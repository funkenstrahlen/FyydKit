//
//  FyydKit.swift
//  FyydKit
//
//  Created by Stefan Trauth on 30.10.17.
//  Copyright © 2017 FyydKit. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

enum FyydKitError: Error {
    case missingId
    case curationNotDeletable
    case missingMetadata
}

extension FyydKitError: LocalizedError {
    public var errorDescription: String? {
        let bundle = Bundle(identifier: "de.stefantrauth.FyydKit")!
        switch self {
        case .missingId:
            return NSLocalizedString("missing id", bundle: bundle, value: "Missing element id", comment: "missing element id")
        case .curationNotDeletable:
            return NSLocalizedString("curation not deletable", bundle: bundle, value: "This curation can not be deleted because it is your personal curation.", comment: "curation not deletable")
        case .missingMetadata:
            return NSLocalizedString("missing metadata", bundle: bundle, value: "missing metadata", comment: "missing metadata")
        }
        
        
    }
}

public struct FyydKit {
    
    private static let apiVersion = "0.2"
    private static let baseUrl = "https://api.fyyd.de/\(apiVersion)"
    public static var defaultResultCount = 20
    
    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    public static func remove(episode: Episode, fromCuration curation: Curation, authToken: String, complete: @escaping (_ error: Error?) -> Void) {
        let parameters: Parameters = [
            "episode_id": episode.id,
            "curation_id": curation.id,
            "force_state": false
        ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)"
        ]
        Alamofire.request("\(baseUrl)/curate", method: .post, parameters: parameters, headers: headers).validate().response { response in
            if let error = response.error {
                complete(error)
                return
            }
            complete(nil)
        }
    }
    
    public static func add(episode: Episode, toCuration curation: Curation, withMessage message: String?, authToken: String, complete: @escaping (_ error: Error?) -> Void) {
        var parameters: Parameters = [
            "episode_id": episode.id,
            "curation_id": curation.id,
            "force_state": true
        ]
        if message != nil {
            parameters["why"] = message!
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)"
        ]
        Alamofire.request("\(baseUrl)/curate", method: .post, parameters: parameters, headers: headers).validate().response { response in
            if let error = response.error {
                complete(error)
                return
            }
            complete(nil)
        }
    }
    
    public static func fetchAuthorizedUserFor(authToken: String, complete: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)"
        ]
        let url = URL(string: "\(baseUrl)/account/info")!
        
        Alamofire.request(url, headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder) { (response: DataResponse<User>) in
            let user = response.result.value
            complete(user, response.error)
        }
    }
    
    public static func fetchPublicUserWith(id: Int, complete: @escaping (_ user: User?, _ error: Error?) -> Void) {
        let url = URL(string: "\(baseUrl)/user")!
        Alamofire.request(url, parameters: ["user_id": id]).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder) { (response: DataResponse<User>) in
            let user = response.result.value
            complete(user, response.error)
        }
    }
    
    public static func create(curation: Curation, coverartImage: UIImage? = nil, authToken: String, complete: @escaping (_ curation: Curation?, _ error: Error?) -> Void) {
        update(curation: curation, coverartImage: coverartImage, authToken: authToken, complete: complete)
    }
    
    public static func update(curation: Curation, coverartImage: UIImage? = nil, authToken: String, complete: @escaping (_ curation: Curation?, _ error: Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        guard let title = curation.title, let description = curation.description else {
            complete(nil, FyydKitError.missingMetadata)
            return
        }
        
        // this is String:String instead of Parameters type to use value.data later in multipart upload
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
                        complete(response.result.value, response.error)
                    })
                case .failure(let encodingError):
                    complete(nil, encodingError)
                }
            }
        } else {
            // Just do a simple post and do not upload any image
            Alamofire.request(url, method: .post, parameters: parameters, headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Curation>) in
                complete(response.result.value, response.error)
            })
        }
    }
    
    public static func destroy(curation: Curation, authToken: String, complete: @escaping (_ error: Error?) -> Void) {
        if !curation.isDeletable {
            complete(FyydKitError.curationNotDeletable)
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        let parameters: Parameters = ["curation_id": curation.id]
        Alamofire.request("\(baseUrl)/curation/delete", method: .post, parameters: parameters, headers: headers).validate().response { response in
            complete(response.error)
        }
    }
    
    public static func fetchPodcastWith(id: Int, includeEpisodes: Bool = true, complete: @escaping (_ podcast: Podcast?, _ error: Error?) -> Void) {
        let parameters : Parameters = ["podcast_id": id]
        let url = includeEpisodes ? URL(string: "\(baseUrl)/podcast/episodes")! : URL(string: "\(baseUrl)/podcast")!
        Alamofire.request(url, parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Podcast>) in
            complete(response.result.value, response.error)
        })
    }
    
    public static func fetchEpisodeWith(id: Int, complete: @escaping (_ episode: Episode?, _ error: Error?) -> Void) {
        let parameters: Parameters = ["episode_id": id]
        
        Alamofire.request("\(baseUrl)/episode", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Episode>) in
            complete(response.result.value, response.error)
        })
    }
    
    public static func searchForCurationsBy(term: String, andCategory category: ItunesCategory? = nil, resultCount: Int = defaultResultCount, complete: @escaping (_ curations: [Curation], _ error: Error?) -> Void) {
        var parameters: Parameters = ["term": term, "count": resultCount]
        if category != nil {
            parameters["category"] = category!.id
        }
        
        Alamofire.request("\(baseUrl)/search/curation", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            let curations = response.result.value ?? [Curation]()
            complete(curations, response.error)
        })
    }
    
    public static func searchForEpisodesWith(title: String? = nil, url: String? = nil, duration: Int? = nil, podcastTitle: String? = nil, guid: String? = nil, term: String? = nil, resultCount: Int = defaultResultCount, complete: @escaping (_ episodes: [Episode], _ error: Error?) -> Void) {
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
            let episodes = response.result.value ?? [Episode]()
            complete(episodes, response.error)
        })
    }
    
    public static func searchForPodcastsWith(title: String? = nil, url: String? = nil, term: String? = nil, resultCount: Int = defaultResultCount, complete: @escaping (_ podcasts: [Podcast], _ error: Error?) -> Void) {
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
            let podcasts = response.result.value ?? [Podcast]()
            complete(podcasts, response.error)
        })
    }
    
    public static func fetchCurationWith(id: Int, includingEpisodes: Bool = false, authToken: String? = nil, complete: @escaping (_ curation: Curation?, _ error: Error?) -> Void) {
        var headers: HTTPHeaders = [String : String]()
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        let parameters: Parameters = ["curation_id": id]
        let url = includingEpisodes ? "\(baseUrl)/curation/episodes" : "\(baseUrl)/curation"
        
        Alamofire.request(url, parameters: parameters, headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<Curation>) in
            complete(response.result.value, response.error)
        })
    }
    
    public static func fetchCurationsWith(category: ItunesCategory, resultCount: Int = defaultResultCount, complete: @escaping (_ curations: [Curation], _ error: Error?) -> Void) {
        let parameters: Parameters = ["category_id": category.id, "count": resultCount]
        
        Alamofire.request("\(baseUrl)/category/curation", parameters: parameters).validate().responseDecodableObject(queue: nil, keyPath: "data.curations", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            let curations = response.result.value ?? [Curation]()
            complete(curations, response.error)
        })
    }
    
    public static func fetchPublicCurationsOfUserWith(id: Int, complete: @escaping (_ curations: [Curation], _ error: Error?) -> Void) {
        Alamofire.request("\(baseUrl)/user/curations", parameters: ["user_id": id]).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            let curations = response.result.value ?? [Curation]()
            complete(curations, response.error)
        })
    }
    
    public static func fetchAuthorizedUserCurations(authToken: String, complete: @escaping (_ curations: [Curation], _ error: Error?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)"
        ]
        
        Alamofire.request("\(baseUrl)/account/curations", headers: headers).validate().responseDecodableObject(queue: nil, keyPath: "data", decoder: decoder, completionHandler: { (response: DataResponse<[Curation]>) in
            let curations = response.result.value ?? [Curation]()
            complete(curations, response.error)
        })
    }
}
