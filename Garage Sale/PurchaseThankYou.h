//
//  PurchaseThankYou.h
//  Garage Sale
//
//  Created by Alexander Hammond on 2/1/17.
//  Copyright © 2017 TripleA. All rights reserved.
//


#import <UIKit/UIKit.h>

//imports header files of other classes it will use (it stores an item and access an ItemDetail view controller
#import "Item.h"
#import "ItemDetail.h"

@interface PurchaseThankYou : UIViewController

//declares it will have an Item as a property
@property Item *itemStorage;

@end
