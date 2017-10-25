//
//  WelcomePageDelegate.swift
//  SnowblindDemo
//
//  Created by Gao, Yong on 18/10/17.
//  Copyright © 2017 sap. All rights reserved.
//

import UIKit
import SAPMDC

class WelcomePageDelegate: WelcomeScreenDelegate {
    var controller : UIViewController?
    var toastBridge: ToastMessageViewBridge!
    
    init(_ controller: UIViewController) {
        self.controller = controller
        self.toastBridge = ToastMessageViewBridge()
    }
    
    
    @objc public func setOnboardingStage() {
        print("setOnboardingStage")
    }
    
    
    @objc public override func loginTapped() {
        print("loginTapped")
    }
    
    // process finishedOnboardingWithParams event
    @objc public func finishedOnboardingWithParams() {
        print("finishedOnboarding 2")
        // restore navigationbar
        
        let vc = self.controller?.childViewControllers.last
        vc?.willMove(toParentViewController: nil)
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
        self.controller?.navigationController?.isNavigationBarHidden = false
        
        let message: [String: String] = ["message": "Onboarding successfully"]
        self.toastBridge.displayToastMessage(message)

        
    }
}
