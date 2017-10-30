//
//  SubscribeHelper.swift
//  Fyyd
//
//  Created by Stefan Trauth on 24.09.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation
import UIKit

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
    
    public static func subscribeTo(podcast: Podcast) {
        guard let subscribeClients = podcast.subscribeURLSchemes else { return }
        subscribeTo(subscribeUrlSchemes: subscribeClients)
    }
    
    public static func subscribeTo(curation: Curation) {
        guard let subscribeClients = curation.subscribeURLSchemes else { return }
        subscribeTo(subscribeUrlSchemes: subscribeClients)
    }
    
    private static func subscribeTo(subscribeUrlSchemes: [String : URL]) {
        let subscribeActionSheet = UIAlertController(title: nil, message: NSLocalizedString("podcast_detailview_subscribe_alert_message", value: "Choose Podcast Client", comment: "when the user clicks on the podcast subscribe button an alert view opens to choose a podcast client. this is the message of the alert view."), preferredStyle: .actionSheet)
        subscribeActionSheet.view.tintColor = Constants.tintColor
        
        // create one option for each podcast client
        for client in subscribeUrlSchemes {
            let clientName = client.0
            let subscribeURL = client.1
            
            // only show the option if the podcast client is installed which reacts to this URL
            if UIApplication.shared.canOpenURL(subscribeURL as URL) {
                let action = UIAlertAction(title: clientName, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                    UIApplication.shared.open(subscribeURL as URL, options: [:], completionHandler: nil)
                })
                subscribeActionSheet.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", value: "Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        subscribeActionSheet.addAction(cancelAction)
        
        
        UIApplication.topViewController()?.present(subscribeActionSheet, animated: true, completion: nil)
    }
    
    
}
