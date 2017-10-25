//
//  FormCellContainerBridge.m
//  SAPMDCFramework
//  Copyright © 2016 SAP. All rights reserved.
//

#import "FormCellContainerBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>
#import "FormCellItemDelegate.h"
//#import <objc/objc.h>
//#import <objc/runtime.h>

@implementation FormCellContainerBridge

- (UIViewController*) createWithParams:(NSDictionary *)params {
  int numberOfSections = [[params objectForKey:@"numberOfSections"] intValue];
  NSArray *numberOfRowsInSection = [params objectForKey:@"numberOfRowsInSection"];
  NSArray *sectionNames = [params objectForKey:@"sectionNames"];
  BOOL isInPopover = [[params objectForKey:@"isInPopover"] boolValue];

  FormCellContainerViewController *controller = [[FormCellContainerViewController alloc] initWithStyle:UITableViewStyleGrouped];
  controller.numberOfSections = numberOfSections;
  controller.numberOfRowsInSection = numberOfRowsInSection;
  controller.sectionNames = sectionNames;
  controller.isInPopover = isInPopover;
  return controller;
}

-(void)populateController:(UIViewController *)controller withParams:(NSDictionary *)params andBridge: (FormCellItemDelegate *) bridge {

  FormCellContainerViewController *fcController = (FormCellContainerViewController*) controller;

  // code just for dumping the properties of the delegate object ---START---
  //    if (delegate) {
  //        unsigned int i = 0;
  //        Method *m = class_copyMethodList([delegate class], &i);
  //        for (int k=0; k<i; k++) {
  //            NSLog(@"%@", NSStringFromSelector(method_getDescription(m[k])->name));
  //            int args = method_getNumberOfArguments(m[k]);
  //            NSLog(@"%i", args);
  //            for (int l=0; l<args; l++) {
  //                char argName[10];
  //                method_getArgumentType(m[k], l, argName, 10);
  //                NSString *str = [NSString stringWithCString:argName encoding:NSUTF8StringEncoding];
  //                NSLog(@"%@", str);
  //            }
  //        }
  //    }
  // ----END---

  FormCellItemDelegate *myDelegate = bridge;
  if (!myDelegate) {
    // default delegate used just for logging the data (DEBUG)
    myDelegate = [[FormCellItemDelegate alloc] init];
  }
  [fcController addFormCell:params withDelegate: myDelegate];
}

-(void)updateCell:(UIViewController *)controller withParams:(NSDictionary*) params row: (NSNumber*) row section: (NSNumber*) section {
  FormCellContainerViewController *fcController = (FormCellContainerViewController*) controller;
  [fcController updateFormCell: params cellRow: [row integerValue] cellSection: [section integerValue]];
}

-(void)updateCells:(UIViewController *)controller withParams:(NSArray*) paramsArray andStyle: (NSString*) style {
  FormCellContainerViewController *fcController = (FormCellContainerViewController*) controller;
  [fcController updateFormCells: paramsArray withStyle: style];
}

@end
