//
//  ItemDetail.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/22/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"
#import "Comments.h"
#import <PassKit/PassKit.h>


@interface ItemDetail : UIViewController <UITextViewDelegate> {
    
    
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

@property Item *itemOnDisplay;

-(IBAction)buy:(id)sender;
-(IBAction)like:(id)sender;
-(IBAction)comments:(id)sender;
-(void)updateView;

@end
