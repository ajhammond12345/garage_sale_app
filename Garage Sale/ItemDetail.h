//
//  ItemDetail.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/22/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

//imports all of the header files it will use
#import "Item.h"
#import "Comments.h"
#import <PassKit/PassKit.h>
#import "Items.h"


@interface ItemDetail : UIViewController <UITextViewDelegate> {
    
    //declares all of the UI elements
    IBOutlet UILabel *displayName;
    IBOutlet UILabel *displayCondition;
    IBOutlet UILabel *displayPrice;
    IBOutlet UITextView *displayDescription;
    IBOutlet UIButton *displayLikeButton;
    IBOutlet UIImageView *displayImage;
    IBOutlet UIButton *comment;
    IBOutlet UIImageView *purchased;
    IBOutlet UIButton *buyButton;
    
    
}

//declares the properties, actions, and publicly accessible methods

@property Item *itemOnDisplay;

-(IBAction)like:(id)sender;
-(IBAction)comments:(id)sender;
-(void)updateView;

@end
