//
//  MyPasscodeInputScreenDelegate.swift
//  SnowblindDemo
//
//  Created by Gao, Yong on 24/10/17.
//  Copyright © 2017 sap. All rights reserved.
//

import UIKit
import SAPMDC

class MyPasscodeInputScreenDelegate: PasscodeInputScreenDelegate {
    var controller : UIViewController?
    var toastBridge: ToastMessageViewBridge!
    init(_ controller: UIViewController) {
        self.controller = controller
        self.toastBridge = ToastMessageViewBridge()
    }
    func didConfirmPasscode() {
        print("didConfirmPasscode")
    }
    
    @objc override func setOnboardingStage(_ stage: String) {
        print("setOnboardingStage:\(stage)")
        //if let stage == ""
    }
    
    @objc func setOnboardingStage() {
        print("setOnboardingStage 2")
    }
    
    @objc func finishedOnboardingWithParams() {
        print("finishedOnboardingWithParams")
        let vc = self.controller?.childViewControllers.last
        vc?.willMove(toParentViewController: nil)
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
        self.controller?.navigationController?.isNavigationBarHidden = false
        
        let message: [String: String] = ["message": " Welcome Back"]
        self.toastBridge.displayToastMessage(message)
    }
    
}
