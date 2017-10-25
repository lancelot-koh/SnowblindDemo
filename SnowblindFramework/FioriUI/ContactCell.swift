//
//  ContactCellFactory.swift
//  SAPMDCFramework
//
//  Created by Chitania, Pathik on 3/14/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori
import MessageUI

// Contact cell has a detailimage, 3 labels (headlinetext, subheadlinetext and description(shown only in landscape mode)
// Contact cell also has an actiivty control, which is an array of activityitems of type phone, message,email, videocall or detail)
// Each activity item has an image and action associated with it when selected. The contact cell can only have 3 activity items
// atmost. If the detailimage is not present, then 4 activity items can be shown.

public class ContactCell: NSObject {

  public private(set) static var activitiesTuple: [(item: FUIActivityItem, value: String)] = []

  public static func configureContactCell(cell: FUIContactCell, params: NSDictionary, viewController: SectionedTableViewController) {

    if let headlineText = params["Headline"] {
      cell.headlineText = String(describing: headlineText)
    }
    if let subheadlineText = params["Subheadline"] {
      cell.subheadlineText = String(describing: subheadlineText)
    }
    if let descriptionText = params["Description"] {
      cell.descriptionText = String(describing: descriptionText)
    }
    if let detailImage = params["DetailImage"] as? String, let uiImage = ImagePathHandler.image(from: detailImage) {
      cell.detailImage = FUIImageView(image: uiImage).image
    }

    if let activityItemParams = params["ActivityItems"] as? [Dictionary<String, String>] {
      setActivityControl(cell: cell, params: activityItemParams)
      setActivitySelectedHandler(cell: cell, viewController: viewController)
    }
  }

  private static func setActivityControl(cell: FUIContactCell, params: [Dictionary<String, String>]) {
    //if detail image is present, the max activities we can show is 3 otherwise 4
    let maxActivityCount = (cell.detailImage != nil) ? 3 : 4
    var activities: [FUIActivityItem] = []
    for i in 0..<params.count {
      guard i < maxActivityCount else {
        break
      }
      let activity = params[i]
      switch activity["ActivityType"]! {
      case "Phone":
        activitiesTuple.append((item: FUIActivityItem.phone, value: activity["ActivityValue"]!))
        activities.append(FUIActivityItem.phone)
      case "Email":
        activitiesTuple.append((item: FUIActivityItem.email, value: activity["ActivityValue"]!))
        activities.append(FUIActivityItem.email)
      case "Message":
        activitiesTuple.append((item: FUIActivityItem.message, value: activity["ActivityValue"]!))
        activities.append(FUIActivityItem.message)
      case "VideoCall":
        activitiesTuple.append((item: FUIActivityItem.videoCall, value: activity["ActivityValue"]!))
        activities.append(FUIActivityItem.videoCall)
      case "Detail":
        activitiesTuple.append((item: FUIActivityItem.detail, value: activity["ActivityValue"]!))
        activities.append(FUIActivityItem.detail)
      default:
        break
      }
    }
    cell.activityControl.addActivities(activities)
  }

  private static func setActivitySelectedHandler(cell: FUIContactCell, viewController: SectionedTableViewController) {
    // Called when the user clicks on the activity item
    cell.onActivitySelectedHandler = { activityItem in
      switch activityItem {
      case FUIActivityItem.phone:
        viewController.call(phoneNumber: getActivityValue(activityItem: activityItem), callType: "Phone")
        break
      case FUIActivityItem.message:
        viewController.sendSMSText(phoneNumber: getActivityValue(activityItem: activityItem))
        break
      case FUIActivityItem.videoCall:
        viewController.call(phoneNumber: getActivityValue(activityItem: activityItem), callType: "FaceTime")
        break
      case FUIActivityItem.email:
        viewController.sendEmail(emailRecipient: getActivityValue(activityItem: activityItem))
        break
      case FUIActivityItem.detail:
        viewController.showAlert(title: "Info", message: getActivityValue(activityItem: activityItem))
        break
      default:
        break
      }
    }
  }

  private static func getActivityValue(activityItem: FUIActivityItem) -> String {
    for activity in activitiesTuple where activity.item == activityItem {
      return activity.value
    }
    return ""
  }
}
