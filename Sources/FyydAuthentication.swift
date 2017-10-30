//
//  UserManager.swift
//  FyydKit
//
//  Created by Stefan Trauth on 04.04.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation
import SafariServices

public protocol FyydAuthenticationDelegate {
    func didLoginWith(authToken: String?, error: Error?)
}

@available(iOSApplicationExtension 11.0, *)
public class FyydAuthentication: NSObject, SFSafariViewControllerDelegate {
    
    private var authSession: SFAuthenticationSession?
    public var delegate: FyydAuthenticationDelegate?
    
    public func loginUserWith(clientId: String) {
        let authURL = URL(string: "https://fyyd.de/oauth/authorize?client_id=\(clientId)")!
        authSession = SFAuthenticationSession(url: authURL, callbackURLScheme: nil) { (callbackUrl, error) in
            let token = self.extractTokenFrom(url: callbackUrl, withName: "token")
            self.delegate?.didLoginWith(authToken: token, error: error)
        }
        authSession?.start()
    }
    
    private func extractTokenFrom(url: URL?, withName tokenName: String) -> String? {
        // fragment does return the string after #
        if let tokenFragment = url?.fragment {
            // token=ydflgjkhydflgkjhdflkgjhldfkgjhlsdkjfgh
            let parts = tokenFragment.components(separatedBy: "=")
            if parts.first == tokenName {
                let token = parts[1]
                return token
            }
        }
        return nil
    }
}
