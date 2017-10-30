//
//  UserManager.swift
//  Skoon
//
//  Created by Stefan Trauth on 04.04.17.
//  Copyright © 2017 Stefan Trauth. All rights reserved.
//

import Foundation
import KeychainAccess
import SafariServices
import UIKit

public extension Notification.Name {
    public static let didLogin = Notification.Name("didLogin")
    public static let loginFailed = Notification.Name("loginFailed")
    public static let didLogout = Notification.Name("didLogout")
}

public class UserManager: NSObject, SFSafariViewControllerDelegate {
    
    public static let shared = UserManager()
    private let keychain = Keychain(service: "de.stefantrauth.Skoon", accessGroup: Constants.keychainAccessGroup)
    private var authSession: SFAuthenticationSession?
    
    public var accessToken: String? {
        get {
            return keychain[string: Constants.keychainAuthorizationTokenKey]
        }
        set {
            if newValue != nil {
                keychain[Constants.keychainAuthorizationTokenKey] = newValue
                NotificationCenter.default.post(Notification(name: .didLogin, object: nil, userInfo: nil))
            } else {
                do {
                    try keychain.remove(Constants.keychainAuthorizationTokenKey)
                } catch {}
                NotificationCenter.default.post(Notification(name: .didLogout))
            }
        }
    }
    
    public var isUserLoggedIn: Bool {
        return accessToken != nil
    }
    
    // MARK: actions
    
    public func fetchUser(complete: @escaping (_ user: User?) -> Void) {
        if !isUserLoggedIn {
            complete(nil)
            return
        }
        Fyyd.fetchAuthorizedUser { (user) in
            complete(user)
        }
    }
    
    public func login() {
        let authURL = URL(string: "https://fyyd.de/oauth/authorize?client_id=\(Constants.clientId)")!
        authSession = SFAuthenticationSession(url: authURL, callbackURLScheme: nil) { (callbackUrl, error) in
            guard error == nil else {
                NotificationCenter.default.post(Notification(name: .loginFailed, object: nil, userInfo: ["error": error?.localizedDescription ?? "login failed"]))
                return
            }
            let oauthToken = self.extractTokenFrom(url: callbackUrl, withName: "token")
            if let errorMessage = self.extractTokenFrom(url: callbackUrl, withName: "error") {
                NotificationCenter.default.post(Notification(name: .loginFailed, object: nil, userInfo: ["error": errorMessage]))
            }
            
            self.accessToken = oauthToken
        }
        authSession?.start()
    }
    
    public func logout() {
        let bundle = Bundle(identifier: "de.stefantrauth.Fyyd")!
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = Constants.tintColor
        alert.addAction(UIAlertAction(title: NSLocalizedString("logout", bundle: bundle, value: "Logout", comment: "logout"), style: .destructive, handler: { (action) in
            self.accessToken = nil
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", bundle: bundle, value: "Cancel", comment: "cancel"), style: .cancel, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    public func showLoginRequiredMessage() {
        let bundle = Bundle(identifier: "de.stefantrauth.Fyyd")!
        let alert = UIAlertController(title: NSLocalizedString("login required", bundle: bundle, value: "Login Required", comment: "login required alert title"), message: NSLocalizedString("login required message", bundle: bundle, value: "You need to login with your fyyd account to use this feature.", comment: "login required message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("login action button title", bundle: bundle, value: "Login", comment: "login action button title"), style: .default, handler: { (_) in
            self.login()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("dismiss action button title", bundle: bundle, value: "Dismiss", comment: "dismiss"), style: .default, handler: nil))
        alert.view.tintColor = Constants.tintColor
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
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
