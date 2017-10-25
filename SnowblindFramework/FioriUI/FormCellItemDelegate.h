//
//  FormCellItemDelegate.h
//  SAPMDCFramework
//
//  Copyright © 2016 SAP. All rights reserved.
//

#ifndef FormCellItemDelegate_h
#define FormCellItemDelegate_h

@interface FormCellItemDelegate : NSObject

- (void)loadMoreItems;
- (void)valueChangedWithParams:(NSDictionary<NSString *, NSString *> * _Nonnull)params;
- (void)searchUpdated: (NSString * _Nonnull) searchText;

@end


#endif /* FormCellItemDelegate_h */
