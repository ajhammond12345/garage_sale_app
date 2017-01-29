//
//  Donate.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

NSString *name;
NSInteger *conditionInt;
NSString *condition;
NSInteger *priceInCents;
NSString *description;
UIImage *image;

NSArray *conditionOptionsDonate;



@interface Donate : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *conditionTextField;
    IBOutlet UITextField *priceTextField;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UIButton *imageView;
    IBOutlet UIButton *cameraButton;
    IBOutlet UILabel *tmpLabel;
}

@property (strong, nonatomic) UIPickerView *conditionPicker;


-(IBAction)done:(id)sender;
-(IBAction)selectImage:(id)sender;

@end
