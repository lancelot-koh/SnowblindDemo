//
//  ODataErrors.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 3/21/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
enum ODataErrors: Error {
  case genericError(String)
  case throwError(NSError)
}
