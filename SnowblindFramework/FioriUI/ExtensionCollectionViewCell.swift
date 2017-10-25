//
//  ExtensionCollectionViewCell.swift
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 4/27/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation

class ExtensionCollectionViewCell: UICollectionViewCell {
  open static var reuseIdentifier: String {
    return "ExtensionCollectionViewCell"
  }

  public static var ExtensionCollectionViewTag: Int {
    return 06092010
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func setupView(view: UIView) {
    // SNOWBLIND-4547: iOS 11 made changes to auto layouts.  If we are on iOS 11 or above, we need to turn this off
    // so margins outside the "safe area" are not automatically modified.
    if #available(iOS 11.0, *) {
      self.contentView.insetsLayoutMarginsFromSafeArea = false
      view.insetsLayoutMarginsFromSafeArea = false
    }

    view.tag = ExtensionCollectionViewCell.ExtensionCollectionViewTag
    // Remove existing view if there is one
    self.viewWithTag(ExtensionCollectionViewCell.ExtensionCollectionViewTag)?.removeFromSuperview()
    self.addSubview(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    view.contentMode = .scaleAspectFill
  }
}
