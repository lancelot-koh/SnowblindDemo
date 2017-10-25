//
//  LoggerManager.swift
//  SAPMDCFramework
//
//  Copyright © 2017. SAP. All rights reserved.
//

import Foundation
import SAPCommon
import SAPFoundation

@objc (LoggerManagerSwift)
public class LoggerManager: NSObject {

    static var clientLocalFileHandler: LogHandler?
    static var clientLocalLogFileURL: URL?

    private static let documentsDirectoryURL: URL? = {
        do {
            let documentDirectoryURL =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return documentDirectoryURL
        } catch let error {
            Logger.root.error("Could not create documents directory", error: error)
            return nil
        }
    }()

    @objc public static func attachUploaderToRootLogger() throws {
        try SAPcpmsLogUploader.attachToRootLogger()
    }

    @objc public static func uploadLogs(backendURL: String, applicationID: String? = nil,
                                        resolve: @escaping SnowblindPromiseResolveBlock,
                                        reject: @escaping SnowblindPromiseRejectBlock) -> Void {

        let backendURL = URL(string: backendURL)
        let session = OAuthRequestor.sharedInstance.urlSession

        if let url = backendURL {
            if let appID = applicationID {
                let settingsParameters = SAPcpmsSettingsParameters(backendURL: url, applicationID: appID)
                SAPcpmsLogUploader.uploadLogs(sapURLSession: session, settingsParameters: settingsParameters) { err in
                    handleUploadCompletion(error: err, with: reject, and: resolve)
                    return
                }
            } else {
                SAPcpmsLogUploader.uploadLogs(sapURLSession: session, endpoint: url) { (err) in
                    handleUploadCompletion(error: err, with: reject, and: resolve)
                    return
                }
            }
        } else {
            reject(nil, "Backend URL is not valid.", nil)
            return
        }
    }

    private static func handleUploadCompletion(error: SAPcpmsLogUploaderError?,
                                               with reject: @escaping SnowblindPromiseRejectBlock,
                                               and resolve: @escaping SnowblindPromiseResolveBlock) {
        if let e = error {
            reject(nil, e.description, e)
            return
        } else {
            resolve(true)
            return
        }
    }

    @objc public static func addLocalFileHandler(withFileName fileName: String, maxFileSize maxFileSizeInMegaBytes: Int) throws {
        clientLocalLogFileURL = documentsDirectoryURL?.appendingPathComponent(fileName)
        let maxFileSize: UInt64 = UInt64(maxFileSizeInMegaBytes) * 1024 * 1024
        clientLocalFileHandler = try FileLogHandler(fileURL: clientLocalLogFileURL!, maxFileSize: maxFileSize)
        Logger.root.add(handler: clientLocalFileHandler!)
    }

    @objc public static func activateLogLevel(withSeverity level: String) {
        if let validLevel = parseLogLevel(ofSeverity: level) {
            Logger.root.logLevel = validLevel
        } else {
            // level is not valid, do nothing
            print("Log level is not valid: " + (level))
        }
    }

    // Logs a message to the console
    @objc public static func log(_ message: String, withSeverity severity: String?) {
        if let changedLogLevel = parseLogLevel(ofSeverity: severity) {
            logMessage(message, withLogLevel: changedLogLevel)
        } else {
            Logger.root.log(message)
        }
    }

    private static func logMessage(_ message: String, withLogLevel logLevel: LogLevel) {
        switch logLevel {
        case .debug:
            Logger.root.debug(message)
        case .error:
            Logger.root.error(message)
        case .info:
            Logger.root.info(message)
        case .warn:
            Logger.root.warn(message)
        default:
            return
        }
    }

    private static func parseLogLevel (ofSeverity severity: String?) -> LogLevel? {
        if let validLogLevel = severity?.lowercased() {
            switch validLogLevel {
            case LogLevel.off.description.lowercased():
                return LogLevel.off
            case LogLevel.error.description.lowercased():
                return LogLevel.error
            case LogLevel.warn.description.lowercased():
                return LogLevel.warn
            case LogLevel.info.description.lowercased():
                return LogLevel.info
            case LogLevel.debug.description.lowercased():
                return LogLevel.debug
            default:
                return nil
            }
        }
        return nil
    }
}
