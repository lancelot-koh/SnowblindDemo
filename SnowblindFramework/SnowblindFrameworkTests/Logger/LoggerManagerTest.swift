//
//  LoggerManagerTest.swift
//  SAPMDCFramework
//
//  Created by Hably, Alexandra on 2017. 02. 20..
//  Copyright © 2017. SAP. All rights reserved.
//

import Foundation
import XCTest
import SAPFoundation
import SAPCommon

@testable import SAPMDC

class LoggerManagerTests: XCTestCase {

    private let testMessage = "this is a test message"

    private let clientId = "595359b3-74d9-4fa0-ba94-0cd234abcb26"
    private let authorizationEndpointURL = "https://oauthasservices-wbac932df.int.sap.hana.ondemand.com/oauth2/api/v1/authorize"
    private let redirectUrl = "https://oauthasservices-wbac932df.int.sap.hana.ondemand.com"
    private let tokenEndpointURL = "https://oauthasservices-wbac932df.int.sap.hana.ondemand.com/oauth2/api/v1/token"

    func testWritingToLocalLogFile() {
        do {
            try LoggerManager.addLocalFileHandler(withFileName: "testLogFile.txt", maxFileSize: 6)
            let text = try String(contentsOf: LoggerManager.clientLocalLogFileURL!, encoding: String.Encoding.utf8)
            XCTAssertNotNil(text)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
        Logger.root.remove(handler: LoggerManager.clientLocalFileHandler!)
    }

    func testActivateLogLevels() {
        LoggerManager.activateLogLevel(withSeverity: "Debug")
        XCTAssertEqual(Logger.root.logLevel, LogLevel.debug)

        LoggerManager.activateLogLevel(withSeverity: "Error")
        XCTAssertEqual(Logger.root.logLevel, LogLevel.error)

        LoggerManager.activateLogLevel(withSeverity: "Warn")
        XCTAssertEqual(Logger.root.logLevel, LogLevel.warn)

        LoggerManager.activateLogLevel(withSeverity: "Info")
        XCTAssertEqual(Logger.root.logLevel, LogLevel.info)

        LoggerManager.activateLogLevel(withSeverity: "Off")
        XCTAssertEqual(Logger.root.logLevel, LogLevel.off)
    }

    func testLogMessage() {
        do {
            try LoggerManager.addLocalFileHandler(withFileName: "testLogFile.txt", maxFileSize: 6)
            LoggerManager.activateLogLevel(withSeverity: "Debug")
            LoggerManager.log(self.testMessage, withSeverity: "Error")
            let logText = try String(contentsOf: LoggerManager.clientLocalLogFileURL!, encoding: String.Encoding.utf8)
            XCTAssertNotNil(logText)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }

    func testLogUploading() {
        do {
            try LoggerManager.attachUploaderToRootLogger()
            LoggerManager.activateLogLevel(withSeverity: "Debug")
            LoggerManager.log(self.testMessage, withSeverity: "Error")
            //LoggerManager.uploadLogs(backendURL: String, resolve: nil, reject: nil)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }

}
