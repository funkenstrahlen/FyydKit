//
//  Curation.swift
//  Skoon
//
//  Created by Stefan Trauth on 23.06.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation

public struct Curation: Decodable {
    public var id: Int // set id to -1 to make clear it is invalid
    public var title: String?
    public var description: String?
    public var webUrlString: String?
    public var rssUrlString: String?
    public var coverartUrl400String: String?
    public var userId: Int?
    public var type: Int
    public var privacy: Int
    public var episodes: [Episode]?
    
    enum CodingKeys : String, CodingKey {
        case id
        case title
        case description
        case webUrlString = "url"
        case rssUrlString = "xmlURL"
        case coverartUrl400String = "layoutImageURL"
        case privacy = "public"
        case type
        case userId = "user_id"
        case episodes
    }
    
    public init(id: Int, title: String?, description: String?, webUrlString: String? = nil, rssUrlString: String? = nil, userId: Int? = nil, isDeletable: Bool = true, isPublic: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.webUrlString = webUrlString
        self.rssUrlString = rssUrlString
        self.userId = userId
        self.privacy = isPublic ? 1 : 0
        self.type = isDeletable ? 1 : 0
    }
    
    
    
    
    
    
    
    public var webUrl: URL? {
        if webUrlString != nil {
            return URL(string: webUrlString!)
        }
        return nil
    }
    public var rssUrl: URL? {
        if rssUrlString != nil {
            return URL(string: rssUrlString!)
        }
        return nil
    }
    public var coverartUrl400: URL? {
        if coverartUrl400String != nil {
            return URL(string: coverartUrl400String!)
        }
        return nil
    }
    public var isPublic: Bool {
        get {
            return privacy == 1
        }
        set {
            privacy = newValue ? 1 : 0
        }
    }
    public var isDeletable: Bool {
        get {
            return type == 1
        }
        set {
            type = newValue ? 1 : 0
        }
    }

    public var subscribeURLSchemes: [String:URL]? {
        guard let rssUrl = rssUrl else { return nil}
        return SubscribeHelper.subscribeUrlSchemesFrom(rssUrl: rssUrl)
    }
}
