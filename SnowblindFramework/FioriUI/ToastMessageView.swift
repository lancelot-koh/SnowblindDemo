//
//  ToastMessageView.swift
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori

@objc (ToastMessageViewSwift)

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
public class ToastMessageView: NSObject {
  /// Creates and displays a toast message from HCP SDK FioriUIKit
  @objc public static func displayToastMsg(params: [String: Any]) {

    var message: String = ""
    if let unwrappedMessage = params["message"] {
      message = String(describing: unwrappedMessage)
    }

    var icon: String?
    var image: UIImage?

    if let tempIcon = params["icon"] as? String, let myImage = ImagePathHandler.image(from: tempIcon) {
      icon = tempIcon
      image = myImage
    } else {
      icon = nil
      image = nil
    }

    let duration = params["duration"] as? Float
    let maxNumberOfLines = params["maxNumberOfLines"] as? Int
    let toastInWindow = params["background"] as? UIWindow
    let toastInView = params["background"] as? UIView

    let result = self.findIfWindowOrView(window: toastInWindow, view: toastInView)

    switch (icon, duration, maxNumberOfLines ) {

    case (.some, .some, .some) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, icon: image!, inWindow: toastInWindow!, withDuration: duration!, maxNumberOfLines: maxNumberOfLines!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, icon: image!, inView: toastInView!, withDuration: duration!, maxNumberOfLines: maxNumberOfLines!)
      } else {
        FUIToastMessage.show(message: message, icon: image!, withDuration: duration!, maxNumberOfLines: maxNumberOfLines!)
      }
      break

    case (.some, .some, .none) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, icon: image!, inWindow: toastInWindow!, withDuration: duration!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, icon: image!, inView: toastInView!, withDuration: duration!)
      } else {
        FUIToastMessage.show(message: message, icon: image!, withDuration: duration!)
      }
      break

    case (.some, .none, .some) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, icon: image!, inWindow: toastInWindow!, maxNumberOfLines: maxNumberOfLines!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, icon: image!, inView: toastInView!, maxNumberOfLines: maxNumberOfLines!)
      } else {
        FUIToastMessage.show(message: message, icon: image!, maxNumberOfLines: maxNumberOfLines!)
      }
      break

    case (.some, .none, .none) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, icon: image!, inWindow: toastInWindow!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, icon: image!, inView: toastInView!)
      } else {
        FUIToastMessage.show(message: message, icon: image!)
      }
      break

    case (.none, .some, .some) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, inWindow: toastInWindow!, withDuration: duration!, maxNumberOfLines: maxNumberOfLines!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, inView: toastInView!, withDuration: duration!, maxNumberOfLines: maxNumberOfLines!)
      } else {
        FUIToastMessage.show(message: message, withDuration: duration!, maxNumberOfLines: maxNumberOfLines!)
      }
      break

    case (.none, .some, .none) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, inWindow: toastInWindow!, withDuration: duration!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, inView: toastInView!, withDuration: duration!)
      } else {
        FUIToastMessage.show(message: message, withDuration: duration!)
      }
      break

    case (.none, .none, .some) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, inWindow: toastInWindow!, maxNumberOfLines: maxNumberOfLines!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, inView: toastInView!, maxNumberOfLines: maxNumberOfLines!)
      } else {
        FUIToastMessage.show(message: message, maxNumberOfLines: maxNumberOfLines!)
      }
      break

    case (.none, .none, .none) :
      if result.isWindowProvided {
        FUIToastMessage.show(message: message, inWindow: toastInWindow!)
      } else if result.isViewProvided {
        FUIToastMessage.show(message: message, inView: toastInView!)
      } else {
        FUIToastMessage.show(message: message)
      }
      break
    }
  }

  public static func findIfWindowOrView(window: UIWindow?, view: UIView?) -> (isWindowProvided: Bool, isViewProvided: Bool) {
    var isWindow: Bool = false
    var isView: Bool = false

    guard window != nil else {
      isWindow = false
      if view != nil {
        isView = true
      }
      return (isWindow, isView)
    }
    isWindow = true
    isView = false
    return ( isWindow, isView)
  }
}
