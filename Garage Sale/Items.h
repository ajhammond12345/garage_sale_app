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




@interface Items : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>{
    
     //needs to be saved to the device
    
    
    IBOutlet UITableView *itemsView;
    IBOutlet UISegmentedControl *itemListType;
    IBOutlet UINavigationItem *itemName;
    
    
    
}

@property NSMutableArray *items;
@property NSArray *likedItems;
//if fails make NSMutableArray
@property NSArray *filteredResults;
@property NSMutableArray *filteredItems;
@property NSArray *result;
@property bool showFiltered;
@property bool showAll;
@property Item *itemToSend;
@property NSDictionary *filters;


-(void)loadAllItems;
-(void)loadLikedItems;

-(Item *)itemFromDictionaryExternal:(NSDictionary *)dictionary;


@end
