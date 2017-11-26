//
//  FyydKitError.swift
//  FyydKit-iOS
//
//  Created by Stefan Trauth on 26.11.17.
//  Copyright © 2017 FyydKit. All rights reserved.
//

import Foundation

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
