//
//  ParameterHelper.swift
//  SAPMDCFramework
//
//  Created by Tan, Jin Na on 1/16/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation

public class ParameterHelper {
  public static func getParameterAsString(cellParams: [String: Any], paramName: String) -> String? {
    if let value = cellParams[paramName] {
      return String(describing: value)
    }
    return checkValidationProperties(cellParams: cellParams, paramName: paramName) as? String
  }

  public static func getParameterAsBool(cellParams: [String: Any], paramName: String) -> Bool? {
    if let value = cellParams[paramName], let boolValue = value as? Bool {
      return boolValue
    }
    return checkValidationProperties(cellParams: cellParams, paramName: paramName) as? Bool
  }

  public static func getParameterAsInt(cellParams: [String: Any], paramName: String) -> Int? {
    if let value = cellParams[paramName], let intValue = value as? Int {
      return intValue
    }
    return nil
  }

  public static func getParameterAsDouble(cellParams: [String: Any], paramName: String) -> Double? {
    if let value = cellParams[paramName], let doubleValue = value as? Double {
      return doubleValue
    }
    return nil
  }

  public static func getParameterAsStringArray(cellParams: [String: Any], paramName: String) -> [String]? {
    if let value = cellParams[paramName], let stringArray = value as? [String] {
      return stringArray
    }
    return nil
  }

  public static func getParameterAsIntArray(cellParams: [String: Any], paramName: String) -> [Int]? {
    if let value = cellParams[paramName], let intArray = value as? [Int] {
      return intArray
    }
    return nil
  }

  public static func getParameterAsColor(cellParams: [String: Any], paramName: String) -> UIColor? {
    if let hexString = checkValidationProperties(cellParams: cellParams, paramName: paramName) as? String {
      return UIColor(hexString: hexString)
    }
    return nil
  }

  public static func getParameterAsDictionary(cellParams: [String: Any], paramName: String) -> [String: Any]? {
    if let style = cellParams[paramName] as? [String: Any] {
      return style
    }
      return nil
  }

  public static func getParameterAsNSDictionaryArray(cellParams: [String: Any], paramName: String) -> [NSDictionary]? {
    if let dict = cellParams[paramName] as? [NSDictionary] {
      return dict
    }
    return nil
  }

  private static func checkValidationProperties(cellParams: [String: Any], paramName: String) -> Any? {
    if let validationProperties = cellParams["validationProperties"] as? [String: Any] {
      return validationProperties[paramName]
    }
    return nil
  }
}
