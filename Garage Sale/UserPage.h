//
//  UserPage.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/10/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "DonatedItemCustomCell.h"
#import "ItemDetailChange.h"



@interface UserPage : UIViewController <UIImagePickerControllerDelegate, NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UINavigationItem *navBar;
    IBOutlet UILabel *name;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *emailLabel;
    IBOutlet UIButton *userImageButton;
    IBOutlet UITableView *donatedItemsView;
    IBOutlet UISegmentedControl *itemListType;

    
}

@property NSMutableArray *donatedItems;
@property NSMutableArray *purchasedItems;
@property NSDictionary *result;
@property Item *itemToSend;
@property bool showAll;

-(IBAction)userPhoto:(id)sender;

@end
