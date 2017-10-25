//
//  HelpSectionFooterView.swift
//  SAPMDC
//
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori

class HelpSectionFooterView: UITableViewHeaderFooterView {

  open static var reuseIdentifier: String {
    return "\(String(describing: self))"
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override public init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }

  private let helpLabel = FUILabel()
  private var bottomPaddingConstraint: NSLayoutConstraint!

  public var text: String = "" {
    didSet {
      self.helpLabel.text = text
    }
  }

  public var bottomPadding: CGFloat = 0 {
    didSet {
      self.bottomPaddingConstraint.constant = self.bottomPadding
      self.setNeedsUpdateConstraints()
    }
  }

  func setup() {

    // Setup the help label
    self.helpLabel.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.addSubview(self.helpLabel)

    // This is the default style from Global Design
    self.helpLabel.textColor = UIColor.preferredFioriColor(forStyle: .primary2)
    self.helpLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    self.helpLabel.textAlignment = .center

    // But the style can also be overriden through the NSS styling mechanism via this class
    self.helpLabel.nuiClass = "HelpSectionFooterView"

    // Horizontally, the helpLabel spans the entire view
    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[helpLabel]|",
      options: NSLayoutFormatOptions.init(rawValue: 0),
      metrics: nil,
      views: ["helpLabel": self.helpLabel]))

    // Vertically, on the top, we are anchored to the view
    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[helpLabel]",
      options: NSLayoutFormatOptions.init(rawValue: 0),
      metrics: nil,
      views: ["helpLabel": self.helpLabel]))

    // Vertically, on the bottom, we are separated by a configurable padding
    self.bottomPaddingConstraint = NSLayoutConstraint(item: self.contentView, attribute: .bottom,
      relatedBy: .equal,
      toItem: self.helpLabel, attribute: .bottom,
      multiplier: 1, constant: self.bottomPadding)
    self.contentView.addConstraint(self.bottomPaddingConstraint)
  }
}
