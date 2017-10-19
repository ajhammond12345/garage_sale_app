//
//  ItemDetailChange.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
//imports all of the header files it will use
#import "Item.h"
#import "UserPage.h"

//variable declarations




@interface ItemDetailChange : UIViewController <UITextViewDelegate> {
    
    //declares all of the UI elements
    
    
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *conditionTextField;
    IBOutlet UITextField *priceTextField;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UIButton *imageView;
    IBOutlet UIButton *cameraButton;
    IBOutlet UIImageView *purchased;
    IBOutlet UIBarButtonItem *saveButton;
    
    IBOutlet UILabel *tmpLabel;
    
}

//declares the properties, actions, and publicly accessible methods


@property NSString *theNewName;
@property NSInteger *theNewConditionInt;
@property NSString *theNewCondition;
@property NSInteger *theNewPriceInCents;
@property NSString *theNewDescription;
@property UIImage *theNewImage;
@property bool imageUpdated;

@property Item *itemOnDisplay;

@property NSArray *conditionOptionsItemUpdate;

//this is passed on to prevent needing to reload when going back to main page
@property NSMutableArray *items;
@property (strong, nonatomic) UIPickerView *conditionPicker;
@property UIToolbar *toolBar;

-(IBAction)save:(id)sender;
-(IBAction)back:(id)sender;
-(void)updateView;


@end


