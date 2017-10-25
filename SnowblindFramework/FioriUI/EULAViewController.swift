//
//  EULAViewController.swift
//  SAPMDCFramework
//
//  Created by Rafay, Muhammad on 3/2/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit

protocol EULADelagate: class {
  func EULAAnswer(agreed: Bool, fromController controller: EULAViewController)
}
let seamBundle = Bundle(identifier: "com.sap.SAPMDC")

public class EULAViewController: UIViewController {
  var eulaDelegate: EULADelagate?

  @IBOutlet weak var disagreeBtn: UIBarButtonItem!
  @IBOutlet weak var agreeBtn: UIBarButtonItem!
  @IBOutlet weak var eulaTextView: UITextView!

  @IBAction func disagree(_ sender: Any) {
    self.eulaDelegate?.EULAAnswer(agreed: false, fromController: self)
  }
  @IBAction func agree(_ sender: Any) {
    eulaDelegate?.EULAAnswer(agreed: true, fromController: self)
  }
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    self.agreeBtn.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.preferredFioriColor(forStyle: .tintColor)], for: .normal)
    self.disagreeBtn.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.preferredFioriColor(forStyle: .tintColor)], for: .normal)
    self.navigationItem.setHidesBackButton(true, animated: false)
    self.navigationController?.navigationBar.barTintColor = UIColor.preferredFioriColor(forStyle: .navigationBar)
    self.navigationController?.navigationBar.isTranslucent = false
  }
}
