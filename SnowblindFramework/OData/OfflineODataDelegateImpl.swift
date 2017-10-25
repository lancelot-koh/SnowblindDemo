//
//  OfflineODataDelegateImpl.swift
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 1/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOfflineOData

class OfflineODataDelegateImpl: OfflineODataDelegate {
  public func offlineODataProvider( _ provider: OfflineODataProvider, didUpdateDownloadProgress progress: OfflineODataProgress ) -> Void {
    print( "Download progress: bytes sent: \(progress.bytesSent)  bytes received: \(progress.bytesReceived)" )
  }

  public func offlineODataProvider( _ provider: OfflineODataProvider, didUpdateFileDownloadProgress progress: OfflineODataFileDownloadProgress ) -> Void {
    print( "File download progress: bytes received: \(progress.bytesReceived) file size: \(progress.fileSize)" )
  }

  public func offlineODataProvider( _ provider: OfflineODataProvider, didUpdateUploadProgress progress: OfflineODataProgress ) -> Void {
    print( "Upload progress: bytes sent: \(progress.bytesSent) bytes received: \(progress.bytesReceived)" )
  }

  public func offlineODataProvider( _ provider: OfflineODataProvider, requestDidFail request: OfflineODataFailedRequest ) -> Void {
    print( "requestFailed: \(request.httpStatusCode)" )
  }

  /// The OfflineODataStoreState is a Swift OptionSet. Use the set operation to retrieve each setting.
  private func storeState2String( _ state: OfflineODataStoreState ) -> String {
    var result: String = ""

    if state.contains(.opening) {
      result += ":opening"
    }

    if state.contains(.open) {
      result += ":open"
    }

    if state.contains(.closed) {
      result += ":closed"
    }

    if state.contains(.downloading) {
      result += ":downloading"
    }

    if state.contains(.uploading) {
      result += ":uploading"
    }

    if state.contains(.initializing) {
      result += ":initializing"
    }

    if state.contains(.fileDownloading) {
      result += ":fileDownloading"
    }

    if state.contains(.initialCommunication) {
      result += ":initialCommunication"
    }

    return result
  }

  public func offlineODataProvider( _ provider: OfflineODataProvider, stateDidChange newState: OfflineODataStoreState ) -> Void {
    let stateString = storeState2String(newState)
    print( "Offline Data Provider state changed: \( stateString )" )
  }
}
