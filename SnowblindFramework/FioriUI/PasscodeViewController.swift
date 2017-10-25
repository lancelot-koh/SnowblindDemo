//
//  PasscodeViewController.swift
//  SAPMDCFramework
//
//  Created by Rafay, Muhammad on 2/27/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPFiori
import SAPFoundation

protocol PasscodeCustomDelegate: class {
  func didConfirmPasscode()
}
extension String: Error {}
private var blurView: UIVisualEffectView?
private var isBlurred: Bool = false
public class PasscodeViewController: UINavigationController, FUIPasscodeControllerDelegate, FUIPasscodeValidationDelegate {

  let fioriUIKitBundle = Bundle(identifier: "com.sap.cp.sdk.ios.SAPFiori")
  var callback: PasscodeInputScreenDelegate?
  weak var passcodeDelegate: PasscodeCustomDelegate?

  public override func viewDidLoad() {
    super.viewDidLoad()
    // The reset button label to display instead of default when user makes a wrong passcode attempt.
    FUIPasscodeController.resetPasscodeButtonString = "Reset Client"
  }

  // swiftlint:disable:next function_body_length
  public func passcodePolicy() -> SAPFiori.FUIPasscodePolicy {
    var passcodePolicy = FUIPasscodePolicy()
    let passCodePolicySettings = AppConfig.sharedInstance.passcodePolicySettings as [String:Any]
    if passCodePolicySettings.count > 0 {
      if let passCodePolicyIsDigitsOnly = passCodePolicySettings["IsDigitsOnly"] {
        passcodePolicy.isDigitsOnly = (passCodePolicyIsDigitsOnly as? Bool)!
      } else {
        passcodePolicy.isDigitsOnly = true
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyMinLength = passCodePolicySettings["MinLength"] {
        passcodePolicy.minLength = (passCodePolicyMinLength as? Int)!
      } else {
        passcodePolicy.minLength = 4
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyHasLower = passCodePolicySettings["HasLower"] {
        passcodePolicy.hasLower = (passCodePolicyHasLower as? Bool)!
      } else {
        passcodePolicy.hasLower = false
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyHasUpper = passCodePolicySettings["HasUpper"] {
        passcodePolicy.hasUpper = (passCodePolicyHasUpper as? Bool)!
      } else {
        passcodePolicy.hasUpper = false
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyHasSpecial = passCodePolicySettings["HasSpecial"] {
        passcodePolicy.hasSpecial = (passCodePolicyHasSpecial as? Bool)!
      } else {
        passcodePolicy.hasSpecial = false
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyAllowsTouchID = passCodePolicySettings["AllowsTouchID"] {
        passcodePolicy.allowsTouchID = (passCodePolicyAllowsTouchID as? Bool)!
      } else {
        passcodePolicy.allowsTouchID = false
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyRetryLimit = passCodePolicySettings["RetryLimit"] {
        passcodePolicy.retryLimit = (passCodePolicyRetryLimit as? Int)!
      } else {
        passcodePolicy.retryLimit = 4
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyHasDigit = passCodePolicySettings["HasDigit"] {
        passcodePolicy.hasDigit = (passCodePolicyHasDigit as? Bool)!
      } else {
        passcodePolicy.hasDigit = false
        print("Warning: Using Default PasscodePolicy Values")
      }
      if let passCodePolicyMinUniqueChars = passCodePolicySettings["MinUniqueChars"] {
        passcodePolicy.minUniqueChars = (passCodePolicyMinUniqueChars as? Int)!
      } else {
        passcodePolicy.minUniqueChars = 1
        print("Warning: Using Default PasscodePolicy Values")
      }
    } else {
      passcodePolicy.isDigitsOnly = true
      passcodePolicy.minLength = 4
      passcodePolicy.hasLower = false
      passcodePolicy.hasUpper = false
      passcodePolicy.hasSpecial = false
      passcodePolicy.allowsTouchID = true
      passcodePolicy.retryLimit = 4
      passcodePolicy.hasDigit = false
      passcodePolicy.minUniqueChars = 1
      print("Warning: Using Default PasscodePolicy Values")
    }
    return passcodePolicy
  }

  // MARK: Passcode Input Screen Methods
  @objc public func showInputScreen(_ params: NSDictionary, callback: PasscodeInputScreenDelegate) {
    let currentVC = params["Page"] as? UIViewController
    self.callback = callback
    // Fetching Enum from {N}. It can be
    // 0. Add - Adding the blur screen
    // 1. Remove - Removing the blur screen
    // 2. Manage - Remove the blur screen if present and show passcode
    let manageBlurScreen = params["ManageBlurScreen"] as? NSNumber
    switch Int(truncating: manageBlurScreen!) {
    case 0:
      // Add
      if let currentVC = currentVC {
        self.addBlurScreen(currentVC: currentVC)
      }
      return
    case 1:
      // Remove
      self.removeBlur()
      return
    case 2:
      // Manage
      self.manageBlur()
    default:
      // During initial launch, we are passing -1 so that switch break into default and show passcode input
      break
    }
    let passcodeInputStoryboard = UIStoryboard(name: "FUIPasscodeInputController", bundle: Bundle(for: FUIPasscodeInputController.self))
    let inputController = passcodeInputStoryboard.instantiateViewController(withIdentifier: "PasscodeInputViewController")
    let passCodeInputController = inputController as! FUIPasscodeInputController //swiftlint:disable:this force_cast
    passCodeInputController.delegate = self
    self.addChildViewController(passCodeInputController)
    self.storePasscodePolicy(params)
    let navController = UINavigationController(rootViewController: passCodeInputController)
    navController.modalPresentationStyle = .overFullScreen
    // Checking if current view controller is modal or push.
    if (currentVC?.presentingViewController) != nil {
      currentVC?.present(navController, animated: false, completion: nil)
      self.setOnboardingStage(to: "Passcode")
    } else {
      currentVC?.navigationController?.present(navController, animated: false, completion: nil)
      self.setOnboardingStage(to: "Passcode")
      if PasscodeRetryHandler.isPasscodeRetryLimitReached() {
        cancelValidationAttempt()
        showRetryLimitReachedAlertThenReset(from: passCodeInputController)
      }
    }
  }

  // MARK: Passcode Create Screen Methods
  public func createPasscodeScreen() -> FUIPasscodeCreateController {
    let passCodeController = FUIPasscodeCreateController.createInstanceFromStoryboard(self.passcodePolicy().allowsTouchID)
    passCodeController.delegate = self
    let passCodePolicySettings = AppConfig.sharedInstance.passcodePolicySettings as [String:Any]
    //  This property indicates if the create passcode process includes a screen to enable TouchID or not. The default is true.
    //  Note that if there is no TouchID registered on the device, the enable TouchID screen will not be shown
    //  even if this property is true.
    if let passCodePolicyAllowsTouchID = passCodePolicySettings["AllowsTouchID"] as? Bool {
      passCodeController.canEnableTouchID = passCodePolicyAllowsTouchID
    }
    return passCodeController
  }

  // MARK: Passcode Change Screen Methods
  @objc
  public func showPasscodeChangeScreen(_ params: NSDictionary, callback: PasscodeInputScreenDelegate) {
    self.callback = callback
    let changeController = FUIPasscodeChangeController.createInstanceFromStoryboard()
    changeController.passcodeControllerDelegate = self
    changeController.validationDelegate = self
    let onController = params["Page"] as? UIViewController
    onController?.present(changeController, animated: true, completion: nil)
  }

  // MARK: Passcode Delegates
  public func shouldTryPasscode(_ passcode: String, forInputMode inputMode: FUIPasscodeInputMode, fromController passcodeController: FUIPasscodeController) throws {
    switch inputMode {
    // User tries to replace an existing passcode with a new passcode - 3rd Screen of Passcode Change
    case .change:
      do {
        try validate(passcode: passcode)
        // Update store and with this new passcode
        try SecureStoreManager.sharedInstance.changeEncryptionKey(with: passcode)
        self.savePasscode(passcode)
        // User has completed passcode change.  Send the new passcode to {N} side.
        self.didConfirmPasscode(passcodeController)
      } catch {
        AppConfig.sharedInstance.data["Status"] = "Failure"
        self.callback!.perform(NSSelectorFromString("finishedOnboardingWithParams"), with: AppConfig.sharedInstance.data)
        throw "Change passcode failed: Unable to set secure store key."
      }
      break
    // User tries to create a new passcode
    case .create:
      self.savePasscodeSource(passcodeController.passcodeSource)
      self.savePasscode(passcode)
      self.passcodeDelegate?.didConfirmPasscode()
      _ = passcodeController.navigationController?.popToRootViewController(animated: true)
      break
    // User is inputing the passcode - Passcode Input Screen
    case .match:
      do {
        try self.validatePasscode(passcode, fromController: passcodeController)
        self.didConfirmPasscode(passcodeController)
      } catch FUIPasscodeControllerError.invalidPasscode(code: "Passcode Mismatch.", triesRemaining: 0) {
        showRetryLimitReachedAlertThenReset(from: passcodeController)
      }
      break
    // User tries to match the previously set passcode in order to change passcode - 1st Screen of Passcode Change
    case .matchForChange:
      do {
        try self.validatePasscode(passcode, fromController: passcodeController)
      } catch FUIPasscodeControllerError.invalidPasscode(code: "Passcode Mismatch.", triesRemaining: 0) {
        showRetryLimitReachedAlertThenReset(from: passcodeController)
      }
      break
    }
  }

  public func didCancelPasscodeEntry(fromController passcodeController: FUIPasscodeController) {
    print("PassCode Entry Cancelled")
    if let passcodeController = passcodeController as? FUIPasscodeCreateController {
      _ = passcodeController.navigationController?.popToRootViewController(animated: true)
    } else {
      passcodeController.dismiss(animated: true, completion: {
        self.setOnboardingStage(to: "InApplication")
        self.cancelPasscode()
      })
    }
  }

  // For now, if user forgets passcode, he has no option but to reset the client and return to welcome screen.
  public func shouldResetPasscode(fromController passcodeController: FUIPasscodeController) {
    print("Should Reset Passcode")
    self.callback!.resetClient()
    passcodeController.dismiss(animated: true, completion: nil)
  }

  public func didSkipPasscodeSetup(fromController passcodeController: SAPFiori.FUIPasscodeController) {
    print("Did Skip Passcode Setup")
  }

  // Called when user attempts change passcode. Per SAP security, new passcode != current passcode.
  public func validate(passcode: String) throws {
    SecureStoreManager.sharedInstance.close()
    do {
      // To validate current passcode entered, try opening our secure store with it.
      try SecureStoreManager.sharedInstance.open(with: passcode)
      // Open succeeds, user entered same passcode. Reject it.
      throw FUIPasscodeControllerError.failedToMeetPolicy(message: "New passcode must differ. Please re-enter.")
    } catch SecureStorageError.authenticationFailed {
      // Open Fails, user entered a new passcode. Now re-open store with cached old passcode so we can update it with new passcode.
      try SecureStoreManager.sharedInstance.open(with: AppConfig.sharedInstance.passCode!)
    }
  }

  // MARK: Passcode Create Screen Methods
  private func storePasscodePolicy(_ params: NSDictionary) {
    if let passCodePolicySettings = params["PasscodePolicySettings"] as? [String:Any] {
      AppConfig.sharedInstance.passcodePolicySettings = passCodePolicySettings
    }
  }

  // Called after the successful validation of Passcode. Change the Finite State Machine State. Send the Success Action
  private func didConfirmPasscode(_ passcodeController: FUIPasscodeController) {
    passcodeController.dismiss(animated: false, completion: {
      PasscodeRetryHandler.resetPasscodeRetriesRemaining()
      AppConfig.sharedInstance.data["Passcode"] = AppConfig.sharedInstance.passCode
      AppConfig.sharedInstance.data["Status"] = "Success"
      self.setOnboardingStage(to: "InApplication")
      guard self.callback != nil else {
        print("Callback is Nil")
        return
      }
      self.callback!.perform(NSSelectorFromString("finishedOnboardingWithParams"), with: AppConfig.sharedInstance.data)
    })
  }

  private func savePasscodeSource(_ passcodeSource: FUIPasscodeSource) {
    var source: Int = 0

    switch passcodeSource {
    case .user:
      source = 1
      break
    case .device:
      source = 2
      break
    default:
      source = 0
    }
    AppConfig.sharedInstance.passcodeSource = source
  }

  private func savePasscode(_ passcode: String) {
    AppConfig.sharedInstance.passCode = passcode
    // Re-setting retry limit and remaining retries if the sign-in was successful
    PasscodeRetryHandler.setPasscodeRetryLimit(self.passcodePolicy().retryLimit)
  }

  private func validatePasscode(_ passcode: String, fromController passcodeController: FUIPasscodeController) throws {
    SecureStoreManager.sharedInstance.close()
    do {
      // To validate current passcode entered, try opening our secure store with it.
      try SecureStoreManager.sharedInstance.open(with: passcode)
      // re-cache passcode in case we got here because user exited app and returned
      savePasscode(passcode)
    } catch {
      let retriesRemaining = PasscodeRetryHandler.decrementPasscodeRetriesRemaining()
      if PasscodeRetryHandler.isPasscodeRetryLimitReached() {
        // Retry limit is reached. Cancel the attempt for now.
        // TODO in future we may enforce a user lockout ?
        self.cancelValidationAttempt()
        throw FUIPasscodeControllerError.invalidPasscode(code: "Passcode Mismatch.", triesRemaining: 0)
      } else {
        throw FUIPasscodeControllerError.invalidPasscode(code: "Passcode Mismatch.",
                                                         triesRemaining: retriesRemaining)
      }
    }
  }

  // MARK: Utility methods
  // swiftlint:enable cyclomatic_complexity

  private func cancelValidationAttempt() {
    AppConfig.sharedInstance.data["Status"] = "Failure"
    FUIPasscodeController.enterCredentialsMessageString = "Please start the onboarding process again!"
    guard self.callback != nil else {
      print("Callback is Nil")
      return
    }
    self.callback!.perform(NSSelectorFromString("finishedOnboardingWithParams"), with: AppConfig.sharedInstance.data)
  }

  // After the alert is dismissed by clicking on the Ok button, the passcode controller will be dismissed
  // and the application will be reset.
  private func showRetryLimitReachedAlertThenReset(from passcodeController: UIViewController) {
    let alertTitle = "No more attempts left"
    let alertMessage = "Please start the onboarding process again!"
    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
    let alertOkHandler = { (action: UIAlertAction!) -> Void in
      passcodeController.dismiss(animated: true, completion: {
        if let callback = self.callback {
          callback.resetClient()
        }
      })
    }
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: alertOkHandler)
    alert.addAction(okAction)
    passcodeController.present(alert, animated: true, completion:nil)
  }

  private func setOnboardingStage(to stage: String) {
    if let callback = self.callback {
      callback.perform(NSSelectorFromString("setOnboardingStage"), with: stage)
    }
  }

  private func finishOnboarding(with params: Dictionary<String, String>) {
    if let callback = self.callback {
      callback.perform(NSSelectorFromString("finishedOnboardingWithParams"), with:params)
    } else {
      print("Callback is nil")
    }
  }

  private func cancelPasscode() {
    if let callback = self.callback {
      callback.perform(NSSelectorFromString("cancelPasscode"))
    }
  }

  private func manageBlur() {
    if isBlurred {
      removeBlur()
    }
  }
  private func addBlurScreen(currentVC: UIViewController) {
    if !isBlurred {
      blurView = addBlurEffect(on: currentVC)
      self.setOnboardingStage(to: "Inactive")
      isBlurred = true
    }
  }
  private func removeBlur() {
    if let view = blurView {
      view.removeFromSuperview()
    }
    self.setOnboardingStage(to: "InApplication")
    blurView = nil
    isBlurred = false
  }
  private func addBlurEffect(on currentViewController: UIViewController) -> UIVisualEffectView {
    let blurEffect = UIBlurEffect(style: .light)
    let blurredEffectView = UIVisualEffectView(effect: blurEffect)
    blurredEffectView.frame = (UIScreen.main.bounds)
    UIApplication.shared.keyWindow?.addSubview(blurredEffectView)
    return blurredEffectView
  }
}
