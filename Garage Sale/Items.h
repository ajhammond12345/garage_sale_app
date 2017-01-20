//
//  Items.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Items : UIViewController {
    NSMutableArray *items;
    NSMutableArray *likedItems; //needs to be saved to the device
    
    IBOutlet UITableView *itemsView;
    IBOutlet UISegmentedControl *itemListType;
    IBOutlet UINavigationItem *itemName;
    
    
}

-(IBAction)showAllItems;
-(IBAction)showLikedItems;
-(IBAction)uploadComment;
-(IBAction)likeItem;

-(void)loadAllItems;
-(void)loadComments;

@end
