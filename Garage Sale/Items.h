//
//  Items.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "ItemCustomCell.h"


bool showAll;
Item *itemToSend;

@interface Items : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>{
    
     //needs to be saved to the device
    
    
    IBOutlet UITableView *itemsView;
    IBOutlet UISegmentedControl *itemListType;
    IBOutlet UINavigationItem *itemName;
    
    
    
}

@property NSMutableArray *items;
@property NSArray *likedItems;
@property NSArray *result;
@property UIImage *tmpImage;



-(void)loadAllItems;
-(void)loadLikedItems;


@end
