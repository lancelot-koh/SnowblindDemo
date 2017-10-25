//
//  ObjectCell.swift
//  SAPMDCFramework
//
//  Created by Mehta, Kunal on 10/19/16.
//  Copyright © 2016 SAP. All rights reserved.
//

import Foundation
import SAPFiori
import UIKit

@objc (ObjectCellSwift)
public class ObjectCell: NSObject {
  enum IndicatorStates: String {
    case toDownload
    case inProgress
    case open
  }

  /// Creates an Object Cell from SAP SDK SAPFiori
  ///
  /// - returns: ObjectTableViewCell
  @objc public static func create() -> UITableViewCell {
    return SAPFiori.FUIObjectTableViewCell()
  }

  /// Populates an object cell with properties passed in params
  ///
  /// - parameter params: Dictionary containing keys as per metadata defintion
  ///   for ListObjectCell
  ///   (https://github.wdf.sap.corp/snowblind/metadata/blob/master/Definition%20Description/Pages/Controls/ListControl.md)
  ///   In addition, params also passes the cell to be updated in the "cell" key.
  @objc public static func populate(params: NSDictionary) {
    print(params)
    if let cell = params["cell"] as? SAPFiori.FUIObjectTableViewCell {
      configureObjectCell(cell: cell, params: params)
      cell.autoresizingMask = [.flexibleWidth]
    }
  }
  // swiftlint:disable:next cyclomatic_complexity
  public static func configureObjectCell(cell: SAPFiori.FUIObjectTableViewCell, params: NSDictionary) {
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
      if let isCircular = params["DetailImageIsCircular"] as? Bool {
        cell.detailImageView.isCircular = isCircular
      } else {
        //set image view to be circular by default
        cell.detailImageView.isCircular = false
      }
    }

    if let descriptionText = params["Description"] {
      cell.descriptionText = String(describing: descriptionText)
    }

    if let state = params["ProgressIndicator"] as? String {
      setIndicatorState(cell: cell, indicatorState: state)
    } else {
      if let accessoryTypeParam = params["AccessoryType"] as? String {
        cell.accessoryType = accessoryType(from: accessoryTypeParam)
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
      if let descriptionStyle = styles["Description"] {
        cell.descriptionLabel.nuiClass = String(describing: descriptionStyle)
      }
    }
    setStatus(cell: cell, params: params)
    setSubStatus(cell: cell, params: params)

    if let icons = params["Icons"] as? NSArray {
      for icon in icons {
        cell.iconImages.append(ImagePathHandler.image(from: (icon as? String)!)!)
      }
    }
    cell.preserveIconStackSpacing = true
    if let shouldPreserveSpacing = params["PreserveIconStackSpacing"] as? Bool {
      cell.preserveIconStackSpacing = shouldPreserveSpacing
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
  static func setStatus(cell: SAPFiori.FUIObjectTableViewCell, params: NSDictionary) {
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
  static func setSubStatus(cell: SAPFiori.FUIObjectTableViewCell, params: NSDictionary) {
    if let substatusImage = params["SubstatusImage"] as? String, let uiImage = ImagePathHandler.image(from: substatusImage) {
      cell.substatusImage = uiImage
    } else if let text = params["SubstatusText"] {
      cell.substatusText = String(describing: text)
    }
  }

  /// Sets the progress indicator's state for the given cell and binds the section and cell to the indicator
  ///
  /// - parameter cell:   cell to be configured with a progress indicator
  /// - parameter indicatorState: IndicatorStates the indicator's state
  /// - parameter section:   section which contains the configured cell
  static func setIndicatorState(cell: SAPFiori.FUIObjectTableViewCell, indicatorState: String) {
    if let state = IndicatorStates(rawValue: indicatorState) {
      switch state {
      case .toDownload:
        let image = ImagePathHandler.image(from: "res://downloadIcon.png")
        let imageView = UIImageView(image: image)
        cell.accessoryView = imageView
      case .inProgress:
        let progressIndicator = FUIProgressIndicatorControl (frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        progressIndicator.changeDisplayState(to: .inProgress)
        cell.accessoryView = progressIndicator
      case .open:
        let image = ImagePathHandler.image(from: "res://openDocumentIcon.png")
        let imageView = UIImageView(image: image)
        cell.accessoryView = imageView
      }
    }
  }
}
