//
//  ObjectHeaderViewController.swift
//  SAPMDCFramework
//
//  Copyright © 2017. SAP. All rights reserved.
//

import UIKit
import SAPFiori
import Foundation

@objc
public class ObjectHeader: NSObject {

  // swiftlint:disable identifier_name
  enum ObjectHeaderProperties: String {
    case DetailImage
    case DetailImageIsCircular
    case HeadlineText
    case Subhead
    case Tags
    case BodyText
    case Footnote
    case Description
    case StatusText
    case StatusImage
    case SubstatusImage
    case SubstatusText
    case DetailContentContainer
  }

  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable force_cast
  // swiftlint:disable function_body_length
  public static func setObjectHeader(_ objectHeader: FUIObjectHeader, withParams params: Dictionary<String, Any>) {
    //set image view to not be circular by default
    objectHeader.detailImageView.isCircular = false
    for (key, value) in params {
      if let objectHeaderProperty = ObjectHeaderProperties(rawValue: key) {
        switch objectHeaderProperty {
        case .DetailImage:
          if let image = ImagePathHandler.image(from: value as! String) {
            objectHeader.detailImage = image
          }
        case .DetailImageIsCircular:
          if let value = value as? Bool {
            objectHeader.detailImageView.isCircular = value
          }
        case .HeadlineText:
          objectHeader.headlineText = String(describing: value)
        case .Subhead:
          objectHeader.subheadlineText = String(describing: value)
        case .Tags:
          if let tags = value as? [String] {
            var objectHeaderTags: [SAPFiori.FUITag] = []
            for tag in tags {
                objectHeaderTags.append(SAPFiori.FUITag(title: tag))
            }
            objectHeader.tags = objectHeaderTags
          }
        case .BodyText:
          objectHeader.bodyText = String(describing: value)
        case .Footnote:
          objectHeader.footnoteText = String(describing: value)
        case .Description:
          objectHeader.descriptionText = String(describing: value)
        case .StatusText:
          objectHeader.statusText = String(describing: value)
        case .StatusImage:
          if let image = ImagePathHandler.image(from: value as! String) {
            objectHeader.statusImage = image
          }
        case .SubstatusImage:
          if let image = ImagePathHandler.image(from: value as! String) {
            objectHeader.substatusImage = image
          }
        case .SubstatusText:
          objectHeader.substatusText = String(describing: value)
        case .DetailContentContainer:
          if let detailContainer = value as? UIView {
            objectHeader.detailContentView = detailContainer
            // SNOWBLIND-4547: iOS 11 made changes to auto layouts.  If we are on iOS 11 or above, we need to turn this off
            // so margins outside the "safe area" are not automatically modified.
            if #available(iOS 11.0, *) {
              objectHeader.detailContentView.insetsLayoutMarginsFromSafeArea = false
            }
          }
        }
      }
    }
  }
}
