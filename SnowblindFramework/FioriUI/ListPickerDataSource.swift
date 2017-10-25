//
//  ListPickerDelegate.swift
//  SAPMDC
//
//  Copyright © 2017 SAP. All rights reserved.
//

// TODO: These data structures (they are unused here) should really live in Core
// that way there is no need to re-implement them for other platforms. Consider
// bridge hopping cost when doing that ...

class ListPickerDataItem {

  let uniqueId: String
  let displayValue: String

  init(_ uniqueId: String, _ displayValue: String) {
    self.uniqueId = uniqueId
    self.displayValue = displayValue
  }
}

class ListPickerSelectedDataItem: ListPickerDataItem {

  let isPartOfFilteredData: Bool

  init(_ uniqueId: String, _ displayValue: String, _ isPartOfFilteredData: Bool) {
    self.isPartOfFilteredData = isPartOfFilteredData
    super.init(uniqueId, displayValue)
  }
}

class ListPickerData {

  var data: [ListPickerDataItem] = []
  var dataDict: [String:ListPickerDataItem] = [:]

  var count: Int {
    return self.data.count
  }

  init(_ from: [NSDictionary]) {
    for item in from {
      if let uniqueId = item["UniqueId"] as? String,
        let displayValue = item["DisplayValue"] as? String {

        let lpItem = ListPickerDataItem(uniqueId, displayValue)
        self.data.append(lpItem)
        self.dataDict[lpItem.uniqueId] = lpItem
      }
    }
  }

  func displayValueForItemAt(_ index: Int) -> String {
    return self.data[index].displayValue
  }

  func displayValueForItemWithUniqueId(_ uniqueId: String) -> String {
    return self.dataDict[uniqueId]!.displayValue
  }
}

import Foundation
import SAPFiori

// This is the implementation of the delegate required by the Fiori SDK for
// their ListPickers data sources and search handlers

public class ListPickerDataSource: NSObject, FUIListPickerDataSource, FUIListPickerSearchResultsUpdating, UISearchBarDelegate {
  private var name: String // #andytodo: remove, for debug only

  private var data: [NSDictionary]

  private var selectedData: [NSDictionary]

  private var delegate: FormCellItemDelegate

  var isInFilteredMode: Bool {
    return !self.search.searchString.isEmpty
  }
  var search: Search

  public init(name: String, data: [NSDictionary], initiallySelectedData: [NSDictionary], delegate: FormCellItemDelegate, search: Search) {
    self.name = name
    self.data = data
    self.selectedData = initiallySelectedData
    self.delegate = delegate
    self.search = search
  }

  public func update(data: [NSDictionary]) {
    self.data = data
  }

  // MARK: - FUIListPickerDataSource

  public func numberOfRows() -> Int {
    return self.data.count
  }

  // TODO: change with new SDK interface to use UUID
  public func listPickerTableView(_ tableView: UITableView, cellForRowAt index: Int, isFiltered: Bool) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
    let dict = self.data[index] as NSDictionary
    if let displayValue = dict["DisplayValue"] {
      cell.textLabel?.text = String(describing: displayValue)
    }

    if index == self.data.count - 1 {
      DispatchQueue.main.async {
        self.delegate.perform(NSSelectorFromString("loadMoreItems"))
      }
    }

    return cell
  }

  public func listPickerTableView(_ tableView: UITableView, cellForItemWithUniqueIdentifier uniqueIdentifier: String) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!

    // #andytodo: this is very ineficient specially as the list grows
    // change this so that it's done with O(1) no matter where the item
    // is by creating a better data structure for the data ...
    for dataItem in self.data {
      if let uid = dataItem["UniqueId"] as? String {
        if uid == uniqueIdentifier {
          if let text = dataItem["DisplayValue"] as? String {
            cell.textLabel?.text = text
          }
        }
      }
    }

    return cell
  }

  public func listPickerTableView(_ tableView: UITableView, uniqueIdentifierForItemAt index: Int) -> String {
    return self.data[index]["UniqueId"] as? String ?? ""
  }

  public func listPickerTableView(_ tableView: UITableView, indexForUniqueIdentifier uniqueIdentifier: String) -> Int {

    var index = -1

    // #andytodo: this is very ineficient specially as the list grows
    // change this so that it's done with O(1) no matter where the item
    // is by creating a better data structure for the data ...
    for (i, dataItem) in self.data.enumerated() {
      if let uid = dataItem["UniqueId"] as? String {
        if uid == uniqueIdentifier {
          index = i
          break
        }
      }
    }

    return index
  }

  // MARK: - FUIListPickerSearchResultsUpdating

  public func listPicker(_ listPicker: FUIListPicker, updateSearchResults forSearchString: String) {
    self.search.schedule(searchString: forSearchString, target: self, selector: #selector(callSearchCallback))
  }

  @objc public func callSearchCallback(sender: Timer) {
    if let userInfo = sender.userInfo as? [String:Any], let searchSting: String = userInfo["searchString"] as? String {
      delegate.perform(NSSelectorFromString("searchUpdated"), with:searchSting)
    }
  }

  // MARK: - UISearchBarDelegate methods

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    if let searchString = searchBar.text {
      self.search.immediateSearch(searchString: searchString, target: self, selector: #selector(callSearchCallback))
    }
  }

  public func listPicker(_ listPicker: FUIListPicker, filteredDataSourceContainsItemWithUniqueIdentifier uniqueIdentifier: String) -> Bool {

    // this will only be called for selected items

    guard self.isInFilteredMode else {
      return false
    }

    // HACK: there is currently no way for us to get current selections or be notified
    // when these change. We are only notified on self.cell.uuidValues after the list
    // picker is closed and done. So: we will keep track of things that are selected
    // through the calls to this method and do the filter check on its data on the UI
    // for now we can get the selection changes as they happen and send them to core
    // to do the checking there

    // TODO: Move this to core

    for dataItem in self.selectedData {
      if let uid = dataItem["UniqueId"] as? String {
        if uid == uniqueIdentifier {
          // We have a cached values for this item (see HACK note above)
          return self._dataItemMatchesSearchString(dataItem)
        }
      }
    }

    for dataItem in self.data {
      if let uid = dataItem["UniqueId"] as? String,
        let displayValue = dataItem["DisplayValue"] as? String {
        if uid == uniqueIdentifier {
          let dataItem = NSDictionary(dictionary: [
            "UniqueId": uid,
            "DisplayValue": displayValue
          ])
          self.selectedData.append(dataItem)
          return self._dataItemMatchesSearchString(dataItem)
        }
      }
    }

    return false
  }

  private func _dataItemMatchesSearchString(_ dataItem: NSDictionary) -> Bool {
    if let uid = dataItem["UniqueId"] as? String,
      let displayValue = dataItem["DisplayValue"] as? String {
      let matches = displayValue.localizedCaseInsensitiveContains(self.search.searchString) || uid.localizedCaseInsensitiveContains(self.search.searchString)
      return matches
    }
    return false
  }
}
