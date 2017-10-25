//
//  AttachmentFormViewDelegate.swift
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFiori
import Photos

// swiftlint:disable force_cast
// swiftlint:disable for_where
// This class implements all the delegates needed by the supported attachment handlers (TakePhoto, AddPhoto)
public class AttachmentFormViewDelegate: FUIAttachmentsViewControllerDataSource, FUIAttachmentsViewControllerDelegate,
FUIAddPhotoAttachmentActionDelegate, FUITakePhotoAttachmentActionDelegate {

  enum AttachmentDataField: String {
    case contentType, content, urlString, entitySet, property, readLink, service
  }

  let formController: FormCellContainerViewController
  let iPath: IndexPath
  var attachmentUniqueIDs = [String]() // to store unique ID that represents each attachment, can be assets-library url or asset local identifier
  var attachmentsData = [String: [String: Any]]()
  var attachmentThumbnails = [String: UIImage?]()
  var params: [String: Any]
  var values: [Any]?

  init(controller: FormCellContainerViewController, indexPath: IndexPath, params: [String: Any]) {
    self.formController = controller
    self.iPath = indexPath
    self.params = params
    self.values = (params["Value"] as? [Any])!
  }

  // MARK: FUIAttachmentsViewControllerDataSource methods

  /**
   Gets the thumbnail image for the attachment at the specific location.

   - parameter attachmentView: the calling AttachmentFormView instance
   - parameter index: the item index of the attachment (single-vector)
   - returns: a thumbnail icon image for the attachment
   */
  public func attachmentsViewController(_ attachmentsViewController: FUIAttachmentsViewController, iconForAttachmentAtIndex index: Int) ->
    (image: UIImage, contentMode: UIViewContentMode)? {

    let uniqueIDString = self.attachmentUniqueIDs[index]
    if let image = attachmentThumbnails[uniqueIDString] {
      return (image!, .scaleAspectFill)
    }

    return nil
  }

  public func attachmentsViewController(_ attachmentsViewController: FUIAttachmentsViewController, urlForAttachmentAtIndex index: Int) -> URL? {
    let uniqueIDString = self.attachmentUniqueIDs[index]
    if let attachmentData = attachmentsData[uniqueIDString] {
      return URL(string: (attachmentData[AttachmentDataField.urlString.rawValue] as? String)!)
    }

    return nil
  }

  public func numberOfAttachments(in attachmentsViewController: FUIAttachmentsViewController) -> Int {
    return attachmentUniqueIDs.count
  }

  // MARK: FUIAttachmentsViewControllerDelegate methods

  public func attachmentsViewController(_ attachmentsViewController: FUIAttachmentsViewController, didPressDeleteAtIndex index: Int) {

    let uniqueIDString = self.attachmentUniqueIDs[index]
    let attachmentData = self.attachmentsData[uniqueIDString]!
    self.attachmentUniqueIDs.remove(at: index)

    self.attachmentThumbnails.removeValue(forKey: uniqueIDString)
    self.attachmentsData.removeValue(forKey: uniqueIDString)

    for (valueIndex, valueItem) in self.values!.enumerated() {
      if let value = valueItem as? [String: Any] {
        let valueIdString = self.uniqueIdForURL(url: URL(string: value["urlString"] as! String)!, udid: "")
        if valueIdString == uniqueIDString {
          self.values?.remove(at: valueIndex)
          break
        }
      }
    }
    self.params["Value"] = self.values

    notifyContainer(deletedAttachment: attachmentData as NSDictionary)

    DispatchQueue.main.async {
      self.formController.tableView.reloadSections(IndexSet(integer: self.iPath.section), with: .automatic)
      self.attachmentsData.removeValue(forKey: uniqueIDString)
    }
  }

  /**
   * This function is invoked, if the controller failed to obtain a valid file URL for an attachment which should be presented.
   * This may occur when the developer returns `nil` to `FUIAttachmentsViewControllerDataSource` `urlForAttachmentAtIndex:`
   * method, or if the file at the URL provided cannot be presented by a `UIDocumentInteractionController`.
   *
   * - parameter attachmentsViewController: The calling `FUIAttachmentsViewController`.
   * - parameter index: The index of the attachment, for which presentation was attempted.
   */

  public func attachmentsViewController(_ attachmentsViewController: FUIAttachmentsViewController,
                                        couldNotPresentAttachmentAtIndex index: Int) -> Void {
  }

  // MARK: AddPhotoAttachmentActionDelegate

  public func addPhotoAttachmentAction(_ action: FUIAddPhotoAttachmentAction, didSelectPhotoAt url: URL) {
    self.addAttachment(url, udid: "")
  }

  public func addPhotoAttachmentAction(_ action: FUIAddPhotoAttachmentAction, didSelectPhoto asset: PHAsset, at url: URL) {
    self.addAttachment(url, udid: asset.localIdentifier)
  }

  // MARK: TakePhotoAttachmentActionDelegate

  public func takePhotoAttachmentAction(_ action: FUITakePhotoAttachmentAction, didTakePhotoAt url: URL) {
    //  url.preferredFilename = "SB-filename"
    //addFileAttachment(url) will add file attachment and noitify container
    self.addAttachment(url, udid: "")
  }

  public func takePhotoAttachmentAction(_ action: FUITakePhotoAttachmentAction, didTakePhoto asset: PHAsset, at url: URL) {
    self.addAttachment(url, udid: asset.localIdentifier)
  }

  private func addAttachment(_ url: URL, reload: Bool = true, udid: String, notify: Bool = true) {
    let uniqueId: String = uniqueIdForURL(url: url, udid: udid)

    guard self.attachmentsData[uniqueId] != nil else {
      // new attachment
      self.attachmentUniqueIDs.append(uniqueId)
      self.addThumbnailAndAttachmentData(url: url, uniqueId: uniqueId, notify: notify)
      guard self.attachmentsData[uniqueId] != nil else {
        // cleanup unique ids
        for (index, uniqueIdIndex) in self.attachmentUniqueIDs.enumerated() {
          if uniqueIdIndex == uniqueId {
            self.attachmentUniqueIDs.remove(at: index)
            break
          }
        }
        // clean up thumbnails
        let thumbnailIndex = self.attachmentThumbnails.index(forKey: uniqueId)
        if let thumbnailIndex = thumbnailIndex {
          self.attachmentThumbnails.remove(at: thumbnailIndex)
        }

        return
      }
      if reload {
        DispatchQueue.main.async {
          self.formController.tableView.reloadSections(IndexSet(integer: self.iPath.section), with: .automatic)
          self.formController.tableView.scrollToRow(at: IndexPath(row: self.iPath.row, section: self.iPath.section), at: .middle, animated: true)
        }
      }
      return
    }
  }

  // Add attachment data, notify Container of the data change
  private func addAttachmentData(imageData: Data, uniqueId: String, url: URL, notify: Bool, contentType: String) {
   var attachmentData = [String: Any]()
    attachmentData[AttachmentDataField.contentType.rawValue] = contentType
    attachmentData[AttachmentDataField.content.rawValue] = imageData
    attachmentData[AttachmentDataField.urlString.rawValue] = url.absoluteString
    self.attachmentsData[uniqueId] = attachmentData
    if notify {
      self.notifyContainer(addedAttachment: attachmentData as NSDictionary)
    }
  }

  public func addAttachmentEntry(attachmentEntry: NSDictionary) {
    if let urlString = attachmentEntry["urlString"] as? String {
      if let url = URL(string: urlString) {
      // data and thumbnail url already exist?
       let uniqueId: String = uniqueIdForURL(url: url, udid: "")
        guard self.attachmentsData[uniqueId] == nil else {
          return
        }
        self.addAttachment(url, reload: false, udid: "", notify: false)
        guard self.attachmentsData[uniqueId] == nil else {
          self.attachmentsData[uniqueId]![AttachmentDataField.entitySet.rawValue] = attachmentEntry["entitySet"]
          self.attachmentsData[uniqueId]![AttachmentDataField.property.rawValue] = attachmentEntry["property"]
          self.attachmentsData[uniqueId]![AttachmentDataField.readLink.rawValue] = attachmentEntry["readLink"]
          self.attachmentsData[uniqueId]![AttachmentDataField.service.rawValue] = attachmentEntry["service"]
          return
        }
      }
    }
  }

  private func addThumbnailAndAttachmentData(url: URL, uniqueId: String, notify: Bool) {
    // Note: When attachment supports other documents than image, we need to set other content type
    var contentType: String = "image/jpeg"
    let assets: PHFetchResult<PHAsset>
    if (url.scheme != nil && url.scheme == "assets-library") || uniqueId == "" {
      assets = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
    } else {
      assets = PHAsset.fetchAssets(withLocalIdentifiers: [uniqueId], options: nil)
    }

    if let asset = assets.firstObject {
      let imageManager = PHImageManager.default()
      let options = PHImageRequestOptions()
      options.isSynchronous = true
      imageManager.requestImage(for: asset, targetSize: CGSize(width: 80, height: 80), contentMode: .default, options: options, resultHandler: { image, _ in
        self.attachmentThumbnails[uniqueId] = image
      })
      imageManager.requestImageData(for: asset, options: nil, resultHandler: { (imageData, _, _, _) in
        self.addAttachmentData(imageData: imageData!, uniqueId: uniqueId, url: url, notify: notify, contentType: contentType)
      })
    } else {
      if let image = ImagePathHandler.image(from: url.path) {
        self.attachmentThumbnails[uniqueId] = image
        var imageData: Data?
        if url.pathExtension == "jpeg" || url.pathExtension == "jpg" {
          imageData = UIImageJPEGRepresentation(image, 0.7)
        } else if url.pathExtension == "png" {
          contentType = "image/png"
          imageData = UIImagePNGRepresentation(image)
        }

        if let imageData = imageData {
          self.addAttachmentData(imageData: imageData, uniqueId: uniqueId, url: url, notify: notify, contentType: contentType)
        }
      }
    }
  }

  // notify the container with the complete list of attachments
  private func notifyContainer(addedAttachment: NSDictionary? = nil, deletedAttachment: NSDictionary? = nil) {
    var data = [String: Any]()
    var dataValue = [Any]()
    for uniqueID in self.attachmentUniqueIDs {
      dataValue.append(self.attachmentsData[uniqueID]!)
    }
    data[FormCellFactory.Parameters.Value.rawValue] = dataValue

    if let addedAttachment = addedAttachment {
      data[FormCellFactory.Parameters.AddedAttachments.rawValue] = addedAttachment
    }

    if let deletedAttachment = deletedAttachment {
      data[FormCellFactory.Parameters.DeletedAttachments.rawValue] = deletedAttachment
    }

    let name: String = (self.params["_Name"] as? String)!
    self.formController.didChangeValue(for: name, with: data)
  }

  private func uniqueIdForURL(url: URL, udid: String) -> String {
    if url.scheme != nil && ((url.scheme == "assets-library") || (url.scheme == "file")) || udid == "" {
      return url.absoluteString
    } else {
      return udid
    }
  }

  func cleanAttachments() {
    self.attachmentUniqueIDs.removeAll()
  }
}
