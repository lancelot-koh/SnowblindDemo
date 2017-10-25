//
//  Search.swift
//  SAPMDC
//
//  Created by Erickson, Ronnie on 8/28/17.
//  Copyright © 2017 SAP. All rights reserved.
//
import Foundation

public class Search: NSObject {
  private var updateTimer = Timer()
  var searchString: String = ""
  var enabled: Bool = false
  var placeholder: String = ""
  var barcodeScanner: Bool = false
  var delay: Double = 0
  var minimumCharacterThreshold: Int = 0

  init(params: NSDictionary) {
    guard let searchParams = params["Search"] as? NSDictionary else {
      return
    }

    self.enabled = searchParams["Enabled"] as? Bool ?? false
    self.placeholder = searchParams["Placeholder"] as? String ?? ""
    self.barcodeScanner = searchParams["BarcodeScanner"] as? Bool ?? false
    self.minimumCharacterThreshold = searchParams["MinimumCharacterThreshold"] as? Int ?? 0
    if let delay = searchParams["Delay"] as? Double {
      if delay > 0 {
        self.delay = delay / 1000
      }
    }
  }

  public func schedule(searchString: String, target: Any, selector: Selector) {
    // When you first click in a search box, it calls updateSearchResults...we don't need to waste the
    // time calling back and letting {N} figure that out.
    guard searchString != self.searchString else {
      return
    }

    // If we have no delay and we haven't met our character threshold, we don't apply the search.
    if searchString.characters.count > self.searchString.characters.count {
      guard searchString.characters.count >= self.minimumCharacterThreshold else {
        return
      }
    }

    self.searchString = searchString
    self.updateTimer.invalidate()
    self.updateTimer = Timer.scheduledTimer(timeInterval: delay, target: target, selector: selector,
                                            userInfo: ["searchString": self.searchString], repeats: false)
  }

  public func immediateSearch(searchString: String, target: Any, selector: Selector) {
    self.searchString = searchString
    self.updateTimer.invalidate()
    self.updateTimer = Timer.scheduledTimer(timeInterval: 0, target: target, selector: selector,
                                            userInfo: ["searchString": self.searchString], repeats: false)
  }
}
