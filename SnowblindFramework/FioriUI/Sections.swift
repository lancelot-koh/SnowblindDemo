//
//  Sections.swift
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/6/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPFiori

// swiftlint:disable file_length

// An array of these is used for one row in the KeyValueSection
struct KeyValue {
  var key: String
  var value: String
}

public enum SectionFooterStyle {

  case attribute, help, title

  init(_ fromString: String) {
    switch fromString {
    case "attribute":
      self = .attribute
    case "help":
      self = .help
    default:
      self = .title
    }
  }

  func toFUIFooterStyle() -> FUISectionHeaderFooterStyle? {
    switch self {
    case .attribute:
      return .attribute
    case .title:
      return .title
    default:
      // the rest are not supported by the SDK
      return nil
    }
  }
}

// MARK: - Section Factory
public class SectionFactory: NSObject {
  // singleton
  @objc
  public static let sharedInstance = SectionFactory()
  public override init() {
  }

  @objc public func createSection(params: NSDictionary, callback: SectionDelegate) -> CommonSection? {

    guard let type = params["type"] as? String else {
      print("_Type parameter missing for Section")
      return nil
    }

    if type == "Section.Type.KeyValue" {
      return KeyValueSection(params: params, callback: callback)
    } else if type == "Section.Type.ObjectTable" {
      return ObjectTableSection(params: params, callback: callback)
    } else if type == "Section.Type.ObjectCollection" {
      return ObjectCollectionSection(params: params, callback: callback)
    } else if type == "Section.Type.ObjectHeader" {
      return ObjectHeaderSection(params: params, callback: callback)
    } else if type == "Section.Type.Extension" {
      return ExtensionSection(params: params, callback: callback)
    } else if type == "Section.Type.ContactCell" {
      return ContactCellSection(params: params, callback: callback)
    } else if type == "Section.Type.SimplePropertyCollection" {
      return SimplePropertyCollectionSection(params: params, callback: callback)
    } else if type == "Section.Type.ButtonTable" {
      return ButtonSection(params: params, callback: callback)
    } else {
      return nil
    }
  }
}

class CollectionLayout {

  let numberOfColumns: Int?
  let minimumInteritemSpacing: CGFloat?

  init(_ params: NSDictionary) {
    self.numberOfColumns = params["numberOfColumns"] as? Int
    self.minimumInteritemSpacing = params["minimumInteritemSpacing"] as? CGFloat
  }

  func applyTo(layout: FUIStandardAutoSizingColumnFlowLayout) {
    if let columns = self.numberOfColumns {
      layout.numberOfColumns = columns
    }
    if let spacing = self.minimumInteritemSpacing {
      layout.minimumInteritemSpacing = spacing
    }
  }
}

protocol CollectionLayoutable {
  var collectionLayout: CollectionLayout { get }
}

// MARK: - Common Section
public class CommonSection: NSObject {
  // Configurable properties:
  var footerAccessoryType: String?
  var footerAttributeLabel: String?
  var usesHeader: Bool = false
  var headerStyle: FUISectionHeaderFooterStyle? = .title
  var headerTitle: String = ""
  var headerAttributeLabel: String = ""
  var usesFooter: Bool = false
  var footerStyle: SectionFooterStyle = .title
  var footerTitle: String = ""
  var footerAttribute: String = ""
  var isDisclosureAccessoryHidden: Bool = false
  var bottomPadding: CGFloat?
  var topPadding: CGFloat?
  var useHeaderTopPadding: Bool = true
  var useFooterBottomPadding: Bool = true
  var emptySectionCaption: String?
  var emptySectionStyle: String?

  var maxItemCount: Int = 1
  var callback: SectionDelegate
  weak var parentTable: SectionedTableViewController?
  // Collection based sections will use this to pass to the sectioned table
  var collectionSection: FUITableViewCollectionSection?

  var itemDict: [Int:NSDictionary] = [:]

  // swiftlint:disable cyclomatic_complexity
  init(params: NSDictionary, callback: SectionDelegate) {
    self.callback = callback
    super.init()
    self.setData(params: params)
  }

  @objc public func redraw(data: NSDictionary) {
    itemDict = [:]
    setData(params: data)

    if let collection = collectionSection {
      collection.collectionView.reloadData()
    } else {
      parentTable?.reloadSection(section: self)
    }
  }

  internal func setData(params: NSDictionary) {

    // Pull out the header data
    if let usesHeader = params["usesHeader"] as? Bool {
      self.usesHeader = usesHeader
    }

    if usesHeader {
      if let headerTitle = params["headerTitle"] {
        self.headerTitle = String(describing: headerTitle)
      }
      if let headerStyle = params["headerStyle"] as? FUISectionHeaderFooterStyle {
        self.headerStyle = headerStyle
      }
      if let headerAttributeLabel = params["headerAttributeLabel"] {
        self.headerAttributeLabel = String(describing: headerAttributeLabel)
      }
      if let topPadding = params["topPadding"] as? CGFloat {
        self.topPadding = topPadding
      }
    }

    // Padding
    if let useHeaderTopPadding = params["useHeaderTopPadding"] as? Bool {
      self.useHeaderTopPadding = useHeaderTopPadding
    }

    if let useFooterBottomPadding = params["useFooterBottomPadding"] as? Bool {
      self.useFooterBottomPadding = useFooterBottomPadding
    }

    // Pull out the footer data
    if let usesFooter = params["usesFooter"] as? Bool {
      self.usesFooter = usesFooter
    }

    if usesFooter {
      if let footerTitle = params["footerTitle"] {
        self.footerTitle = String(describing: footerTitle)
      }
      if let footerAccessoryType = params["footerAccessoryType"] {
        self.footerAccessoryType = String(describing: footerAccessoryType)
      }

      if let footerAttributeLabel = params["footerAttributeLabel"] {
        self.footerAttributeLabel = String(describing: footerAttributeLabel)
      }
      if let footerStyleName = params["footerStyle"] as? String {
        self.footerStyle = SectionFooterStyle(footerStyleName)
      }
      if let isDisclosureAccessoryHidden = params["disclosureAccessoryHidden"] as? Bool {
        self.isDisclosureAccessoryHidden = isDisclosureAccessoryHidden
      }
      if let bottomPadding = params["bottomPadding"] as? CGFloat {
        self.bottomPadding = bottomPadding
      }
    }

    // Pull out default maxItemCount behavior
    if let maxItemCount = params["maxItemCount"] as? Int {
      self.maxItemCount = maxItemCount
    } else {
      self.maxItemCount = 1
    }

    if let emptySectionCaption = params["emptySectionCaption"] as? String {
      self.emptySectionCaption = emptySectionCaption
    }
    if let emptySectionStyle = params["emptySectionStyle"] as? String {
      self.emptySectionStyle = emptySectionStyle
    }
  }

  @objc public func reloadRow(index: Int) {
    DispatchQueue.main.async {
      let indexPath = IndexPath(row: index, section: 0)
      self.parentTable?.tableView.reloadRows(at: [indexPath], with: .fade)
    }
  }

  @objc public func reloadData(itemCount: Int) {
    DispatchQueue.main.async {
      self.maxItemCount = itemCount
      self.parentTable?.tableView.reloadData()
    }
  }

  internal func bindItem(row: Int) {
    // NO-OP
  }

  // MARK: Callback methods
  public func footerTapCallback() -> Void {
    self.callback.footerTapped()
  }

  public func onPressCallback(cell: Int, view: UIView) {
    self.callback.perform(NSSelectorFromString("onPress"), with: cell as NSNumber!, with: view)
  }

  public func getView(row: Int = 0) -> UIView? {
    return self.callback.perform(NSSelectorFromString("getView"), with: row as NSNumber!)?.takeUnretainedValue() as? UIView
  }

  public func isSectionEmpty() -> Bool {
    return self.maxItemCount == 0
  }

  public func usesEmptySectionRow() -> Bool {
    return self.emptySectionCaption != nil
  }

  // MARK: Static methods
  static func accessoryType(from type: String) -> UITableViewCellAccessoryType {
    switch type {
    case "checkmark": return UITableViewCellAccessoryType.checkmark
    case "detailButton": return UITableViewCellAccessoryType.detailButton
    case "detailDisclosureButton": return UITableViewCellAccessoryType.detailDisclosureButton
    case "disclosureIndicator": return UITableViewCellAccessoryType.disclosureIndicator
    default: return UITableViewCellAccessoryType.none
    }
  }
}

// MARK: - FUIView Section
/**
 * FUIViewSection is a class for wrapping Fiori UI Controls into a section
 * Every section which contains a Fiori UI control should extend this class
 */
public class FUIViewSection: CommonSection {
  var items: [AnyObject] = []
  var title: String = ""
  var tableView: UITableView?

  func setTableView(tableView: UITableView) {
    self.tableView = tableView
  }

  override func setData(params: NSDictionary) {
    super.setData(params: params)

    do {
      let jsonItems = (params["items"] as? String)!
      if let items = try JSONSerialization.jsonObject(with: jsonItems.data(using: .utf8)!, options: []) as? [AnyObject] {
        self.items = items
        self.maxItemCount = self.items.count
      }

    } catch {
      print(error)
    }
  }

  func setCellValues(cell: FUIBaseTableViewCell, cellForRow row: Int, viewController: SectionedTableViewController) {
    // NO-OP
  }
}

// MARK: - KeyValue Section
public class KeyValueSection: CommonSection, CollectionLayoutable {

  var keyValues: [KeyValue] = []

  var collectionLayout: CollectionLayout

  override init(params: NSDictionary, callback: SectionDelegate) {
    self.collectionLayout = CollectionLayout(params)
    super.init(params: params, callback: callback)
  }

  override func setData(params: NSDictionary) {
    super.setData(params: params)

    do {
      self.keyValues.removeAll()
      let jsonKeyValues = (params["keyValues"] as? String)!
      if let items = try JSONSerialization.jsonObject(with: jsonKeyValues.data(using: .utf8)!, options: []) as? NSArray {
        for itemDict in (items as? [NSDictionary])! {
          let item: KeyValue = KeyValue(key: String(describing: itemDict.value(forKey: "key")!), value: String(describing: itemDict.value(forKey: "value")!))
          self.keyValues.append(item)
        }
      }

      self.maxItemCount = keyValues.count

      self.collectionLayout = CollectionLayout(params)

    } catch {
      print(error)
    }
  }

  func setCellValues(cell: SAPFiori.FUIKeyValueCollectionViewCell, cellForRow row: Int) {
    cell.keyName = (keyValues[row].key)
    cell.value = (keyValues[row].value)
  }
}

// MARK: - SimplePropertyCollection Section
public class SimplePropertyCollectionSection: CommonSection, CollectionLayoutable {

  public var items: [AnyObject] = []

  var collectionLayout: CollectionLayout

  override init(params: NSDictionary, callback: SectionDelegate) {
    self.collectionLayout = CollectionLayout(params)
    super.init(params: params, callback: callback)
  }

  override func setData(params: NSDictionary) {
    super.setData(params: params)

    do {
      let jsonItems = (params["items"] as? String)!
      if let items = try JSONSerialization.jsonObject(with: jsonItems.data(using: .utf8)!, options: []) as? [AnyObject] {
        self.items = items
        self.maxItemCount = self.items.count
      }

      self.collectionLayout = CollectionLayout(params)

    } catch {
      print(error)
    }
  }

  func setCellValues(cell: FUISimplePropertyCollectionViewCell, cellForRow row: Int) {
    if let params = self.items[row] as? NSDictionary {
      if let keyName = params["keyName"] {
        cell.keyName = String(describing: keyName)
      }
      if let value = params["value"] {
        cell.value = String(describing: value)
      }
      if let accessoryTypeParam = params["accessoryType"] as? String {
        cell.accessoryType = CommonSection.accessoryType(from: accessoryTypeParam)
      }
    }
  }
}

// MARK: - Extension Section
public class ExtensionSection: CommonSection {
  var contentHeight: CGFloat?

  public static var ExtensionSectionViewTag: Int {
    return 11022016
  }

  override init(params: NSDictionary, callback: SectionDelegate) {

    super.init(params: params, callback: callback)

    if let height = params["Height"] as? CGFloat {
      self.contentHeight = height
    }
  }
}

// MARK: - ContactCell Section
public class ContactCellSection: ObjectCellSection {
  public var items: [AnyObject] = []
  var tableView: UITableView?

  func setTableView(tableView: UITableView) {
    self.tableView = tableView
  }

  func setCellValues(cell: SAPFiori.FUIContactCell, cellForRow row: Int, viewController: SectionedTableViewController) {
    if let item = self.items[row] as? NSDictionary {
      ContactCell.configureContactCell(cell: cell, params: item, viewController: viewController)
    }
  }

  override func setData(params: NSDictionary) {
    super.setData(params: params)
    items = []
    do {
      let jsonItems = (params["items"] as? String)!
      if let items = try JSONSerialization.jsonObject(with: jsonItems.data(using: .utf8)!, options: []) as? [AnyObject] {
        self.items = items
        self.maxItemCount = self.items.count
      }
    } catch {
      print(error)
    }
  }
}

// MARK: - ObjectCell Section
public class ObjectCellSection: CommonSection {
  var search: Search

  override init(params: NSDictionary, callback: SectionDelegate) {
    self.search = Search(params: params)
    super.init(params: params, callback: callback)
  }

  override func setData(params: NSDictionary) {
    super.setData(params: params)

    if let maxItemCount = params["maxItemCount"] as? Int {
      self.maxItemCount = maxItemCount
    }
  }

  func getBoundData(row: Int) -> NSDictionary? {
    return self.callback.perform(NSSelectorFromString("getBoundData:"), with: row as NSNumber!)?.takeUnretainedValue() as? NSDictionary
  }

  override func bindItem(row: Int) -> Void {
    guard self.itemDict[row] != nil else {
      self.callback.perform(NSSelectorFromString("bindItem"), with: row as NSNumber!)
      return
    }
  }

  func configureObjectCell(cell: UIView, params: NSDictionary) {
    // No-op
  }

  func configureObjectCellProgressIndicator(cell: UIView, visible: Bool) {
    // No-op
  }

  // get the item or call setCellValues for existing item dictionary.
  func setCellValues(cell: UIView, cellForRow row: Int) {
    var item: NSDictionary?
    if let json = self.itemDict[row] {
      item = json
    } else if let json = self.getBoundData(row: row) {
      item = json
      self.itemDict[row] = json
    }

    if let jsonItem = item {
      self.configureObjectCell(cell: cell, params: jsonItem)
    }

    self.configureObjectCellProgressIndicator(cell: cell, visible:(item == nil))
  }
}

// MARK: - ObjectTable Section
public class ObjectTableSection: ObjectCellSection {
  var tableView: UITableView?

  func setTableView(tableView: UITableView) {
    self.tableView = tableView
  }

  override func configureObjectCell(cell: UIView, params: NSDictionary) {
    if let objCell = cell as? SAPFiori.FUIObjectTableViewCell {
      ObjectCell.configureObjectCell(cell: objCell, params: params)
      objCell.statusImageView.tintColor = UIColor.preferredFioriColor(forStyle: .critical)
    }
  }

  override func configureObjectCellProgressIndicator(cell: UIView, visible: Bool) {
    if let objectTableCell = cell as? FUIObjectTableViewCell {
      if visible {
        let progIndicatorFrame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let progIndicator = FUIProcessingIndicatorView(frame: progIndicatorFrame)
        progIndicator.startAnimating()
        progIndicator.show()
        objectTableCell.accessoryView = progIndicator
      } else {
        if let progIndicator = objectTableCell.accessoryView as? FUIProcessingIndicatorView {
          progIndicator.stopAnimating()
          progIndicator.dismiss()
          // We have to completely take it out so that the configured accessoryType is shown
          objectTableCell.accessoryView = nil
        }
      }
    }
  }

  public func loadMoreItems() {
    self.callback.perform(NSSelectorFromString("loadMoreItems"))
  }

  @objc public func setIndicatorState(params: NSDictionary) {
    if let objectTableCell = params["cell"] as? FUIObjectTableViewCell, let state = params["state"] as? String {
      ObjectCell.setIndicatorState(cell: objectTableCell, indicatorState: state)
    }
  }
}

// MARK: - ObjectCollection Section
public class ObjectCollectionSection: ObjectCellSection, CollectionLayoutable {
  var usesExtensions: Bool = false

  var collectionLayout: CollectionLayout

  override init(params: NSDictionary, callback: SectionDelegate) {

    self.collectionLayout = CollectionLayout(params)

    super.init(params: params, callback: callback)

    if let useExtensions = params["Uses_Extensions"] as? Bool {
      self.usesExtensions = useExtensions
    }
  }

  override func configureObjectCell(cell: UIView, params: NSDictionary) {
    if let objCell = cell as? SAPFiori.FUIObjectCollectionViewCell {
      ObjectCollectionCell.configureObjectCollectionCell(cell: objCell, params: params)
      objCell.substatusImageView.tintColor = UIColor.preferredFioriColor(forStyle: .negative)
    }
  }
}

// MARK: - ObjectHeader Section
/// ObjectHeaderSection that appears at the top of the page
public class ObjectHeaderSection: ObjectCellSection {
  public var items: [AnyObject] = []
  var fuiObjectHeader: FUIObjectHeader?
  // setData is called before initialize so we need to cache headerData
  var headerData: Dictionary<String, Any> = [:]

  /**
   Sets new data in the FUIObjectHeader instance
   - parameters:
    - data: The new header data to display
   */
  @objc override public func redraw(data: NSDictionary) {
    // reset the headerData
    setData(params: data)
  }

  @objc public override func reloadData(itemCount: Int) {
    // NO-OP
  }

  @objc public override func reloadRow(index: Int) {
    // NO-OP
  }

  /// rebuilds the header data
  override func setData(params: NSDictionary) {
    // call super to fill in self.items
    super.setData(params: params)
    items = []
    do {
      let jsonItems = (params["items"] as? String)!
      if let items = try JSONSerialization.jsonObject(with: jsonItems.data(using: .utf8)!, options: []) as? [AnyObject] {
        self.items = items
      }
    } catch {
      print(error)
    }

    // reset headerData
    headerData.removeAll()
    // initalize headerData
    for item in self.items {
      if let property = item as? Dictionary<String, Any> {
        for (key, var value) in property {
          if key == "DetailContentContainer" && (value as? Bool)! {
            if let view = getView() {
              value = view
            }
          }
          headerData.updateValue(value, forKey: key)
        }
      }
    }

    updateHeaderData()
  }

  /**

   Initializes an ObjectHeaderSection with a FUIObjectHeader and applies the
   headerData
   - parameters:
    - objectHeader: The FUIObjectHeader instance passed in from the controller
   */
  func setObjectHeader(_ objectHeader: FUIObjectHeader) {
    // set the fuiObjectHeader instance
    fuiObjectHeader = objectHeader
    // now the headerData can be updated
    updateHeaderData()
  }

  /// Updates the data in the fuiObjectHeader instance
  func updateHeaderData() {

    // first time through this method fuiObjectHeader isn't set
    // (i.e. wait for setObjectHeader to be called)
    guard let objectHeader = fuiObjectHeader else {
      return
    }

    ObjectHeader.setObjectHeader(objectHeader, withParams: headerData)
  }
}

// MARK: - Button Section
public class ButtonSection: FUIViewSection {
  override func setCellValues(cell: FUIBaseTableViewCell, cellForRow row: Int, viewController: SectionedTableViewController) {
    if let buttonMetadata = self.items[row] as? Dictionary<String, Any> {
      let btn = FUIButtonWrapper(row: row, containerCell: cell)
      btn.configure(withMetadata: buttonMetadata)
      btn.addTarget(self, action: #selector(buttonSectionAction), for: .touchUpInside)
      // Remove existing view if there is one
      cell.contentView.viewWithTag(FUIButtonWrapper.FUIButtonWrapperTag)?.removeFromSuperview()
      cell.contentView.addSubview(btn)
    }
  }

  @objc private func buttonSectionAction(_ sender: FUIButtonWrapper) {
    let indexPath = self.tableView?.indexPath(for: sender.containerCell)
    onPressCallback(cell: sender.cellRow, view: sender.containerCell)
    self.tableView?.deselectRow(at: indexPath!, animated: false)
  }
}
