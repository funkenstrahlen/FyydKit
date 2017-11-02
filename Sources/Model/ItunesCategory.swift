//
//  ItunesCategory.swift
//  FyydKit
//
//  Created by Stefan Trauth on 23.06.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation

public enum ItunesCategoryType: Int {
    case arts = 1
    case business = 8
    case comedy = 14
    case education = 15
    case gamesHobbies = 21
    case governmentOrganizations = 27
    case health = 32
    case kidsFamily = 37
    case music = 38
    case newsPolitics = 39
    case religionSpirituality = 40
    case scienceMedicine = 48
    case societyCulture = 52
    case sportsRecreation = 57
    case technology = 62
    case tvFilm = 67
}

public struct ItunesCategory {
    public var id: Int {
        return type.rawValue
    }
    public let type: ItunesCategoryType
    public var name: String {
        let bundle = Bundle(identifier: "de.stefantrauth.FyydKit")!
        switch type {
        case .arts: return NSLocalizedString("arts", bundle: bundle, value: "Arts", comment: "")
        case .business: return NSLocalizedString("business", bundle: bundle, value: "Business", comment: "")
        case .comedy: return NSLocalizedString("comedy", bundle: bundle, value: "Comedy", comment: "")
        case .education: return NSLocalizedString("education", bundle: bundle, value: "Education", comment: "")
        case .gamesHobbies: return NSLocalizedString("games-hobbies", bundle: bundle, value: "Games & Hobbies", comment: "")
        case .governmentOrganizations: return NSLocalizedString("government-organizations", bundle: bundle, value: "Government & Organizations", comment: "")
        case .health: return NSLocalizedString("health", bundle: bundle, value: "Health", comment: "")
        case .kidsFamily: return NSLocalizedString("kids-family", bundle: bundle, value: "Kids & Family", comment: "")
        case .music: return NSLocalizedString("music", bundle: bundle, value: "Music", comment: "")
        case .newsPolitics: return NSLocalizedString("news-politics", bundle: bundle, value: "News & Politics", comment: "")
        case .religionSpirituality: return NSLocalizedString("religion-spirituality", bundle: bundle, value: "Religion & Spirituality", comment: "")
        case .scienceMedicine: return NSLocalizedString("science-medicine", bundle: bundle, value: "Science & Medicine", comment: "")
        case .societyCulture: return NSLocalizedString("society-culture", bundle: bundle, value: "Society & Culture", comment: "")
        case .sportsRecreation: return NSLocalizedString("sports-recreation", bundle: bundle, value: "Sports & Recreation", comment: "")
        case .technology: return NSLocalizedString("techology", bundle: bundle, value: "Technology", comment: "")
        case .tvFilm: return NSLocalizedString("tv-film", bundle: bundle, value: "TV & Film", comment: "")
        }
    }
    
    public init(type: ItunesCategoryType) {
        self.type = type
    }
}
