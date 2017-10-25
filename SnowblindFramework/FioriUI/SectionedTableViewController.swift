//
//  SectionedTableViewController.swift
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/6/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import UIKit
import SAPFiori
import MessageUI

// swiftlint:disable file_length
// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity

public class SectionedTableViewController: UITableViewController, FullScreenTableViewControllerTraits,
  UICollectionViewDataSource, UICollectionViewDelegate, UISearchResultsUpdating, UISearchBarDelegate,
MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

  var sections: [CommonSection] = []
  var objectHeader: ObjectHeaderSection?
  let searchController = FUISearchController(searchResultsController: nil)
  let extensionReuseID: String = "ExtensionCell"

  // Global design states 30, so splitting the pads equally
  // https://experience.sap.com/fiori-design-ios/article/grid-design/#divider
  let defaultSectionHeaderPadding: CGFloat = 15.0
  let defaultSectionFooterPadding: CGFloat = 15.0

  // Measured in Xcode using the UI Hierarchy, this will have to change if the SDK changes
  // If this is incorrect, it might not always be obvious
  let expectedSectionHeaderHeight: CGFloat = 38.0
  let expectedSectionFooterHeight: CGFloat = 44.5

  // The side margins of the table views should be 48 points according
  // to Global Design for both landscape and portrait
  let defaultSideMargin: CGFloat = 48.0

  @objc public func initialize(_ sections: NSArray) {
    for section in sections {
      if section is ObjectHeaderSection {
        objectHeader = section as? ObjectHeaderSection
      } else {
        self.sections.append((section as? CommonSection)!)
      }
    }
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.onFullScreenTableViewControllerAppeared()
    // Pass viewDidAppear call only if an ObjectTableSection is in use.
    if self.sections.count == 1, self.sections[0] as? ObjectTableSection != nil {
      self.sections[0].callback.viewDidAppear()
    }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.onFullScreenTableViewControllerLoaded()

    self.tableView.estimatedRowHeight = 98
    self.tableView.rowHeight = UITableViewAutomaticDimension
    // As per design spec
    self.tableView.tintColor = UIColor.preferredFioriColor(forStyle: .tintColorDark)
    // Assume the most common case will have a label and padding
    self.tableView.estimatedSectionHeaderHeight = defaultSectionHeaderPadding + expectedSectionHeaderHeight
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension

    // Assume the most common case will have a label and padding
    self.tableView.estimatedSectionFooterHeight = defaultSectionFooterPadding + expectedSectionFooterHeight
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension

    // Margin according to Global Design
    // This needs to be set after the estimated heights are set otherwise there are
    // estra spaces left at the top and bottom of the table.
    self.tableView.cellLayoutMarginsFollowReadableWidth = false
    self.tableView.layoutMargins = UIEdgeInsets(top: 0.0, left: defaultSideMargin, bottom: 0.0, right: defaultSideMargin)

    self.tableView.register(FUITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: FUITableViewHeaderFooterView.reuseIdentifier)
    self.tableView.register(HelpSectionFooterView.self, forHeaderFooterViewReuseIdentifier: HelpSectionFooterView.reuseIdentifier)
    self.tableView.register(EmptySectionTableViewCell.self, forCellReuseIdentifier: EmptySectionTableViewCell.reuseIdentifier)

    for tableSection in self.sections {
      if tableSection is ObjectTableSection {
        self.tableView.register(FUIObjectTableViewCell.self, forCellReuseIdentifier: FUIObjectTableViewCell.reuseIdentifier)
        (tableSection as? ObjectTableSection)!.setTableView(tableView: self.tableView)
      } else if tableSection is ExtensionSection {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.extensionReuseID)
      } else if tableSection is ContactCellSection {
        self.tableView.register(FUIContactCell.self, forCellReuseIdentifier: FUIContactCell.reuseIdentifier)
        (tableSection as? ContactCellSection)!.setTableView(tableView: self.tableView)
      } else if tableSection is FUIViewSection {
        var reuseIdentifier: String = ""

        if tableSection is ButtonSection {
          reuseIdentifier = FUIButtonWrapper.reuseIdentifier
        }
        self.tableView.register(FUIBaseTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
      } else {
        let section = FUITableViewCollectionSection(tableView: self.tableView)
        section.collectionView.dataSource = self
        section.collectionView.delegate = self
        section.collectionView.isScrollEnabled = false
        if let tableSection = tableSection as? KeyValueSection {
          let layout = FUICollectionViewLayout.keyValueColumnFlow
          tableSection.collectionLayout.applyTo(layout: layout)
          section.collectionView.collectionViewLayout = layout
          section.collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
          section.collectionView.register(FUIKeyValueCollectionViewCell.self, forCellWithReuseIdentifier: FUIKeyValueCollectionViewCell.reuseIdentifier)
          // We don't support click actions on KeyValueSections
          section.collectionViewTableViewCell.isUserInteractionEnabled = false
        } else if let collectionSection = tableSection as? ObjectCollectionSection {
          // It is an ObjectCollection section
          if collectionSection.usesExtensions {
            section.collectionView.register(ExtensionCollectionViewCell.self, forCellWithReuseIdentifier: ExtensionCollectionViewCell.reuseIdentifier)
            let layout = FUICollectionViewLayout.horizontalFlow
            layout.minimumScaledItemSize = CGSize(width: 100, height: 100)
            if let numOfColumns = collectionSection.collectionLayout.numberOfColumns {
              layout.numberOfColumns = numOfColumns
            }
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            section.collectionView.collectionViewLayout = layout
          } else {
            section.collectionView.register(FUIObjectCollectionViewCell.self, forCellWithReuseIdentifier: FUIObjectCollectionViewCell.reuseIdentifier)
            let layout = FUIStandardAutoSizingColumnFlowLayout()
            collectionSection.collectionLayout.applyTo(layout: layout)
            section.collectionView.collectionViewLayout = layout
          }
        } else if let collectionSection = tableSection as? SimplePropertyCollectionSection {
          // It is a SimplePropertyCollection section
          section.collectionView.register(FUISimplePropertyCollectionViewCell.self, forCellWithReuseIdentifier: FUISimplePropertyCollectionViewCell.reuseIdentifier)

          let layout = FUIStandardAutoSizingColumnFlowLayout()
          collectionSection.collectionLayout.applyTo(layout: layout)
          section.collectionView.collectionViewLayout = layout
        }
        tableSection.collectionSection = section
      }

      tableSection.parentTable = self
    }

    if let objHeader = self.objectHeader {
      let objectHeader: FUIObjectHeader? = FUIObjectHeader(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 300 ))
      objHeader.setObjectHeader(objectHeader!)
      self.tableView.tableHeaderView = objectHeader
    } else if self.sections.count == 1, let section = self.sections[0] as? ObjectTableSection {
      // If there is one section, it is an ObjectCellSection, and it has search enabled, set up search
      if section.search.enabled {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholderText = section.search.placeholder

        if section.search.barcodeScanner {
          searchController.searchBar.isBarcodeScannerEnabled = true
        }
        self.tableView.tableHeaderView = searchController.searchBar
      }
    }
  }

  // MARK: - UITableViewDataSource methods
  override public func numberOfSections(in tableView: UITableView) -> Int {
    return self.sections.count
  }

  override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let mSection = self.sections[section]
    if mSection.isSectionEmpty() && mSection.usesEmptySectionRow() {
      return 1
    }
    if mSection.collectionSection != nil && !mSection.isSectionEmpty() {
      return 1
    }
    return mSection.maxItemCount
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = self.sections[indexPath.section]

    if section.isSectionEmpty() && section.usesEmptySectionRow() {
      if let cell = tableView.dequeueReusableCell(withIdentifier: EmptySectionTableViewCell.reuseIdentifier) as? EmptySectionTableViewCell {
        cell.captionLabel.text = section.emptySectionCaption
        if let style = section.emptySectionStyle {
          cell.captionLabel.nuiClass = style
        }
        return cell
      }
    }

    if section is ObjectTableSection {
      // The TableSection uses this delegate. The CollectionSection uses the other one ;)
      let objectTableSectionData = (section as? ObjectTableSection)!
      let cell = (tableView.dequeueReusableCell(withIdentifier: FUIObjectTableViewCell.reuseIdentifier) as? FUIObjectTableViewCell)!
      cell.isUserInteractionEnabled = true
      objectTableSectionData.setCellValues(cell: cell, cellForRow: indexPath.row)
      if indexPath.row != (section.maxItemCount-1) {
        cell.separators = .bottom
        // When the tableView's layoutMargins are set, the right margin of the separators is lost, so we reset it here
        cell.separatorInset = UIEdgeInsets(top: 0, left: defaultSideMargin, bottom: 0, right: defaultSideMargin)
      } else {
        cell.separators = []
      }
      return cell
    } else if section is ContactCellSection {
      let contactCellSectionData = (section as? ContactCellSection)!
      let cell = (tableView.dequeueReusableCell(withIdentifier: FUIContactCell.reuseIdentifier, for: indexPath) as? FUIContactCell)!
      contactCellSectionData.setCellValues(cell: cell, cellForRow: indexPath.row, viewController: self)
      if indexPath.row != (section.maxItemCount-1) {
        cell.separators = .bottom
        // When the tableView's layoutMargins are set, the right margin of the separators is lost, so we reset it here
        cell.separatorInset = UIEdgeInsets(top: 0, left: defaultSideMargin, bottom: 0, right: defaultSideMargin)
      } else {
        cell.separators = []
      }
      return cell
    } else if section is ExtensionSection {
      let cell = (tableView.dequeueReusableCell(withIdentifier: self.extensionReuseID))
      cell?.contentView.autoresizesSubviews = true
      if let view = section.getView() {
        // SNOWBLIND-4547: iOS 11 made changes to auto layouts.  If we are on iOS 11 or above, we need to turn this off
        // so margins outside the "safe area" are not automatically modified.
        if #available(iOS 11.0, *) {
          cell?.contentView.insetsLayoutMarginsFromSafeArea = false
          view.insetsLayoutMarginsFromSafeArea = false
        }

        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = (cell?.contentView.frame)!
        view.tag = ExtensionSection.ExtensionSectionViewTag
        // Remove existing view if there is one
        cell?.contentView.viewWithTag(ExtensionSection.ExtensionSectionViewTag)?.removeFromSuperview()
        cell?.contentView.addSubview(view)
      }
      return cell!
    } else if section is FUIViewSection {
      var reuseIdentifier: String = ""

      if section is ButtonSection {
        reuseIdentifier = FUIButtonWrapper.reuseIdentifier
      }

      let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? FUIBaseTableViewCell
      cell?.contentView.autoresizesSubviews = true

      // set the cell's separators correctly (hide the top for the first and use a single line from one side of the screen to the other)
      if indexPath.row != (section.maxItemCount-1) {
        cell?.separators = .bottom
        cell?.separatorInset = .zero
      } else {
        cell?.separators = []
      }

      (section as? FUIViewSection)?.setCellValues(cell: cell!, cellForRow: indexPath.row, viewController: self)

      return cell!
    } else {
      if let section = section.collectionSection {
        let cell = section.collectionViewTableViewCell
        cell.separators = []
        return cell
      }
    }
    return UITableViewCell()
  }

  override public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let sectionType = self.sections[indexPath.section]
    if sectionType is ObjectTableSection {
      if indexPath.row == (sectionType.maxItemCount - 1) {
        let objectTableSection = (sectionType as? ObjectTableSection)!
        objectTableSection.loadMoreItems()
      }
    }
  }

  override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let mySection: CommonSection = sections[indexPath.section]
    let cell: Int = indexPath.row
    if !(mySection is ObjectHeaderSection) && !(mySection is ContactCellSection) && !(mySection is ButtonSection) {
      // there's no callback for ObjectHeaderSections, ContactCellSection or ButtonSection
      mySection.onPressCallback(cell: cell, view: tableView.cellForRow(at: indexPath)!)
      tableView.deselectRow(at: indexPath, animated: false)
    }
  }

  public override func tableView(_ tableView: UITableView, viewForHeaderInSection sectionIndex: Int) -> UIView? {

    let section = self.sections[sectionIndex]

    if section.usesHeader {

      if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FUITableViewHeaderFooterView.reuseIdentifier) as? FUITableViewHeaderFooterView {

        if let headerStyle = section.headerStyle {
          headerView.style = headerStyle

          if headerStyle == .attribute {
            headerView.attributeLabel.text = section.headerAttributeLabel
          }
        } else {
          // The default style
          headerView.style = .title
        }

        if tableView.numberOfRows(inSection: sectionIndex) == 0 {
          // no rows here...don't show divider
          headerView.separators = []
        } else {
          headerView.separators = .bottom
        }
        headerView.titleLabel.text = section.headerTitle

        // Add appropiate Top Padding
        var calcTopPadding: CGFloat = 0
        if section.useHeaderTopPadding {
          // Use the default padding, except if it's the first section
          // For the first section add the default footer padding to fill in the missing footer
          // Note that the footer was used instead of 2 * header in case the header/footer isn't equal
          calcTopPadding = sectionIndex == 0 ? defaultSectionHeaderPadding + defaultSectionFooterPadding : defaultSectionHeaderPadding
        }

        // If this was configured, the designer is in control; otherwise use defaults
        headerView.topPadding = section.topPadding ?? calcTopPadding

        headerView.didSelectHandler  = {
          // no-op
        }

        return headerView
      }
    }

    return nil
  }

  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let headerTopPadding: CGFloat = self.sections[section].topPadding ?? defaultSectionHeaderPadding
    let footerBottomPadding: CGFloat = self.sections[section].bottomPadding ?? defaultSectionFooterPadding
    var height: CGFloat = 0

    if self.sections[section].useHeaderTopPadding {
      height += headerTopPadding

      // Account for the first section by adding the footer padding
      // Intentionally not setting footerBottomPadding to zero if .usesBottomPadding is false
      // If checking for .usesBottomPadding, can create a scenario where there is less control on the
      // spcaing between items. This problem will go away if support .topPadding/.bottomPadding values from metadata
      if section == 0 {
        height += footerBottomPadding
      }
    }

    if self.sections[section].usesHeader {
      height += expectedSectionHeaderHeight
    }
    return height
  }

  public override func tableView(_ tableView: UITableView, viewForFooterInSection sectionIndex: Int) -> UIView? {

    let section = self.sections[sectionIndex]

    if section.usesFooter {

      // Calculate the appropiate Bottom Padding
      var calcBottomPadding: CGFloat = 0
      if section.useFooterBottomPadding {
        // Use the default padding, except if it's the last section
        // For the last section add the default header padding to fill in the missing header
        // Note that the header was used instead of 2 * footer in case the header/footer isn't equal
        calcBottomPadding = sectionIndex == (self.sections.count - 1) ? defaultSectionFooterPadding + defaultSectionHeaderPadding : defaultSectionFooterPadding
      }

      // If this was configured, the designer is in control; otherwise use defaults
      calcBottomPadding = section.bottomPadding ?? calcBottomPadding

      if let footerStyle = section.footerStyle.toFUIFooterStyle() {

        // This is a footer style supported by FioriUI ('attribute' or 'title')

        if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FUITableViewHeaderFooterView.reuseIdentifier) as? FUITableViewHeaderFooterView {

          footerView.style = footerStyle
          if footerStyle == .attribute {
            footerView.attributeLabel.text = section.footerAttributeLabel
          }

          footerView.separators = .top
          footerView.titleLabel.text = section.footerTitle
          footerView.isDisclosureAccessoryHidden = section.isDisclosureAccessoryHidden

          footerView.didSelectHandler = {
            section.footerTapCallback()
          }

          footerView.bottomPadding = calcBottomPadding
          return footerView
        }

      } else if section.footerStyle == .help {

        // Non FioriUI footer style 'help'

        if let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HelpSectionFooterView.reuseIdentifier) as? HelpSectionFooterView {

          footerView.text = section.footerTitle
          footerView.bottomPadding = calcBottomPadding
          return footerView
        }
      }
    }

    return nil
  }

  public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    let headerTopPadding: CGFloat = self.sections[section].topPadding ?? defaultSectionHeaderPadding
    let footerBottomPadding: CGFloat = self.sections[section].bottomPadding ?? defaultSectionFooterPadding
    var height: CGFloat = 0

    if self.sections[section].useFooterBottomPadding {
      height += footerBottomPadding

      // Account for the last section by adding the header padding
      // Intentionally not setting headerTopPadding to zero if .usesTopPadding is false
      if section == (self.sections.count - 1) {
        height += headerTopPadding
      }
    }

    if self.sections[section].usesFooter {
      height += expectedSectionFooterHeight
    }

    return height
  }

  // MARK: - FUITableViewCollectionSectionDataSource ( UICollectionViewDataSource )
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let section = sectionFor(collectionView: collectionView) {
      if let collectionSection = section as? KeyValueSection {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: FUIKeyValueCollectionViewCell.reuseIdentifier, for: indexPath) as? FUIKeyValueCollectionViewCell)!
        collectionSection.setCellValues(cell: cell, cellForRow: indexPath.row)
        cell.valueTextView.dataDetectorTypes = []
        return cell
      } else if let collectionSection = section as? ObjectCollectionSection {
        if collectionSection.usesExtensions {
          let cell: ExtensionCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: ExtensionCollectionViewCell.reuseIdentifier,
                               for: indexPath) as? ExtensionCollectionViewCell)!
          if let view = collectionSection.getView(row: indexPath.row) {
            cell.setupView(view: view)
            return cell
          }
        } else {
          let cell: FUIObjectCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: FUIObjectCollectionViewCell.reuseIdentifier,
                               for: indexPath) as? FUIObjectCollectionViewCell)!
          collectionSection.setCellValues(cell: cell, cellForRow: indexPath.row)

          // By default, there are two columns, so we start using borders after the
          // second cell
          var firstCellWithBorders: Int = 2
          if let numberOfColumns = collectionSection.collectionLayout.numberOfColumns {
            firstCellWithBorders = numberOfColumns
          }
          if indexPath.item >= firstCellWithBorders {
            cell.borders = .top
          }

          return cell
        }
      } else if let collectionSection = section as? SimplePropertyCollectionSection {
        let cell: FUISimplePropertyCollectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: FUISimplePropertyCollectionViewCell.reuseIdentifier,
                             for: indexPath) as? FUISimplePropertyCollectionViewCell)!
        collectionSection.setCellValues(cell: cell, cellForRow: indexPath.row)

        // By default, there are two columns, so we start using borders after the
        // second cell
        var firstCellWithBorders: Int = 2
        if let numberOfColumns = collectionSection.collectionLayout.numberOfColumns {
          firstCellWithBorders = numberOfColumns
        }
        if indexPath.item >= firstCellWithBorders {
          cell.borders = .top
        }
        cell.valueTextField.isEnabled = false
        return cell
      }
    }
    return UICollectionViewCell()
  }

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let section = sectionFor(collectionView: collectionView) {
      return section.maxItemCount
    }
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let section = sectionFor(collectionView: collectionView) {
      guard let collSection: FUITableViewCollectionSection = section.collectionSection else {
        return
      }
      guard let view = collSection.collectionViewTableViewCell as UITableViewCell? else {
        return
      }
      section.onPressCallback(cell: indexPath.row, view: view)
    }
  }

  // MARK: - UISearchResultsUpdating methods

  public func updateSearchResults(for searchController: UISearchController) {
    if let searchString = searchController.searchBar.text, let section: ObjectTableSection = self.sections[0] as? ObjectTableSection {
      section.search.schedule(searchString: searchString, target: self, selector: #selector(callSearchCallback))
    }
  }

  @objc public func callSearchCallback(sender: Timer) {
    let delegate = self.sections[0].callback
    if let userInfo = sender.userInfo as? [String:Any], let searchSting: String = userInfo["searchString"] as? String {
      delegate.perform(NSSelectorFromString("searchUpdated"), with: searchSting)
    }
  }

  // MARK: - UISearchBarDelegate methods

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    if let searchString = searchBar.text, let section: ObjectTableSection = self.sections[0] as? ObjectTableSection {
      section.search.immediateSearch(searchString: searchString, target: self, selector: #selector(callSearchCallback))
    }
  }

  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let mySection = sections[indexPath.section] as? ExtensionSection, let height = mySection.contentHeight {
      let extensionIndex = 0
      if indexPath.row == extensionIndex {
        return height
      }
    }
    return super.tableView(tableView, heightForRowAt: indexPath)
  }

  public func reloadSection(section: CommonSection) {
    let indexSet: IndexSet = [self.sections.index(of: section)!]
    self.tableView.reloadSections(indexSet, with: .none)
  }

  private func sectionFor(collectionView view: UICollectionView) -> CommonSection? {
    for section in self.sections {
      if let fuiColSec = section.collectionSection {
        if fuiColSec.collectionView == view {
          return section
        }
      }
    }
    return nil
  }

  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  // MARK: - Contact Cell delegate methods

  public func call(phoneNumber: String, callType: String) {
    guard callType == "Phone" || callType == "FaceTime" else {
      return
    }
    let URLString: String
    if callType == "Phone" {
      URLString = "tel://\(phoneNumber)"
    } else {
      URLString = "facetime://\(phoneNumber)"
    }
    if let callURL = URL(string: URLString) {
      let application: UIApplication = UIApplication.shared
      if application.canOpenURL(callURL) {
        application.open(callURL, options: [:], completionHandler: nil)
      }
    }
  }

  public func sendSMSText(phoneNumber: String) {
    if MFMessageComposeViewController.canSendText() {
      let controller = MFMessageComposeViewController()
      controller.body = ""
      controller.recipients = [phoneNumber]
      controller.messageComposeDelegate = self
      self.present(controller, animated: true, completion: nil)
    } else {
      showAlert(title: "Error", message: "Text Messaging is not supported")
    }
  }

  public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    self.dismiss(animated: true, completion: nil)
  }

  public func sendEmail(emailRecipient: String) {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients([emailRecipient])
      mail.setMessageBody("", isHTML: true)
      self.present(mail, animated: true)
    } else {
      showAlert(title: "Error", message: "Sending emails is not supported")
    }
  }

  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }

  public func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}

extension UIView {
  /// Adds constraints to the superview so that this view has same size and position.
  /// Note: This fails the build if the `superview` is `nil` – add it as a subview before calling this.
  func bindEdgesToSuperview() {
    guard let superview = superview else {
      preconditionFailure("`superview` was nil – call `addSubview(view: UIView)` before calling `bindEdgesToSuperview()` to fix this.")
    }
    translatesAutoresizingMaskIntoConstraints = false
    ["H:|-0-[subview]-0-|", "V:|-0-[subview]-0-|"].forEach { visualFormat in
      superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: visualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
  }
}
