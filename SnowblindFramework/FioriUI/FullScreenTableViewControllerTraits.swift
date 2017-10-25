//
//  FullScreenTableViewController.swift
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

// #todo: get rid of all the 'Table' here since this now works for all VCs

import UIKit
/**
 * This is a trait shared by table view controllers that occupy
 * the entire screen.
 *
 * It accomplishes two goals: size the table view to occupy the
 * entire screen, and hide the table view while the resizing is
 * taking place to avoid widgets moving around.
 *
 * To use, just make sure your control's view controller implements
 * the protocol and the correct methods are called in the lifecycle
 * events.
 */
protocol FullScreenTableViewControllerTraits {

  // Call whenever the table view controller is loaded
  func onFullScreenTableViewControllerLoaded()

  // Call whenever the table view controller apperared
  func onFullScreenTableViewControllerAppeared()
}

extension FullScreenTableViewControllerTraits {

  func onFullScreenTableViewControllerLoaded() {

    assert(self is UIViewController, "Protocol implementor of the wrong type!")

    if let viewController = self as? UIViewController {

      // hide the view until the frame is set properly
      viewController.view.isHidden = true
    }
  }

  func onFullScreenTableViewControllerAppeared() {

    assert(self is UIViewController, "Protocol implementor of the wrong type!")

    if let viewController = self as? UIViewController,
      let view = viewController.view,
      let superView = view.superview {

      var newFrame = CGRect()

      if let navigationController = viewController.navigationController {

        // If there is a navigationController, we are not in a modal page,
        // so our frame is based on the screen size or window size

        if let window = viewController.view.window {

          // adjust the  view frame to take over the whole screen
          newFrame = window.frame

          // our width is always full screen (we only support the vertical
          // Stack layout, but we must adjust our height to account for the
          // navigation bar
          newFrame.size.height = superView.frame.size.height - newFrame.origin.y

          // check if the orientation of windw and superview is consistent. If not, align
          // newFrame's width to superview's width. Otherwise, it breaks frame hierarchy of
          // view tree
          let superViewIsLandscape = superView.frame.size.height < superView.frame.size.width
          let windowIsLandscape = window.frame.size.height < window.frame.size.width
          if superViewIsLandscape != windowIsLandscape {
            newFrame.size.width = superView.frame.size.width
          }

          // make the navigation controller opaque so there is no scrolling behind it
          navigationController.navigationBar.isTranslucent = false

          // set a shadowImage to the navigation bar which removes the white line below that
          navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
          navigationController.navigationBar.shadowImage = UIImage()
        }

      } else {

        // We are in a modal page, find the size we have to fit

        // adjust the view frame to take over the whole modal page
        newFrame = superView.frame
      }

      view.frame = newFrame

      // ... and finally show the view
      view.isHidden = false
    }
  }
}
