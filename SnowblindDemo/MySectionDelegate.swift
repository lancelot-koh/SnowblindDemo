//
//  MySectionDelegate.swift
//  SnowblindDemo
//
//  Created by Gao, Yong on 20/10/17.
//  Copyright © 2017 sap. All rights reserved.
//

import UIKit
import SAPMDC

class MySectionDelegate: SectionDelegate {
    var controller : UIViewController?
    var data: [Int: Dictionary<String, Any>]?

    init(_ controller: UIViewController) {
        self.controller = controller
    }
    
    @objc func setData(data : [Int : Dictionary<String, Any>]) {
        self.data = data
    }
    
    @objc  override func footerTapped(){
        print("footerTapped")

    }

    @objc override func loadMoreItems(_ row: NSNumber!) {
        print("load more items")
    }
    
    @objc func getView(row: Int) -> UIView! {
        print("getView \(row)")
        return nil
    }
    @objc func getView() -> UIView! {
        print("getView")
        return nil
    }
    
    // override getBoundData and set current row data
    @objc override func getBoundData(_ row: NSNumber!) -> [AnyHashable : Any]! {
        var rowi: Int = row.intValue
        return self.data![rowi] as! [AnyHashable : Any]
    }
    

    @objc func onPress() {
        print("onPress")
    }
    
    
    @objc func searchUpdated()  {
        print("searchUpdated")
    }
    
    @objc func loadMoreItems()  {
        print("loadMoreItems")
    }
   
    
}
