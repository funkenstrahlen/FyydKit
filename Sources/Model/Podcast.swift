//
//  Podcast.swift
//  FyydKit
//
//  Created by Stefan Trauth on 30.07.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation

public struct Podcast: Decodable {
    public var title: String
    public var id: Int
    public var coverartUrlString: String
    public var slug: String
    public var coverartThumbnailUrlString: String
    public var languageCode: String
    public var lastPublicationDate: Date
    public var iTunesCategories: [Int]
    public var ranking: Int
    public var fyydWebUrlString: String
    public var description: String
    public var subtitle: String
    public var episodes: [Episode]?
    public var lastFyydRefreshDate: Date
    public var rssFeedUrlString: String
    
    enum CodingKeys : String, CodingKey {
        case title
        case id
        case coverartUrlString = "imgURL"
        case slug
        case coverartThumbnailUrlString = "layoutImageURL"
        case languageCode = "language"
        case lastPublicationDate = "lastpub"
        case iTunesCategories = "categories"
        case ranking = "rank"
        case fyydWebUrlString = "url_fyyd"
        case description
        case subtitle
        case episodes
        case lastFyydRefreshDate = "lastpoll"
        case rssFeedUrlString = "xmlURL"
    }
    
    public var coverartUrl: URL? {
        return URL(string: coverartUrlString)
    }
    
    public var coverartThumbnailUrl: URL? {
        return URL(string: coverartThumbnailUrlString)
    }
    
    public var fyydWebUrl: URL? {
        return URL(string: fyydWebUrlString)
    }
    
    public var rssFeedUrl: URL? {
        return URL(string: rssFeedUrlString)
    }
    
    public var subscribeURLSchemes: [String:URL]? {
        guard let rssUrl = rssFeedUrl else { return nil}
        return SubscribeHelper.subscribeUrlSchemesFrom(rssUrl: rssUrl)
    }
    
}
