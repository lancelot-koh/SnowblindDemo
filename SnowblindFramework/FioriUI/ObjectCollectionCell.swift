//
//  ObjectCollectionCell.swift
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/17/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPFiori

class ObjectCollectionCell {

  // swiftlint:disable cyclomatic_complexity
  public static func configureObjectCollectionCell(cell: FUIObjectCollectionViewCell, params: NSDictionary) {

    if let title = params["Title"] {
      cell.headlineText = String(describing: title)
    }
    if let subhead = params["Subhead"] {
      cell.subheadlineText = String(describing: subhead)
    }
    if let footnote = params["Footnote"] {
      cell.footnoteText = String(describing: footnote)
    }
    if let detailImage = params["DetailImage"] as? String, let uiImage = ImagePathHandler.image(from: detailImage) {
      cell.detailImage = FUIImageView(image: uiImage).image
      //set image view to be circular
      if let isCircular = params["DetailImageIsCircular"] as? Bool {
        cell.detailImageView.isCircular = isCircular
      } else {
        //set image view to be circular by default
        cell.detailImageView.isCircular = false
      }
    }

    setAccessoryType(cell: cell, params: params)
    setStatus(cell: cell, params: params)
    setSubStatus(cell: cell, params: params)

    if let icons = params["Icons"] as? NSArray {
      for icon in icons {
        cell.iconImages.append(ImagePathHandler.image(from: (icon as? String)!)!)
      }
    }

    if let styles = params["Styles"] as? NSDictionary {
      if let footnoteStyle = styles["Footnote"] {
        cell.footnoteLabel.nuiClass = String(describing: footnoteStyle)
      }
      if let statusStyle = styles["StatusText"] {
        cell.statusLabel.nuiClass = String(describing: statusStyle)
      }
      if let subheadStyle = styles["Subhead"] {
        cell.subheadlineLabel.nuiClass = String(describing: subheadStyle)
      }
      if let substatusStyle = styles["SubstatusText"] {
        cell.substatusLabel.nuiClass = String(describing: substatusStyle)
      }
      if let titleStyle = styles["Title"] {
        cell.headlineLabel.nuiClass = String(describing: titleStyle)
      }
    }
  }

  /// Converts string type to UITableViewCellAccessoryType
  ///
  /// - parameter type: String type
  ///
  /// - returns: UITableViewCellAccessoryType
  static func accessoryType(from type: String) -> UITableViewCellAccessoryType {
    switch type {
    case "checkmark": return UITableViewCellAccessoryType.checkmark
    case "detailButton": return UITableViewCellAccessoryType.detailButton
    case "detailDisclosureButton": return UITableViewCellAccessoryType.detailDisclosureButton
    case "disclosureIndicator": return UITableViewCellAccessoryType.disclosureIndicator
    default: return UITableViewCellAccessoryType.none
    }
  }

  /// Sets cell's status properties
  ///
  /// - parameter cell:   cell to be updated
  /// - parameter params: params containing status values
  public static func setStatus(cell: FUIObjectCollectionViewCell, params: NSDictionary) {
    if let statusImage = params["StatusImage"] as? String, let uiImage = ImagePathHandler.image(from: statusImage) {
      cell.statusImage = uiImage
    } else if let text = params["StatusText"] {
      cell.statusText = String(describing: text)
    }
  }

  /// Sets cell's subStatus properties
  ///
  /// - parameter cell:   cell to be updated
  /// - parameter params: params containing substatus values
  public static func setSubStatus(cell: FUIObjectCollectionViewCell, params: NSDictionary) {
    if let substatusImage = params["SubstatusImage"] as? String, let uiImage = ImagePathHandler.image(from: substatusImage) {
      cell.substatusImage = uiImage
    } else if let text = params["SubstatusText"] {
      cell.substatusText = String(describing: text)
    }
  }

  public static func setAccessoryType(cell: FUIObjectCollectionViewCell, params: NSDictionary) {
    cell.accessoryType = UITableViewCellAccessoryType.none
    if let accessoryTypeParam = params["AccessoryType"] as? String {
      cell.accessoryType = accessoryType(from: accessoryTypeParam)
    }
  }
}
