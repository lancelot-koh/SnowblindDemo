//
//  OAuthRequestor.swift
//  SAPMDCFramework
//
//  Created by Wonderley, Lucas on 3/20/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import SAPFoundation
import SAPCommon

/**
 * Sends requests which can respond to OAuth challenges.
 * Uses SAPFoundation components and the SecureOAuth2TokenStore to accomplish this.
 * Requests may be triggered directly from Swift or from JavaScript.
 * The urlSession property may also be passed to other APIs to automatically handle authentication.
 */
public class OAuthRequestor: NSObject {
  @objc
  public static var sharedInstance: OAuthRequestor = {
    let instance = OAuthRequestor()
    return instance
  }()
  public let urlSession = SAPURLSession()
  public var authenticator: OAuth2Authenticator?
  public var oauthObserver: OAuth2Observer?
  public var cpmsObserver: SAPcpmsObserver?
  public var serviceUrl: String {
    guard let cpmsUrl = self.cpmsUrl else {
      print("Error: Cannot get cpmsUrl for serviceUrl.")
      return ""
    }
    return cpmsUrl + "/" + self.applicationID
  }
  public var applicationID: String {
    guard let cpmsObserver = self.cpmsObserver else {
      print("Error: Cannot get cpmsObserver for applicationID.")
      return ""
    }
    return cpmsObserver.applicationID
  }
  private var cpmsUrl: String?

  @objc
  public func initialize(params: NSDictionary) {

    // If debugging a networking issue, start by uncommenting this line.
    // Logger.root.logLevel = LogLevel.debug
    let oAuthParams = OAuth2AuthenticationParameters(
      authorizationEndpointURL: URL(string: (params["AuthorizationEndpointURL"] as? String)!)!,
      clientID: (params["ClientID"] as? String)!,
      redirectURL: URL(string: (params["RedirectURL"] as? String)!)!,
      tokenEndpointURL: URL(string: (params["TokenEndpointURL"] as? String)!)!,
      requestingScopes: Set<String>()
    )
    self.authenticator = OAuth2Authenticator(authenticationParameters: oAuthParams, webViewPresenter: WKWebViewPresenter())
    // Create an observer to handle OAuth challenges.
    let oauthObserver = OAuth2Observer(authenticator: self.authenticator!, tokenStore: SecureOAuth2TokenStore.sharedInstance)
    self.urlSession.register(oauthObserver)
    self.oauthObserver = oauthObserver
    // Create an observer to add necessary headers.
    self.cpmsObserver = SAPcpmsObserver(applicationID: (params["ApplicationID"] as? String)!)
    // Store the cpmsUrl.
    self.cpmsUrl = params["CpmsURL"] as? String
    self.urlSession.register(self.cpmsObserver!)
  }
  @objc
  public func update(params: NSDictionary) {
    OAuthRequestor.sharedInstance = OAuthRequestor()
    initialize(params: params)
  }
  public func sendRequest(urlString: String,
                          success: @escaping (HTTPURLResponse, Data) -> Void,
                          failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    guard self.authenticator != nil else {
      failure(nil, "OAuthRequestor is not yet initialized.", nil)
      return
    }
    DispatchQueue.global().async {
      let url: URL! = URL(string: urlString)
      let task = OAuthRequestor.sharedInstance.urlSession.dataTask(with: url) { data, response, error in
        DispatchQueue.main.async {
          if let httpResponse = response as? HTTPURLResponse {
            success(httpResponse, data!)
          } else {
            failure(nil, error.debugDescription, nil)
          }
        }
      }
      task.resume()
    }
  }
  @objc public func sendRequest(params: NSDictionary,
                                resolve: @escaping SnowblindPromiseResolveBlock,
                                reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    guard let url = params["url"] as? String! else {
      reject(nil, "url missing from sendRequest call", nil)
      return
    }
    self.sendRequest(urlString: url, success: { (httpResponse: HTTPURLResponse, data: Data) in
      let responseAndData: [String: AnyObject] = [
        "data": data as AnyObject,
        "response": httpResponse
      ]
      resolve(responseAndData)
    }, failure: reject)
  }
  /**
   * Manually trigger an OAuth authentication. This isn't necessary for OAuth
   * to work because the SAPURLSession will handle challenges automatically. However,
   * it's convenient for when we want to get OAuth set up without targetting a specific URL.
   * Because the OAuth2Observer doesn't get involved, we must save the token manually.
   */
  public func triggerOAuth(success: @escaping () -> Void, failure: @escaping () -> Void) {
    guard let authenticator = self.authenticator else {
      failure()
      return
    }
    authenticator.authenticate { token, error in
      if let error = error {
        // handle the error
        print("Error:", error)
        failure()
      } else if let token = token {
        SecureOAuth2TokenStore.sharedInstance.store(token: token)
        success()
      } else {
        print("Error: Did not receive a token.")
        failure()
      }
    }
    // This is added so we can clear cookies each time user reset client due to forgotten passcode etc.
    // If not, after welcome screen, user gets takes to authroize screen skipping the cloud login
    // as the webview remembers previous login. So we need to clear it.
    if let cookies = HTTPCookieStorage.shared.cookies {
      let storage = HTTPCookieStorage.shared
      for cookie in cookies {
        storage.deleteCookie(cookie)
      }
    }
  }
}
