//
//  ItemCustomCell.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/21/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ItemCustomCell : UITableViewCell

@property Item *item;
@property UITableView *parentTable;

@property IBOutlet UILabel *name;
@property IBOutlet UILabel *condition;
@property IBOutlet UILabel *price;
@property IBOutlet UIButton *likeButton;
@property IBOutlet UIImageView *image;

-(void)updateCell;

@end
