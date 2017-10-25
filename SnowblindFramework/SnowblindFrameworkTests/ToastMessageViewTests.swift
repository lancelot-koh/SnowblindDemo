//
//  ToastMessageViewTests.swift
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class ToastMessageViewTests: XCTestCase {

    let frame = CGRect(x: 0, y: 0, width: 500, height: 1000)

     let maxNumberOfLines = 2, duration: Float = 2.0, message = "Test Message"

    override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.

  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

    func testShowInWindowNoIcon() {
        let containerWindow = UIWindow(frame: frame)
        let background = containerWindow

        let params =  [
            "message": message,
             "duration": duration,
            "maxNumberOfLines": maxNumberOfLines,
            "background": background
            ] as [String : Any]

        ToastMessageView.displayToastMsg(params: params)
    }

    func testShowInWindowNoDuration() {
        let containerWindow = UIWindow(frame: frame)
        let background = containerWindow

        let params =  [
            "message": message,
            "maxNumberOfLines": maxNumberOfLines,
            "background": background
            ] as [String : Any]

        ToastMessageView.displayToastMsg(params: params)
    }

    func testShowInWindowNoMaxLines() {
        let containerWindow = UIWindow(frame: frame)
        let background = containerWindow

        let params =  [
            "message": message,
            "duration": duration,
            "background": background
            ] as [String : Any]

        ToastMessageView.displayToastMsg(params: params)
    }

    func testShowInViewNoIcon() {

        let background = UIView(frame: frame)

        let params =  [
            "message": message,
            "duration": duration,
            "maxNumberOfLines": maxNumberOfLines,
            "background": background
            ] as [String : Any]

        ToastMessageView.displayToastMsg(params: params)
    }

    func testShowInViewNoDuration() {
          let background = UIView(frame: frame)

        let params =  [
            "message": message,
            "maxNumberOfLines": maxNumberOfLines,
            "background": background
            ] as [String : Any]

        ToastMessageView.displayToastMsg(params: params)
    }

    func testShowInViewNoMaxLines() {

        let background = UIView(frame: frame)

        let params =  [
            "message": message,
            "duration": duration,
            "background": background
            ] as [String : Any]

        ToastMessageView.displayToastMsg(params: params)
    }
}
