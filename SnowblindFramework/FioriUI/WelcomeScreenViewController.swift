//
//  WelcomeScreenViewController.swift
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 2/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import UIKit
import SAPFiori
import SAPFoundation

extension UINavigationController {
  public func pushViewController(viewController: UIViewController,
                                 animated: Bool,
                                 completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}
public class WelcomeScreenViewController: UINavigationController, EULADelagate, PasscodeCustomDelegate, FUIWelcomeControllerDelegate {
  public var params: NSDictionary?
  public var callback: WelcomeScreenDelegate?
  private var fuiWelcomeController = FUIWelcomeScreen.createInstanceFromStoryboard()
  let passcodeScreen: PasscodeViewController? = PasscodeViewController()
  let eulaScreen: EULAViewController? = EULAViewController()

  // MARK: Objective-C Methods
  @objc public func initialize(_ params: NSDictionary, callback: WelcomeScreenDelegate) {
    AppConfig.sharedInstance.isOnboarding = true
    self.params = params
    self.callback = callback
    self.storePasscodePolicy()
    self.getDemodataFlag()
  }

  // MARK: Swift Methods
  public override func viewDidLoad() {
    super.viewDidLoad()
    // Register to receive notification in your class
    NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    self.navigationItem.setHidesBackButton(true, animated: false)
    eulaScreen?.eulaDelegate = self
    passcodeScreen?.passcodeDelegate = self
    self.showWelcomeScreen()
  }

  public override func viewWillAppear(_ animated: Bool) {
    self.setOnboardingStage(to: "Welcome")
    // Welcome Screen's view should be within the screen size.
    // Before displaying the welcome screen, check if WelcomeScreenViewController's view
    // was extended over the screen height. If yes, correct it to be the same as screen
    // height. Fix for [SNOWBLIND-5098].
    if self.view.frame.size.height > UIScreen.main.bounds.size.height {
      self.view.frame.size.height = UIScreen.main.bounds.size.height
    }
  }

  // Called from {N} side whenever the app launches or returns to foreground.
  // If all connection settings are available (from a launching URL or branded settings) the button is visible.
  // If a valid bundle definition is present, display the demo section
  @objc public static func update(_ params: NSDictionary) {
    if let VC = params["WelcomeScreen"] as? WelcomeScreenViewController {
      // swiftlint:disable force_cast
      VC.fuiWelcomeController.primaryActionButton.isHidden = !(params["IsActivateButtonVisible"] as! Bool)
      // swiftlint:disable force_cast
      VC.fuiWelcomeController.isDemoAvailable = (params["IsDemoAvailable"] as! Bool)
    }
  }

  private func configureWelcomeScreen(_ screen: FUIWelcomeScreen) {
    if let headlineLabelText = params?["AppNameLabel"] as? String {
      screen.headlineLabel.text = headlineLabelText
    }
    if let thankyouLabelText = params?.value(forKey: "welcomeDetailLabel") as? String {
      screen.footnoteLabel.text = thankyouLabelText
    }
    if let demoLabelText = params?["DemoLabel"] as? String {
      screen.footnoteLabel.text = demoLabelText
    }
    if let detailLabelTextViewText = params?["DetailLabelViewText"] as? String, !detailLabelTextViewText.isEmpty {
      screen.detailLabel.text = detailLabelTextViewText
    }
    if let signInButtonText = params?["SigninButtonText"] as? String {
      screen.primaryActionButton.setTitle(signInButtonText, for: .normal)
    }
    if let demoButtonText = params?["DemoButtonText"] as? String {
      screen.footnoteActionButton.setTitle(demoButtonText, for: .normal)
    }
    if let isDemoAvailable = params?["IsDemoAvailable"] as? Bool {
      screen.isDemoAvailable = isDemoAvailable
    }
  }

  // MARK: Welcome Screen Methods
  private func showWelcomeScreen() {
    // Set the state of controller first, else some welcome screen settings may be ignored by Fiori.
    self.fuiWelcomeController.state = .isConfigured
    self.configureWelcomeScreen(self.fuiWelcomeController)
    self.fuiWelcomeController.delegate = self
    self.viewControllers.insert(self.fuiWelcomeController, at: 0)
  }

  // MARK: Onboading Delegate
  public func shouldContinueUserOnboarding(_ welcomeController: FUIWelcomeController) {
    // While authenticating with the server, indicate to the user that the client is doing
    // something by dimming the view controller.
    self.setViewForLoading(withAlpha: 0.5, isInteractionEnabled: false)
    if OAuthRequestor.sharedInstance.authenticator == nil {
      // This is to cover an edge case:
      //  Overrides.json settings file was used to onboard and it gets nuked just before user logs out. Trying to onboard again,
      //  should read settings from BrandedSettings now.
      //  The TS side will recreate the OAuthRequestor and if it is not initialized, do it here.
      OAuthRequestor.sharedInstance.initialize(params: self.params!)
    }
    OAuthRequestor.sharedInstance.triggerOAuth(success: self.didFinishLoginWithSuccess, failure: {
      BannerMessageView.displayBannerMsg(params: ["message": "Authentication failed. Please try again",
                                                  "navigationController": self])
      self.didFinishLoginWithError()
    })
    self.setOnboardingStage(to: "CloudLogin")
  }

  // Allows the screen to be dimmed and disabled.
  private func setViewForLoading(withAlpha: CGFloat, isInteractionEnabled: Bool) {
    DispatchQueue.main.async {
      self.fuiWelcomeController.view.alpha = withAlpha
      self.fuiWelcomeController.view.isUserInteractionEnabled = isInteractionEnabled
    }
  }

  public func didSelectDemoMode(_ welcomeController: FUIWelcomeController) {
    AppConfig.sharedInstance.isOnboarding = false
    var data = [String: Any]()
    data["OfflineKey"] = DataServiceUtils.generateOfflineStoreEncryptionKey()
    // temp hardcoded for now
    data["Passcode"] = "1234"
    self.setOnboardingStage(to: "InAppFromDemo")
    self.callback!.perform(NSSelectorFromString("finishedOnboardingWithParams"), with: data)
  }

  // MARK: Cloud Login Delegate
  public func didFinishLoginWithSuccess() {
    self.setViewForLoading(withAlpha: 1.0, isInteractionEnabled: true)
    self.showEULA()
  }

  public func didFinishLoginWithError() {
    self.setViewForLoading(withAlpha: 1.0, isInteractionEnabled: true)
    //Handle Error
  }

  // MARK: EULA Custom Delegate
  public func EULAAnswer(agreed: Bool, fromController controller: EULAViewController) {
    if agreed {
      if let passcodeController = self.passcodeScreen?.createPasscodeScreen() {
        self.navigationController?.pushViewController(viewController: passcodeController, animated: true, completion: {
          self.setOnboardingStage(to: "Passcode")
        })
      }
    } else {
      _ = controller.navigationController?.popToRootViewController(animated: true)
    }
  }

  public func showEULA() {
    let onboardingStoryboard = UIStoryboard(name: "EULA", bundle: Bundle(identifier: "com.sap.SAPMDC"))
    let onboardingController = onboardingStoryboard.instantiateViewController(withIdentifier: "EULA") as! EULAViewController //swiftlint:disable:this force_cast
    onboardingController.eulaDelegate = self
    DispatchQueue.main.sync {
      self.navigationController?.isNavigationBarHidden = false
      self.navigationController?.pushViewController(viewController: onboardingController, animated: true, completion: {
        self.setOnboardingStage(to: "EULA")
      })
    }
  }

  // MARK: Passcode Custom Delegate
  public func didConfirmPasscode() {
    // User has completed onboarding, get him a OfflinestoreEncryptionKey and send it away to
    // be stored in secure vault by {N}. The secure store AKA secure vault opens with his passcode.
    // A FSM is maintained in {N} to check for app status (Onboarding or not) that persists even if
    // app exits and is relaunched.
    if !AppConfig.sharedInstance.encryptDatabase {
      // If key is false then we will not encrypt the database
      AppConfig.sharedInstance.data["OfflineKey"] = ""
    } else {
      // If key is true or undefined then we will encrypt the database
      AppConfig.sharedInstance.data["OfflineKey"] = AppConfig.sharedInstance.isOnboarding ? DataServiceUtils.generateOfflineStoreEncryptionKey() : "unused"
    }
    AppConfig.sharedInstance.data["OAuth2Token"] = AppConfig.sharedInstance.oauth2Token
    AppConfig.sharedInstance.data["Passcode"] = AppConfig.sharedInstance.passCode
    AppConfig.sharedInstance.data["PasscodeSource"] = AppConfig.sharedInstance.passcodeSource
    self.setOnboardingStage(to: "InApplication")
    if let callback = self.callback {
      callback.perform(NSSelectorFromString("finishedOnboardingWithParams"), with: AppConfig.sharedInstance.data)
    } else {
      print("Callback is nil")
    }
    AppConfig.sharedInstance.isOnboarding = false
  }
  // MARK: Utility methods
  private func setOnboardingStage(to stage: String) {
    if let callback = self.callback {
      callback.perform(NSSelectorFromString("setOnboardingStage"), with: stage)
    }
  }

  @objc private func deviceOrientationDidChange(_ notification: NSNotification) {
    // no-op
    // A temp fix so we can deal with orientation change on welcome screen.  Without this no-op method
    // the welcome screen loses the description text when we rotate.
  }
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
  }
  // MARK: Branding Methods
  private func storePasscodePolicy() {
    if let passCodePolicySettings = self.params?["PasscodePolicySettings"] as? [String:Any] {
      AppConfig.sharedInstance.passcodePolicySettings = passCodePolicySettings
    }
  }
  private func getDemodataFlag() {
    if let isEncryptedDatabase = self.params?["EncryptDatabase"] as? Bool {
      AppConfig.sharedInstance.encryptDatabase = isEncryptedDatabase
    }
  }
}
