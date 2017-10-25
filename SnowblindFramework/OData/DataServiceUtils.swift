//
//  DataServiceUtils.swift
//  SnowblindClient
//
//  Created by Mehta, Kunal on 9/12/16.
//  Copyright © 2016 sap. All rights reserved.
//

import Foundation
import SAPOData
import SAPFoundation
import SAPOfflineOData

class DataServiceUtils {

  //TODO this may need to updated if app domain is changed
  static let appDomain = "sap.com.mdc"
  static let genericErrorCode = 400

  private static let timeZoneAbbreviationForString = "UTC"

  private static let dateFormats = ["yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ssXXXXX", "yyyy-MM-dd", "HH:mm:ss"]

  // MARK: Helpers
  static func getServiceName(serviceUrl: String?) -> String? {
    if let urlString = serviceUrl, let url = NSURL(string: urlString), let name = url.lastPathComponent, name != "/" {
      return name
    }
    return nil
  }

  // TODO:  This method trips swiftlint (cyclomatic_complexity) rule.  Please refactor.
  // swiftlint:disable:next cyclomatic_complexity
  static func convert(value: AnyObject, type: Int) throws -> DataValue {
    switch type {
    case DataType.string:
      return try convertString(value: value)
    case DataType.integer:
      return try convertInteger(value: value)
    case DataType.byte:
      return try convertByte(value: value)
    case DataType.boolean:
      return try convertBool(value: value)
    case DataType.char:
      return try convertChar(value: value)
    case DataType.decimal:
      return try convertDecimal(value: value)
    case DataType.double:
      return try convertDouble(value: value)
    case DataType.float:
      return try convertFloat(value: value)
    case DataType.int:
      return try convertInt(value: value)
    case DataType.short:
      return try convertShort(value: value)
    case DataType.long:
      return try convertLong(value: value)
    case DataType.unsignedByte:
      return try convertUnsignedByte(value: value)
    case DataType.localDate:
      return try convertLocalDate(value: value)
    case DataType.localTime:
      return try convertLocalTime(value: value)
    case DataType.localDateTime:
      return try convertLocalDateTime(value: value)
    case DataType.globalDateTime:
      return try convertGlobalDateTime(value: value)
    default:
      throw ODataErrors.genericError("Conversion of format \(type) not implemented")
    }
  }

  static func convertString(value: AnyObject) throws -> DataValue {
    if let correctType = value as? StringValue {
      return correctType
    }

    // This is a workaround for a bug in the backend which lead to the temporary removal of the Date type, which
    // has been replaced by strings. When the UI sends a Date object, and that the Property is of type String,
    // convert the Date to a String
    if let dateVal = value as? Date {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"

      let stringDate = formatter.string(from: dateVal)
      return StringValue.of(stringDate)
    }

    if let stringVal = value as? String {
      return StringValue.of(stringVal)
    } else {
      throw ODataErrors.genericError("Could not convert to StringValue")
    }
  }

  static func convertInteger(value: AnyObject) throws -> DataValue {
    if let correctType = value as? IntegerValue {
      return correctType
    }

    if let integerVal = value as? BigInteger {
      return IntegerValue.of(integerVal)
    } else if let stringVal = value as? String {
      return IntegerValue.of(BigInteger(stringVal))
    } else {
      throw ODataErrors.genericError("Could not convert to IntegerValue")
    }
  }

  static func convertByte(value: AnyObject) throws -> DataValue {
    if let correctType = value as? ByteValue {
      return correctType
    }

    let returnValue: Int
    if let intval = value as? Int {
      returnValue = intval
    } else if let stringVal = value as? String, let intVal = Int(stringVal) {
      returnValue = intVal
    } else {
      throw ODataErrors.genericError("Could not convert to Byte")
    }
    guard returnValue >= -128, returnValue <= 127 else {
      throw ODataErrors.genericError("Number does not fit into a signed Byte")
    }
    return ByteValue.of(returnValue)
  }

  static func convertBool(value: AnyObject) throws -> DataValue {
    if let correctType = value as? BooleanValue {
      return correctType
    }

    if let boolVal = value as? Bool {
      return BooleanValue.of(boolVal)
    } else if let stringVal = value as? String {
      guard let stringBool = Bool(stringVal) else {
        throw ODataErrors.genericError("Could not convert string to Boolean. String is \(stringVal), needs to be true of false")
      }
      return BooleanValue.of(stringBool)
    } else {
      throw ODataErrors.genericError("Could not convert to BooleanValue")
    }
  }

  static func convertChar(value: AnyObject) throws -> DataValue {
    if let correctType = value as? CharValue {
      return correctType
    }

    if let charVal = value as? unichar {
      return CharValue.of(charVal)
    } else {
      throw ODataErrors.genericError("Could not convert to CharValue")
    }
  }

  static func convertDecimal(value: AnyObject) throws -> DataValue {
    if let correctType = value as? DecimalValue {
      return correctType
    }

    if let decimalVal = value as? BigDecimal {
      return DecimalValue.of(decimalVal)
    } else if let doubleVal = value as? Double {
      return DecimalValue.of(BigDecimal.fromDouble(doubleVal))
      // Double from String is more robust than BigDecimal from String, so doing a detour through Double...
    } else if let stringVal = value as? String, let doubleValue = Double(stringVal) {
      return DecimalValue.of(BigDecimal.fromDouble(doubleValue))
    } else {
      throw ODataErrors.genericError("Could not convert to DecimalValue")
    }
  }

  static func convertDouble(value: AnyObject) throws -> DataValue {
    if let correctType = value as? DoubleValue {
      return correctType
    }

    if let doubleVal = value as? Double {
      return DoubleValue.of(doubleVal)
    } else if let stringVal = value as? String, let doubleValue = Double(stringVal) {
      return DoubleValue.of(doubleValue)
    } else {
      throw ODataErrors.genericError("Could not convert to DoubleValue")
    }
  }

  static func convertFloat(value: AnyObject) throws -> DataValue {
    if let correctType = value as? FloatValue {
      return correctType
    }

    if let floatVal = value as? Float {
      return FloatValue.of(floatVal)
    } else if let stringVal = value as? String, let floatValue = Float(stringVal) {
      return FloatValue.of(floatValue)
    } else {
      throw ODataErrors.genericError("Could not convert to FloatValue")
    }
  }

  static func convertInt(value: AnyObject) throws -> DataValue {
    if let correctType = value as? IntValue {
      return correctType
    }

    if let intval = value as? Int {
      return IntValue.of(intval)
    } else if let stringVal = value as? String, let intValue = Int(stringVal) {
      return IntValue.of(intValue)
    } else {
      throw ODataErrors.genericError("Could not convert to IntValue")
    }
  }

  static func convertShort(value: AnyObject) throws -> DataValue {
    if let correctType = value as? ShortValue {
      return correctType
    }

    if let intval = value as? Int {
      return ShortValue.of(intval)
    } else if let stringVal = value as? String, let intValue = Int(stringVal) {
      return ShortValue.of(intValue)
    } else {
      throw ODataErrors.genericError("Could not convert to ShortValue")
    }
  }

  static func convertLong(value: AnyObject) throws -> DataValue {
    if let correctType = value as? LongValue {
      return correctType
    }

    if let int64val = value as? Int64 {
      return LongValue.of(int64val)
    } else if let stringVal = value as? String, let int64Value = Int64(stringVal) {
      return LongValue.of(int64Value)
    } else {
      throw ODataErrors.genericError("Could not convert to LongValue")
    }
  }

  static func convertUnsignedByte(value: AnyObject) throws -> DataValue {
    if let correctType = value as? UnsignedByte {
      return correctType
    }

    let returnValue: Int
    if let intval = value as? Int {
      returnValue = intval
    } else if let stringVal = value as? String, let intVal = Int(stringVal) {
      returnValue = intVal
    } else {
      throw ODataErrors.genericError("Could not convert to UnsignedByte")
    }
    guard returnValue <= 255 else {
      throw ODataErrors.genericError("Number does not fit into a Byte")
    }

    guard returnValue >= 0 else {
      throw ODataErrors.genericError("No negative values allowed in an Unsigned Byte")
    }

    return UnsignedByte.of(returnValue)
  }

  // Info: the date or time coming from UI Controls is always in UTC, i.e. if user enters 13:00 and his device is EST timezone, the Date object will be 17:00

  static func convertLocalDateTime(value: AnyObject) throws -> DataValue {

    if let correctType = value as? LocalDateTime {
      return correctType
    }

    if let stringVal = value as? String {
      if let utcDate = DataServiceUtils.optionalUtcDateFromString(stringVal, withTimeZoneAbbreviation: timeZoneAbbreviationForString) {
        return LocalDateTime.from(utc: utcDate, in: TimeZone.init(abbreviation: timeZoneAbbreviationForString)!)
      } else {
        throw ODataErrors.genericError("This string could not be parsed to LocalDateTime: \(stringVal). Wrong format.")
      }
    }

    if let dateTimeVal = value as? Date {
      // TODO: The abbreviation comes from the BrandedSettings. This will also have to support DateTimeOffset in the future, as it will replace DateTime in OData V4
      // (Gateway currently does not support DateTimeOffset).
      return LocalDateTime.from(utc: dateTimeVal, in: TimeZone.init(abbreviation: ODataServiceProvider.serviceTimeZoneAbbreviation)!)
    }

    throw ODataErrors.genericError("LocalDateTime conversion error")
  }

  // GlobalDateTime assumes that the user did all the calculations and entered time in UTC no matter where he is,
  //  and that the backend also expects UTC, so no conversion is required
  static func convertGlobalDateTime(value: AnyObject) throws -> DataValue {
    if let correctType = value as? GlobalDateTime {
      return correctType
    }

    if let stringVal = value as? String {
      if let utcDate = DataServiceUtils.optionalUtcDateFromString(stringVal, withTimeZoneAbbreviation: timeZoneAbbreviationForString) {
        return GlobalDateTime.from(utc: utcDate)
      } else {
        throw ODataErrors.genericError("This string could not be parsed to GlobalDateTime: \(stringVal). Wrong format.")
      }
    }

    if let dateTimeVal = value as? Date {
      return GlobalDateTime.from(utc: dateTimeVal)
    }

    throw ODataErrors.genericError("GlobalDateTime conversion error")
  }

  static func convertLocalDate(value: AnyObject) throws -> DataValue {
    if let correctType = value as? LocalDate {
      return correctType
    }

    if let stringVal = value as? String {
      if let utcDate = DataServiceUtils.optionalUtcDateFromString(stringVal, withTimeZoneAbbreviation: timeZoneAbbreviationForString) {
        return LocalDate.from(utc: utcDate, in: TimeZone.init(abbreviation: timeZoneAbbreviationForString)!)
      } else {
        throw ODataErrors.genericError("This string could not be parsed to LocalDate: \(stringVal). Wrong format.")
      }
    }

    if let dateVal = value as? Date {
      // TODO: The abbreviation comes from the BrandedSettings. This will also have to support DateTimeOffset in the future, as it will replace DateTime in OData V4
      // (Gateway currently does not support DateTimeOffset).
      return LocalDate.from(utc: dateVal, in: TimeZone.init(abbreviation: ODataServiceProvider.serviceTimeZoneAbbreviation)!)
    }

    throw ODataErrors.genericError("LocalDate conversion error")
  }

  static func convertLocalTime(value: AnyObject) throws -> DataValue {
    if let correctType = value as? LocalTime {
      return correctType
    }

    if let stringVal = value as? String {
      if let utcDate = DataServiceUtils.optionalUtcDateFromString(stringVal, withTimeZoneAbbreviation: timeZoneAbbreviationForString) {
        return LocalTime.from(utc: utcDate, in: TimeZone.init(abbreviation: timeZoneAbbreviationForString)!)
      } else {
        throw ODataErrors.genericError("This string could not be parsed to LocalTime: \(stringVal). Wrong format.")
      }
    }

    if let dateVal = value as? Date {
      // TODO: The abbreviation comes from the BrandedSettings. This will also have to support DateTimeOffset in the future, as it will replace DateTime in OData V4
      // (Gateway currently does not support DateTimeOffset).
      return LocalTime.from(utc: dateVal, in: TimeZone.init(abbreviation: ODataServiceProvider.serviceTimeZoneAbbreviation)!)
    }

    throw ODataErrors.genericError("LocalTime conversion error")
  }

  static func getError(errorCode: Int, dataServiceError: DataServiceError) -> NSError {
    return NSError(domain: appDomain, code: errorCode,
                   userInfo: ["message": dataServiceError.message as Any])
  }

  static func getError(errorCode: Int?, oDataError: SAPOData.ErrorBase) -> NSError {
    let code = errorCode == nil ? genericErrorCode: errorCode
    return NSError(domain: appDomain, code: code!,
                   userInfo: ["message": oDataError.message as Any])
  }

  static func getOfflineError(errorCode: Int?, oDataError: OfflineODataError) -> NSError {
    let code = errorCode == nil ? genericErrorCode: errorCode
    return NSError(domain: appDomain, code: code!,
                   userInfo: ["message": oDataError.message as Any])
  }

  static func getError(errorCode: Int, errorMessage: String) -> NSError {
    return NSError(domain: appDomain, code: errorCode,
                   userInfo: ["message": errorMessage])
  }

  // This key generation method satisfies the SAP security requirements for encryption.
  static func generateOfflineStoreEncryptionKey() -> String? {
    var keyData = Data(count: 32)
    let result = keyData.withUnsafeMutableBytes { mutableBytes in
      SecRandomCopyBytes(kSecRandomDefault, keyData.count, mutableBytes)
    }
    if result == errSecSuccess {
      return keyData.base64EncodedString()
    }
    // We should never get here.
    return nil
  }

  /**
   String formats supported:  ISO8601 = yyyy-MM-ddTHH:mm:ssZZZZZ and yyyy-MM-dd HH:mm:ssZZZZZ
   Compatible with Edm.DateTime (OData)
   Example:  2017-04-20T13:42:00Z
   */
  public static func utcDateFromString(_ dateString: String, withTimeZoneAbbreviation timeZoneAbbreviation: String) -> Date {

    if let utcDate = optionalUtcDateFromString(dateString, withTimeZoneAbbreviation: timeZoneAbbreviation) {
      return utcDate
    }
    return Date()
  }

  private static func optionalUtcDateFromString(_ dateString: String, withTimeZoneAbbreviation timeZoneAbbreviation: String) -> Date? {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.timeZone = TimeZone.init(abbreviation: timeZoneAbbreviation)
    if let someDateTime = isoFormatter.date(from: dateString) {
      return someDateTime
    } else {
      // try the formatter used by the native control
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone.init(abbreviation: timeZoneAbbreviation)
      for val in dateFormats {
        formatter.dateFormat = val
        if let dateTime = formatter.date(from: dateString) {
          return dateTime
        }
      }
    }
    return nil
  }
}
