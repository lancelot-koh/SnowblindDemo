//
//  EmptySectionTableViewCell.swift
//  SAPMDC
//
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori

class EmptySectionTableViewCell: FUIBaseTableViewCell {

  open static var reuseIdentifier: String {
    return "\(String(describing: self))"
  }

  let captionLabel = FUILabel()

  override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override open func prepareForReuse() {
    setup()
  }

  func setup() {

    // This cell can't be selected
    self.selectionStyle = .none
    self.isUserInteractionEnabled = false

    // Setup the label
    self.captionLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.captionLabel)

    // This is the default style from Global Design
    self.captionLabel.font = UIFont.preferredFont(forTextStyle: .body)
    self.captionLabel.textColor = UIColor.preferredFioriColor(forStyle: .primary1)

    // But the style can also be overriden through the NSS styling mechanism via this class
    self.captionLabel.nuiClass = "EmptySectionCaptionStyle"

    // Horizontally, the emptySectionLabel spans the entire view
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[emptySectionLabel]-|",
                                                                options: NSLayoutFormatOptions.init(rawValue: 0),
                                                                metrics: nil,
                                                                  views: ["emptySectionLabel": self.captionLabel]))

    // Vertically, the emptySectionLabel spans the entire view,
    // and it has a height of 44.5
    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[emptySectionLabel(44.5)]|",
                                                                options: NSLayoutFormatOptions.init(rawValue: 0),
                                                                metrics: nil,
                                                                  views: ["emptySectionLabel": self.captionLabel]))

    // No separators
    self.separators = []
  }
}
