//
//  SectionTableViewController.swift
//  SnowblindDemo
//
//  Created by Gao, Yong on 20/10/17.
//  Copyright © 2017 sap. All rights reserved.
//

import UIKit
import SAPMDC

class SectionTableViewController: UIViewController {
    
    private var sectionTableBridge: SectionedTableBridge!
    private var sectionBridge: SectionBridge!
    private var sections = [ObjectTableSection]()
    private var sectionDelegate: MySectionDelegate!
    var data: [Int: NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sectionBridge = SectionBridge()
        self.sectionTableBridge = SectionedTableBridge()
        self.sectionDelegate = MySectionDelegate(self)
        self.sectionDelegate.setData(data: self.data! as! [Int : Dictionary<String, Any>])
        
        createSection()
        createSectionTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // create section
    func createSection() -> Void {
        let sectionDefinition = ["type": "Section.Type.ObjectTable",
                        "usesHeader": true,
                        "headerTitle": "headerTitle",
                        "headerAttributeLabel": true,
                        "topPadding": 0,
                        "useHeaderTopPadding": true,
                        "usesFooter": true,
                        "footerTitle": "footerTitle",
                        "footerAttributeLabel": true,
                        "disclosureAccessoryHidden": true
            ] as [String : Any]
        let section = self.sectionBridge?.create(sectionDefinition, callback: self.sectionDelegate)
        self.sections.append(section as! ObjectTableSection)
    }
    
    // create sectionedTable
    func createSectionTable() {
        let controller = self.sectionTableBridge?.create(sections)
        self.addChildViewController(controller!)
        self.view.addSubview((controller?.view)!)
        if(data != nil){
            // simulate callback when data ready
            self.sectionBridge.reloadData(data?.count as! NSNumber)
        }
    }

}
