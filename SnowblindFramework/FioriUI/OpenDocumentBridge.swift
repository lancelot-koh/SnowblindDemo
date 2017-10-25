//
//  OpenDocumentBridge.swift
//  SAPMDC
//
//  Copyright © 2017 SAP. All rights reserved.
//

import QuickLook

@objc (OpenDocumentSwift)
public class OpenDocument: NSObject {

  @objc public static func open(path: String, resolve: @escaping SnowblindPromiseResolveBlock,
                                reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    print ("trying to open document at: " + path)

    let qlPreviewController = OpaqueBarQLPreviewController()
    let previewController = PreviewController (path: path)

    qlPreviewController.dataSource = previewController
    qlPreviewController.delegate = previewController
    qlPreviewController.reloadData()

    let previewItem = previewController.previewController(qlPreviewController, previewItemAt: 0)
    if let topMostViewController: UIViewController = UIApplication.shared.keyWindow?.rootViewController {
      if QLPreviewController.canPreview(previewItem) {
        topMostViewController.show(qlPreviewController, sender: nil)
        resolve(nil)
      } else {
        reject(nil, "failed to preview item at the following path: " + path, nil)
      }
    }
  }
}

/**
 * SNOWBLIND-4622
 * Issue: Document viewer page is showing the navigation bar in transparent mode.
 * To fix the issue, we can add a sub class from QLPreviewController to override the viewWillAppear function
 * and set the isTranslucent property of navigationBar.
 * The sub class can be used to override other functions of QLPreviewController as well.
 * i.e. to recognize touchesBegan and modify other properties of QLPreviewController
 */
class OpaqueBarQLPreviewController: QLPreviewController {

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isTranslucent = false
  }
}

private class PreviewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {

  private var resourcePath: String = ""
  private let resPrefix: String = "res://"

  public init () {
    super.init(nibName: nil, bundle: nil)
  }

  init (path: String) {
    self.resourcePath = path
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return 1
  }

  public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    var urlPath: NSURL = NSURL()
    guard resourcePath.characters.count > 0 else { return urlPath }
    guard let ext: String = NSURL(fileURLWithPath: resourcePath).pathExtension else { return urlPath }
    let prefixLength = resourcePath.hasPrefix(resPrefix) ? resPrefix.characters.count : 0
    let extensionLength = ext.characters.count > 0 ? ext.characters.count + 1 : 0
    let range = resourcePath.index(resourcePath.startIndex, offsetBy: prefixLength)..<resourcePath.index(resourcePath.endIndex, offsetBy: -extensionLength)
    let trimmedPath = resourcePath.substring(with: range)
    if prefixLength > 0 && ext.characters.count > 0 {
      if let tempUrl = Bundle.main.url(forResource: trimmedPath, withExtension: ext) {
        urlPath = tempUrl as NSURL
      }
    } else {
      urlPath = NSURL(fileURLWithPath: resourcePath, isDirectory: false)
    }

    return urlPath
  }
}
