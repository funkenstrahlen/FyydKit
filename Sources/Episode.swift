//
//  Episode.swift
//  Skoon
//
//  Created by Stefan Trauth on 23.06.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation

public struct EpisodeMetadata {
    public var title: String?
    public var duration: Int? // seconds
    public var url: String?
    
    public init(title: String?, duration: Int?, url: String?) {
        self.title = title
        self.duration = duration
        self.url = url
    }
}

public struct Episode: Decodable {
    public var id: Int
    public var guid: String
    public var title: String
    public var webUrlString: String
    public var enclosureUrlString: String
    public var podcastId: Int
    public var releaseDate: Date // "2017-04-14 15:05:11"
    public var duration: Int?
    public var curationDate: Date?
    public var fyydWebUrlString: String
    public var description: String?
    public var imageUrlString: String?
    
    enum CodingKeys : String, CodingKey {
        case id
        case guid
        case title
        case webUrlString = "url"
        case enclosureUrlString = "enclosure"
        case podcastId = "podcast_id"
        case releaseDate = "pubdate"
        case duration
        case curationDate = "favedDate"
        case fyydWebUrlString = "url_fyyd"
        case description
        case imageUrlString = "imgURL"
    }
    
    public var webUrl: URL? {
        return URL(string: webUrlString)
    }
    
    public var enclosureUrl: URL? {
        return URL(string: enclosureUrlString)
    }
    
    public var fyydWebUrl: URL? {
        return URL(string: fyydWebUrlString)
    }
}
