//
//  Items.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

//imports
#import <UIKit/UIKit.h>
#import "Item.h"
#import "ItemCustomCell.h"



//declaring interface outlets
@interface Items : UIViewController <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>{
    
     //needs to be saved to the device
    
    
    IBOutlet UITableView *itemsView;
    IBOutlet UISegmentedControl *itemListType;
    IBOutlet UINavigationItem *itemName;
    
    
    
}

//declaring properties
@property NSMutableArray *items;
@property NSArray *likedItems;
//if fails make NSMutableArray
@property NSArray *filteredResults;
@property NSMutableArray *filteredItems;
@property NSArray *result;
@property bool showFiltered;
@property bool showAll;
@property Item *itemToSend;
@property long itemToSendRow;
@property NSDictionary *filters;


//methods that can be accessed when importing this header file
-(void)loadAllItems;
-(void)loadLikedItems;

-(Item *)itemFromDictionaryExternal:(NSDictionary *)dictionary;


@end
