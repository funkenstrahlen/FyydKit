//
//  FyydKit.swift
//  FyydKit
//
//  Created by Stefan Trauth on 30.10.17.
//  Copyright © 2017 FyydKit. All rights reserved.
//

import Foundation

enum FyydApiError: Error {
    case missingAccessToken
    case missingId
    case curationNotDeletable
}

extension FyydApiError: LocalizedError {
    public var errorDescription: String? {
        let bundle = Bundle(identifier: "de.stefantrauth.Fyyd")!
        switch self {
        case .missingAccessToken:
            return NSLocalizedString("missing access token", bundle: bundle, value: "Missing access token", comment: "missing access token")
        case .missingId:
            return NSLocalizedString("missing id", bundle: bundle, value: "Missing element id", comment: "missing element id")
        case .curationNotDeletable:
            return NSLocalizedString("curation not deletable", bundle: bundle, value: "This curation can not be deleted because it is your personal curation.", comment: "curation not deletable")
        }
    }
}

public struct FyydKit {
    
    private static let baseUrl = "https://api.fyyd.de/0.2"
    public static let defaultResultCount = 20
    
    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // "2017-04-14 15:05:11"
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    public static func remove(episode: Episode, fromCuration curation: Curation, complete: @escaping (_ error: Error?) -> Void) {
        guard let token = UserManager.shared.accessToken else {
            complete(FyydApiError.missingAccessToken)
            return
        }
        
        let parameters: Parameters = [
            "episode_id": episode.id,
            "curation_id": curation.id,
            "force_state": false
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request("\(baseUrl)/curate", method: .post, parameters: parameters, headers: headers).validate().response { response in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
                complete(error)
                return
            }
            complete(nil)
        }
    }
    
    public static func add(episode: Episode, toCuration curation: Curation, withMessage message: String?, complete: @escaping (_ error: Error?) -> Void) {
        guard let token = UserManager.shared.accessToken else {
            complete(FyydApiError.missingAccessToken)
            return
        }
        
        var parameters: Parameters = [
            "episode_id": episode.id,
            "curation_id": curation.id,
            "force_state": true
        ]
        if message != nil {
            parameters["why"] = message!
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        Alamofire.request("\(baseUrl)/curate", method: .post, parameters: parameters, headers: headers).validate().response { response in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
                complete(error)
                return
            }
            complete(nil)
        }
    }
    
    public static func fetchAuthorizedUser(complete: @escaping (_ user: User?) -> Void) {
        guard let token = UserManager.shared.accessToken else {
            complete(nil)
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let url = URL(string: "\(baseUrl)/account/info")!
        
        Alamofire.request(url, headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder) { (response: DataResponse<User>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            
            let user = response.result.value
            complete(user)
        }
    }
    
    public static func fetchPublicUserWith(id: Int, complete: @escaping (_ user: User?) -> Void) {
        let url = URL(string: "\(baseUrl)/user")!
        
        Alamofire.request(url, parameters: ["user_id": id]).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder) { (response: DataResponse<User>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            
            let user = response.result.value
            complete(user)
        }
    }
    
    public static func create(curation: Curation, coverartImage: UIImage? = nil, complete: @escaping (_ curation: Curation?) -> Void) {
        update(curation: curation, coverartImage: coverartImage, complete: complete)
    }
    
    public static func update(curation: Curation, coverartImage: UIImage? = nil, complete: @escaping (_ curation: Curation?) -> Void) {
        guard let token = UserManager.shared.accessToken else {
            complete(nil)
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        guard let title = curation.title, let description = curation.description else {
            complete(nil)
            return
        }
        
        // this must be String:String instead of Parameters type to use value.data later in multipart upload
        var parameters: [String: String] = [
            "title": title,
            "description": description,
            "public": curation.isPublic ? "1" : "0"
        ]
        if curation.id >= 0 {
            parameters["curation_id"] = "\(curation.id)"
        }
        
        let url = URL(string: "\(baseUrl)/curation")!
        
        if let image = coverartImage, let imageData = UIImagePNGRepresentation(image) {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                // add parameters
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
                // add image data
                multipartFormData.append(imageData, withName: "image", fileName: "png", mimeType: "image/png")
            }, to: url, headers: headers) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Curation>) in
                        complete(response.result.value)
                    })
                case .failure(let encodingError):
                    print(encodingError)
                    complete(nil)
                }
            }
        } else {
            // Just do a simple post and do not upload any image
            Alamofire.request(url, method: .post, parameters: parameters, headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Curation>) in
                if let error = response.error {
                    print(error.localizedDescription)
                    debugPrint(response)
                }
                complete(response.result.value)
            })
        }
    }
    
    public static func destroy(curation: Curation, complete: @escaping (_ error: Error?) -> Void) {
        if !curation.isDeletable {
            complete(FyydApiError.curationNotDeletable)
            return
        }
        
        guard let token = UserManager.shared.accessToken else {
            complete(nil)
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: Parameters = ["curation_id": curation.id]
        Alamofire.request("\(baseUrl)/curation/delete", method: .post, parameters: parameters, headers: headers).validate().response { response in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
                complete(error)
            } else {
                complete(nil)
            }
        }
    }
    
    public static func fetchPodcastWith(id: Int, includeEpisodes: Bool = true, complete: @escaping (_ podcast: Podcast?) -> Void) {
        let parameters : Parameters = ["podcast_id": id]
        let url = includeEpisodes ? URL(string: "\(baseUrl)/podcast/episodes")! : URL(string: "\(baseUrl)/podcast")!
        Alamofire.request(url, parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Podcast>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            complete(response.result.value)
        })
    }
    
    public static func fetchEpisodeWith(id: Int, complete: @escaping (_ episode: Episode?) -> Void) {
        let parameters: Parameters = ["episode_id": id]
        
        Alamofire.request("\(baseUrl)/episode", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Episode>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            complete(response.result.value)
        })
    }
    
    public static func fetchMatchingEpisodes(url: URL, complete: @escaping (_ episodes: [Episode]) -> Void) {
        guard let host = url.host else {
            complete([])
            return
        }
        
        var crawler: Crawler?
        
        switch host {
        case PocketCastsCrawler.host: crawler = PocketCastsCrawler()
        case OvercastCrawler.host: crawler = OvercastCrawler()
        case ApplePodcastsCrawler.host: crawler = ApplePodcastsCrawler()
        case CastroCrawler.host: crawler = CastroCrawler()
        case "fyyd.de":
            // ["/", "episode", "1675949"]
            if url.pathComponents.contains("episode") {
                if let episodeId = Int(url.lastPathComponent) {
                    fetchEpisodeWith(id: episodeId, complete: { (episode) in
                        if let episode = episode {
                            complete([episode])
                        } else {
                            complete([])
                        }
                    })
                } else {
                    complete([])
                }
            } else {
                complete([])
            }
            return
        default:
            // if host is unknown try to find a matching episode by searching for the episode url directly
            // this will work for Podcat and also for sharing directly from Safari if the user is currently
            // on the website of a podcast episode
            Fyyd.searchForEpisodesWith(url: url.absoluteString, complete: { (matchingEpisodes) in
                complete(matchingEpisodes)
            })
            return
        }
        
        // this is sure not nil
        crawler!.crawlWebsite(url: url, complete: { (episodeMetadata) in
            guard let metadata = episodeMetadata else {
                complete([])
                return
            }
            Fyyd.searchForEpisodesWith(title: metadata.title, url: url.absoluteString, complete: { (matchingEpisodes) in
                complete(matchingEpisodes)
            })
        })
    }
    
    public static func searchForCurationsBy(term: String, andCategory category: ItunesCategory? = nil, resultCount: Int = defaultResultCount, complete: @escaping (_ curations: [Curation]) -> Void) {
        var parameters: Parameters = ["term": term, "count": resultCount]
        if category != nil {
            parameters["category"] = category!.id
        }
        
        Alamofire.request("\(baseUrl)/search/curation", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            guard let curations = response.result.value else {
                complete([Curation]())
                return
            }
            complete(curations)
        })
    }
    
    public static func searchForEpisodesWith(title: String? = nil, url: String? = nil, duration: Int? = nil, podcastTitle: String? = nil, guid: String? = nil, term: String? = nil, resultCount: Int = defaultResultCount, complete: @escaping (_ episodes: [Episode]) -> Void) {
        var parameters: Parameters = [:]
        if title != nil {
            parameters["title"] = title!
        }
        if url != nil {
            parameters["url"] = url!
        }
        if duration != nil {
            parameters["duration"] = duration!
        }
        if podcastTitle != nil {
            parameters["podcast_title"] = podcastTitle!
        }
        if guid != nil {
            parameters["guid"] = guid!
        }
        if term != nil {
            parameters["term"] = term!
        }
        parameters["count"] = resultCount
        
        Alamofire.request("\(baseUrl)/search/episode", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Episode]>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            guard let episodes = response.result.value else {
                complete([Episode]())
                return
            }
            complete(episodes)
        })
    }
    
    public static func searchForPodcastsWith(title: String? = nil, url: String? = nil, term: String? = nil, resultCount: Int = defaultResultCount, complete: @escaping (_ podcasts: [Podcast]) -> Void) {
        var parameters: Parameters = [:]
        if title != nil {
            parameters["title"] = title!
        }
        if url != nil {
            parameters["url"] = url!
        }
        if term != nil {
            parameters["term"] = term!
        }
        parameters["count"] = resultCount
        
        Alamofire.request("\(baseUrl)/search/podcast", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Podcast]>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            guard let podcasts = response.result.value else {
                complete([Podcast]())
                return
            }
            complete(podcasts)
        })
    }
    
    public static func fetchCurationWith(id: Int, includingEpisodes: Bool = false, complete: @escaping (_ curation: Curation?) -> Void) {
        var headers: HTTPHeaders = [String : String]()
        if let token = UserManager.shared.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        let parameters: Parameters = ["curation_id": id]
        
        let url = includingEpisodes ? "\(baseUrl)/curation/episodes" : "\(baseUrl)/curation"
        
        Alamofire.request(url, parameters: parameters, headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Curation>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            complete(response.result.value)
        })
    }
    
    public static func fetchCurationsWith(category: ItunesCategory, resultCount: Int = defaultResultCount, complete: @escaping (_ curations: [Curation]) -> Void) {
        let parameters: Parameters = ["category_id": category.id, "count": resultCount]
        
        Alamofire.request("\(baseUrl)/category/curation", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data.curations", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            guard let curations = response.result.value else {
                complete([Curation]())
                return
            }
            complete(curations)
        })
    }
    
    public static func fetchPublicCurationsOfUserWith(id: Int, complete: @escaping (_ curations: [Curation]) -> Void) {
        Alamofire.request("\(baseUrl)/user/curations", parameters: ["user_id": id]).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            guard let curations = response.result.value else {
                complete([Curation]())
                return
            }
            complete(curations)
        })
    }
    
    public static func fetchAuthorizedUserCurations(complete: @escaping (_ curations: [Curation]) -> Void) {
        guard let token = UserManager.shared.accessToken else {
            complete([])
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        Alamofire.request("\(baseUrl)/account/curations", headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            if let error = response.error {
                print(error.localizedDescription)
                debugPrint(response)
            }
            guard let curations = response.result.value else {
                complete([Curation]())
                return
            }
            complete(curations)
        })
    }
}
