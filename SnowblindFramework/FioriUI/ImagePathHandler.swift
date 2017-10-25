//
//  ImagePathHandler.swift
//  SAPMDCFramework
//
//  Copyright © 2017. SAP. All rights reserved.
//

import Foundation

/// A helper class for creating UIImage from an image string
public class ImagePathHandler {
  public static let BASE64PREFIX = "data:image"
  public static let PDFPREFIX = "data:application/pdf"
  public static let RESOURCEPREFIX = "res://"
  public static let WEBPREFIX = "http://"

  /// Returns a UIImage from input string which could be a base64 encoded string, resource or web reference
  ///
  /// - parameter imageString: image reference string
  ///
  /// - returns: UIImage
  public static func image(from imageString: String) -> UIImage? {
    if imageString.isEmpty {
      // file path not provided
      return nil
    }
    if imageString.range(of: PDFPREFIX) != nil {
      // pdf file is in the metadata
      return imageFromPdfString(imageString)
    } else if imageString.range(of: BASE64PREFIX) != nil {
      // file is in the metadata
      return imageFromBase64String(imageString)
    } else if imageString.range(of: RESOURCEPREFIX) != nil {
      // file is in the main bundle
      return imageFromResource(imageString)
    } else if imageString.range(of: WEBPREFIX) != nil {
      return imageFromWeb(imageString)
    } else {
      // file is in the sandbox
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: imageString) {
        return UIImage(contentsOfFile: imageString)
      } else {
        // file not found
        return nil
      }
    }
  }

  /// Returns UIImage from pdf format base64String
  ///
  /// - parameter imageString: base64 encoded string
  ///
  /// - returns: UIIMage
 private static func imageFromPdfString(_ imageString: String) -> UIImage? {
    // remove data:image/png;base64,
    let c = imageString.characters
    if let comma = c.index(of: ",") {
      let base64String = imageString[c.index(after: comma)..<imageString.endIndex]
      let data = NSData(base64Encoded: String(base64String))
      let provider: CGDataProvider = CGDataProvider(data: data!)!
      let pdfDoc: CGPDFDocument = CGPDFDocument(provider)!
      //pageCount = pdfDoc.numberOfPages;
      let pdfPage: CGPDFPage = pdfDoc.page(at: 1)!
      let pageRect: CGRect = pdfPage.getBoxRect(.mediaBox)
      let contextSize: CGSize = CGSize(width: pageRect.size.width * 3, height: pageRect.size.height * 3)
      UIGraphicsBeginImageContext(contextSize)
      let context: CGContext = UIGraphicsGetCurrentContext()!
      context.saveGState()
      context.translateBy(x: 0.0, y: pageRect.size.height * 3)
      context.scaleBy(x: 3.0, y: -3.0)
      context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
      context.drawPDFPage(pdfPage)
      context.restoreGState()
      let pdfImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      return pdfImage
    }
    return nil
  }

  /// Returns UIImage from base64String
  ///
  /// - parameter imageString: base64 encoded string
  ///
  /// - returns: UIIMage
  private static func imageFromBase64String(_ imageString: String) -> UIImage? {
    // remove data:image/png;base64,
    let c = imageString.characters
    if let comma = c.index(of: ",") {
      let base64String = imageString[c.index(after: comma)..<imageString.endIndex]
      if let data = Data(base64Encoded: String(base64String)), let decodedimage: UIImage = UIImage(data: data) {
        return decodedimage
      }
    }
    return nil
  }

  /// Returns UIImage from an app resource file
  ///
  /// - parameter imageString: resource file name
  ///
  /// - returns: UIImage
  private static func imageFromResource(_ imageString: String) -> UIImage? {
    let range = imageString.index(imageString.startIndex,
                                  offsetBy: RESOURCEPREFIX.characters.count)..<imageString.endIndex
    return UIImage(named: String(imageString[range]))
  }

  /// Returns UIImage from a web url (http://)
  ///
  /// - parameter imageString: url
  ///
  /// - returns: UIImage
  private static func imageFromWeb(_ imageString: String) -> UIImage? {
    let range = imageString.index(imageString.startIndex,
                                  offsetBy: WEBPREFIX.characters.count)..<imageString.endIndex
    return UIImage(named: String(imageString[range]))
  }
}
