//
//  FUIButtonWrapper.swift
//  SAPMDC
//
//  Copyright © 2017. SAP. All rights reserved.
//

import Foundation
import SAPFiori

/**
 Subclass of `FUIButton` to store additional information, which are needed to carry out the touch event.
 */
public class FUIButtonWrapper: FUIButton {
  enum ContentAlignment: String {
    case center
    case left
    case right
  }

  public var cellRow: Int
  public var containerCell: FUIBaseTableViewCell
  private let defaultSideMargin: CGFloat = 48.0

  init(row: Int, containerCell: FUIBaseTableViewCell) {
    cellRow = row
    self.containerCell = containerCell
    super.init(frame: containerCell.contentView.frame)
    self.tag = FUIButtonWrapper.FUIButtonWrapperTag
  }

  /// Reuse identifier
  public static var reuseIdentifier: String {
    return "\(String(describing: self))"
  }

  public static var FUIButtonWrapperTag: Int {
    return 01261986
  }

  /// Configures the button with the provided metadata
  public func configure(withMetadata metadata: Dictionary<String, Any>) {
    self.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    for (key, value) in metadata {
      switch key {
      case "Title":
        self.setTitle(value as? String, for: UIControlState.normal)
        self.setTitleColor(UIColor(hexString: "#5D88AF"), for: UIControlState.normal)
        self.setTitleColor(.gray, for: .disabled)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        break
      case "TextAlignment":
        setContentAlignmentFromString(alignment: value as? String)
        break
      case "Enabled":
        self.isEnabled = (value as? Bool)!
        break
      default:
        break
      }
    }

    if let buttonStyle = metadata["Style"] as? String {
      self.nuiClass = buttonStyle
    } else {
      // Styling: From documentation, the nss file can contain this nui class
      // in order to override the buttons default style in sections
      self.nuiClass = "ButtonSectionStyle"
    }
  }

  static func alignmentFromString(alignment: String?) -> ContentAlignment {
    if let position = alignment, let titleAlignment = ContentAlignment(rawValue: position) {
      switch titleAlignment {
      case .center:
        return .center
      case .left:
        return .left
      case .right:
        return .right
      }
    }
    // set the default alignment to center
    return .center
  }

  /// Sets the button title alignment to one of the following: center, left, right
  /// If the parameter is invalid, the default position is: center
  ///
  /// - parameter alignment: The title's alignment
  private func setContentAlignmentFromString(alignment: String?) {
    // use the same margins as other cells
    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: defaultSideMargin, bottom: 0, right: defaultSideMargin)
    let contentAlignment = FUIButtonWrapper.alignmentFromString(alignment: alignment)
    // convert ContentAlignment to UIControlContentHorizontalAlignment
    switch contentAlignment {
    case .center:
      self.contentHorizontalAlignment = .center
      break
    case .left:
      self.contentHorizontalAlignment = .left
      break
    case .right:
      self.contentHorizontalAlignment = .right
      break
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
