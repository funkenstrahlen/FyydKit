//
//  Model.swift
//  Skoon
//
//  Created by Stefan Trauth on 03.04.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation

public struct User: Decodable {
    public var id: Int
    public var nick: String?
    public var fullName: String?
    public var bio: String?
    public var websiteUrlString: String?
    public var avatarUrlString: String?

    enum CodingKeys : String, CodingKey {
        case id
        case nick
        case fullName = "fullname"
        case bio
        case websiteUrlString = "url"
        case avatarUrlString = "layoutImageURL"
    }
    
    public var websiteUrl: URL? {
        if websiteUrlString != nil {
            return URL(string: websiteUrlString!)
        }
        return nil
    }
    public var avatarUrl: URL? {
        if avatarUrlString != nil {
            return URL(string: avatarUrlString!)
        }
        return nil
    }
}
