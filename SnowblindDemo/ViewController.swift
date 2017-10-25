//
//  ViewController.swift
//  SnowblindDemo
//
//  Created by Gao, Yong on 18/10/17.
//  Copyright © 2017 sap. All rights reserved.
//

import UIKit
import Foundation
import SAPMDC


class ViewController: UIViewController {
    func didConfirmPasscode() {
        print("test")
    }
    
    
    private var toastBridge: ToastMessageViewBridge!
    private var connectionSettingsParams: [String: Any] = [:]
    private var welcomePageDelegate: WelcomePageDelegate!
    private var myPasscodeInputScreenDelegate : MyPasscodeInputScreenDelegate?
    
    private var oDataServiceManagerBridge: ODataServiceManagerBridge!
    private var serviceUrl: String = "https://hcpms-p1941708244trial.hanatrial.ondemand.com/com.sap.seam.demo"
    @IBOutlet weak var accessToken: UITextField!
    private var oAuthRequestorBridge: OAuthRequestorBridge!
    private var oDataParams: [String: Any] = [:]
    private var data:[Int: NSDictionary]?
    private var jsonData: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParams()
        welcomePageDelegate = WelcomePageDelegate(self)
        self.toastBridge = ToastMessageViewBridge()
        self.oDataServiceManagerBridge = ODataServiceManagerBridge()
        self.myPasscodeInputScreenDelegate = MyPasscodeInputScreenDelegate(self)
        // for testing
        self.accessToken.text = "168f8d95aef019ebcc112ce6bd7536b"
    }
    
    @IBAction func GetAccessToken(_ sender: Any) {
        let token = SecureOAuth2TokenStore.sharedInstance.token(for: URL(string: "https://www.sap.com")!)
        self.accessToken.text = token?.accessToken
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    func setupParams(){
        self.oDataParams = ["serviceUrl": serviceUrl,
                            "X-SMP-APPID": "com.sap.seam.demo",
                            "entitySet": "ProductSet",
                            "properties": ["ProductID", "Category","Name"]
        ]
        let passcodePolicyParams: [String: Any] = [
            "IsDigitsOnly": true,
            "MinLength": 4,
            "HasLower": false,
            "HasUpper": false,
            "HasSpecial": false,
            "AllowsTouchID": true,
            "RetryLimit": 6,
            "HasDigit": true,
            "MinUniquechars": 0
        ]
        self.connectionSettingsParams = [
            "AppNameLabel" : "Android POC",
            "ApplicationID" : "com.sap.seam.demo",
            "AuthorizationEndpointURL" : "https://oauthasservices-p1941708244trial.hanatrial.ondemand.com/oauth2/api/v1/authorize",
            "ClientID" : "720ff054-9a43-4078-aa4d-985fad16c22e",
            "CpmsURL" : "https://hcpms-p1941708244trial.hanatrial.ondemand.com",
            "EncryptDatabase" : false,
            "PasscodePolicySettings" : passcodePolicyParams,
            "RedirectURL" : "https://oauthasservices-p1941708244trial.hanatrial.ondemand.com",
            "TokenEndpointURL" : "https://oauthasservices-p1941708244trial.hanatrial.ondemand.com/oauth2/api/v1/token",
        ]
    }

    // show welcome page and onboarding
    @IBAction func onWelcomePage(_ sender: UIButton) {
        self.navigationController?.isNavigationBarHidden = true
        let bridge = WelcomeScreenBridge()
        let controller = bridge.create(self.connectionSettingsParams, callback: self.welcomePageDelegate) as! WelcomeScreenViewController
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
    }
    
    @IBAction func onShowPasscodeScreen(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = true
        self.connectionSettingsParams["Page"] = self
        self.connectionSettingsParams["ManageBlurScreen"] = -1
        let bridge = PasscodeInputScreenBridge()
        let controller = bridge.create(self.connectionSettingsParams, callback: self.myPasscodeInputScreenDelegate) as! PasscodeViewController
        
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
    }
    
    // create odata
    @IBAction func onODataCreate(_ sender: UIButton) {
        guard self.accessToken.text != "" else {
            return
        }
        oDataParams["AccessToken"] = self.accessToken.text
        self.oDataServiceManagerBridge.create(oDataParams, resolve: { (_) in
            let messageParams = ["message": "OData create successfully"]
            self.toastBridge.displayToastMessage(messageParams)
        }, reject: { (_: String?, message: String?, _: Error?) in
            print("\(String(describing: message))")
        })
        
    }
    
    // open oData
    @IBAction func onODataOpen(_ sender: UIButton) {
        guard self.accessToken.text != "" else {
            return
        }
        self.oDataServiceManagerBridge.open(oDataParams, resolve: { (result) in
            print(String(result.debugDescription))
            let messageParams = ["message": "OData Open successfully"]
            self.toastBridge.displayToastMessage(messageParams)
        }, reject: { (_: String?, message: String?, _: Error?) in
            print("\(String(describing: message))")
        })
    }

    // read online/offline oData
    @IBAction func onODataRead(_ sender: UIButton) {
        guard self.accessToken.text != "" else {
            return
        }
        self.oDataServiceManagerBridge.read(oDataParams, resolve: { (data) in
            
            if let result: String = data as! String {
                if let data2 = self.convertToDictionary(text: result) {
                    self.jsonData = data2
                }
            }

            let messageParams = ["message": "OData Read successfully"]
            self.toastBridge.displayToastMessage(messageParams)
        }, reject: { (_: String?, message: String?, _: Error?) in
            print("\(String(describing: message))")
        })
    }
    
    // count online/offline oData
    @IBAction func onODataCount(_ sender: UIButton) {
        guard self.accessToken.text != "" else {
            return
        }
        self.oDataServiceManagerBridge.count(oDataParams, resolve: { (data) in
            if let result = data {
                let messageParams = ["message": "OData has \(result) records"]
                self.toastBridge.displayToastMessage(messageParams)
            }
        }, reject: { (_: String?, message: String?, _: Error?) in
            print("\(String(describing: message))")
        })
    }
    
    
    // init OfflineODataStore
    @IBAction func InitOfflineStore(_ sender: Any) {
        oDataParams["inDemoMode"] = false
        oDataParams["serviceTimeZoneAbbreviation"] = "UTC"
        oDataParams["storeEncryptionKey"] = ""
        oDataParams["debugODataProvider"] = true
        
        let reqDict: NSMutableDictionary = [:]
        reqDict["Name"] = "Products"
        reqDict["Query"] = "ProductSet"
        reqDict["AutomaticallyRetrievesStreams"] = false
        
        let definingRequests = [reqDict]
        oDataParams["definingRequests"] = definingRequests
        
        self.oDataServiceManagerBridge.initializeOfflineStore(oDataParams, resolve: { (data) in
            
            let messageParams = ["message": "Offline OData Initialized successfully"]
            self.toastBridge.displayToastMessage(messageParams)
        }, reject: { (_: String?, message: String?, _: Error?) in
            print("\(String(describing: message))")
        })
        
    }
    
    // show sectionedTable page
    @IBAction func showSectionedTable(_ sender: UIButton) {
        if self.jsonData == nil {
            print("no data received")
            return
        }
        
        guard let dataset: [Int: NSDictionary] = self.generateDataset() else {
            print("data format error")
            return
        }
        let sectionedTableVC = SectionTableViewController()
        sectionedTableVC.data = dataset
        self.navigationController?.pushViewController(sectionedTableVC, animated: true)
    }
    
    // convert oData result for sectionedtable data
    func generateDataset() -> [Int: NSDictionary] {
        
        let jsonData:[String: Any] = self.jsonData!
        let dataArray = jsonData["value"] as! NSArray;
        
        var dataset : [Int: NSDictionary] = [:]
        var i: Int = 0
        for item in dataArray {
            let obj = item as! NSDictionary
            var product: NSMutableDictionary = [:]
            for (key, value) in obj {
                if key as! String == "Name" {
                    product["Title"] = value
                }
                if key as! String == "Category" {
                    product["Subhead"] = value
                }
                if key as! String == "SupplierName" {
                    product["Footnote"] = value

                }
            }
            dataset[i] = product
            i = i + 1
        }
        return dataset
    }
    
    
    // for convert data
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

}

