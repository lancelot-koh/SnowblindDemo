//
//  BannerMessageView.swift
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori

@objc public class BannerMessageView: NSObject {

  // Creates and displays a Banner message from HCP SDK FioriUIKit
  @objc public static func displayBannerMsg(params: [String: Any]) {

    guard let navigationController = params["navigationController"] as? UINavigationController else {
        // Can't display a Banner without a navigation bar from a
        // navigation controller
        return
    }

    guard let unwrappedMessage = params["message"] else {
        // A message is required to display a Banner
        return
    }
    let message = String(describing: unwrappedMessage)

    DispatchQueue.main.async(execute: {
      let banner = FUIBannerMessageView()
      banner.navigationBar = navigationController.navigationBar

      let duration = params["duration"] as? TimeInterval
      let animated = params["animated"] as? Bool
      switch (duration, animated ) {
      case (.none, .none) :
        banner.show(message: message)
        break
      case (.none, .some) :
        banner.show(message: message, animated: animated!)
        break
      case (.some, .none) :
        banner.show(message: message, withDuration: duration!)
        break
      case (.some, .some) :
        banner.show(message: message, withDuration: duration!, animated: animated!)
        break
      }
    })
  }
}
