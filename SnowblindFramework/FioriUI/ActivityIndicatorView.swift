//
//  ActivityIndicatorView.swift
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori

@objc (ActivityIndicatorViewSwift)
public class ActivityIndicatorView: NSObject {

  static var modalLoadingIndicatorView: FUIModalLoadingIndicatorView?

  @objc public static func dismiss() {
    modalLoadingIndicatorView?.dismiss()
    modalLoadingIndicatorView = nil
  }

  @objc public static func show(params: [String: Any]) {

    modalLoadingIndicatorView = _allocateIndicator()

    if let text = params["text"] as? String {
      modalLoadingIndicatorView?.text = text
    }

    let window = UIApplication.shared.keyWindow
    modalLoadingIndicatorView?.show(inView:window!)
  }

  @objc private static func _allocateIndicator() -> FUIModalLoadingIndicatorView? {
    guard modalLoadingIndicatorView == nil else {
      return nil
    }

   return SAPFiori.FUIModalLoadingIndicatorView()
  }
}
