//
//  SecureOAuth2TokenStore.swift
//  SAPMDCFramework
//
//  Created by Wonderley, Lucas on 3/20/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import SAPFoundation

/**
 * Implements the OAuth2TokenStore protocol using the secure store.
 */
public class SecureOAuth2TokenStore: SAPFoundation.OAuth2TokenStore {
  // This in-memory property is only used if the secure store is closed.
  // When the secure store is opened, the in-memory token is synced into the store.
  // This is only intended for use before the secure store is created.
  private var token: OAuth2Token?

  public static let sharedInstance: SecureOAuth2TokenStore = {
    let instance = SecureOAuth2TokenStore()
    return instance
  }()

  public func store(token: OAuth2Token) {
    // The URL passed to the token store isn't really used, but the string
    // has to be a valid URL or else the URL initializer will crash.
    let string = "https://www.sap.com"
    let url: URL = URL(string: string)!
    self.store(token: token, for: url)
  }

  public func store(token: OAuth2Token, for url: URL) {
    if SecureStoreManager.sharedInstance.isOpen() {
      do {
        let tokenAsJsonString = String(data: token.json()!, encoding: .utf8)
        try SecureStoreManager.sharedInstance.put(tokenAsJsonString!, forKey: "OAuth2Token")
      } catch {
        print("Failed to store OAuth token.")
      }
    } else {
      self.token = token
    }
  }

  public func token(for url: URL) -> OAuth2Token? {
    if SecureStoreManager.sharedInstance.isOpen() {
      do {
        guard let tokenAsJsonString = try SecureStoreManager.sharedInstance.getString("OAuth2Token") else {
          print("Failed to get OAuth token.")
          return nil
        }
        let data = tokenAsJsonString.data(using: .utf8)
        return OAuth2Token(json: data!)
      } catch {
        print("Failed to get OAuth token.")
        return nil
      }
    } else {
      return self.token
    }
  }

  public func deleteToken(for url: URL) {
    if SecureStoreManager.sharedInstance.isOpen() {
      do {
        try SecureStoreManager.sharedInstance.remove("OAuth2Token")
      } catch {
        print("Failed to delete OAuth token.")
      }
    } else {
      self.token = nil
    }
  }

  public func syncInMemoryTokenToStore() -> Void {
    guard let token = self.token else {
      return
    }
    self.store(token: token)
    self.token = nil
  }
}
