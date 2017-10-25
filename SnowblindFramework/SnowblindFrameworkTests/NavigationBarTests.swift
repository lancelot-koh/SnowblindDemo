//
//  NavigationBarTests.swift
//  SAPMDCFramework
//
//  Copyright © 2017. SAP. All rights reserved.
//

import XCTest
@testable import SAPMDC

private var applyCalled = false

class NavigationBarTests: XCTestCase {
    func testApplyFioriStyleCalled() {
        NavigationBar.applyFioryStyle()
        XCTAssertEqual(UINavigationBar.appearance().tintColor, UIColor.preferredFioriColor(forStyle: .tintColorLight))
        XCTAssertEqual(UINavigationBar.appearance().barTintColor, UIColor.preferredFioriColor(forStyle: .backgroundGradientTop))
        XCTAssertEqual(UINavigationBar.appearance().isTranslucent, false)
        XCTAssertEqual(UINavigationBar.appearance().barStyle, .black)
    }
}
