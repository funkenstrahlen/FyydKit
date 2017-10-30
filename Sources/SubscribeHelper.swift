//
//  SubscribeHelper.swift
//  FyydKit
//
//  Created by Stefan Trauth on 24.09.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation

public struct SubscribeHelper {
    // do not forget to enable them in Info.plist
    public static func subscribeUrlSchemesFrom(rssUrl: URL) -> [String: URL]? {
        guard let urlScheme = rssUrl.scheme else { return nil }
        
        let urlStringWithoutScheme = rssUrl.absoluteString.replacingOccurrences(of: urlScheme + "://", with: "")
        let urlString = rssUrl.absoluteString
        
        guard let castroUrl = URL(string: "castro://subscribe/\(urlStringWithoutScheme)") else { return [String:URL]() }
        guard let downcastUrl = URL(string: "downcast://\(urlString)") else { return [String:URL]() }
        guard let instacastUrl = URL(string: "instacast://\(urlStringWithoutScheme)") else { return [String:URL]() }
        guard let overcastUrl = URL(string: "overcast://x-callback-url/add?url=\(urlString)") else { return [String:URL]() }
        guard let pocketCastsUrl = URL(string: "pktc://subscribe/\(urlStringWithoutScheme)") else { return [String:URL]() }
        guard let applePodcastsUrl = URL(string: "podcast://\(urlStringWithoutScheme)") else { return [String:URL]() }
        guard let podcatUrl = URL(string: "podcat://\(urlString)") else { return [String:URL]() }
        
        return ["Podcat" : podcatUrl,
                "Castro" : castroUrl,
                "Downcast" : downcastUrl,
                "Instacast" : instacastUrl,
                "Overcast" : overcastUrl,
                "PocketCasts" : pocketCastsUrl,
                "Podcasts" : applePodcastsUrl
        ]
    }
    
}
