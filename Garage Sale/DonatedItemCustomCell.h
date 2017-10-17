//
//  DonatedItemCustomCell.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/10/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"


//class declarations
@interface DonatedItemCustomCell : UITableViewCell

@property Item *item;
@property UITableView *parentTable;
@property NSIndexPath *cellPath;

@property IBOutlet UILabel *name;
@property IBOutlet UILabel *condition;
@property IBOutlet UILabel *purchaseStatus;
@property IBOutlet UIImageView *image;

-(void)updateCell;

@end

