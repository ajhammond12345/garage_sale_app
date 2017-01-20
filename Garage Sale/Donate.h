//
//  Donate.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *name;
NSString *condition;
int priceInCents;
NSString *description;
UIImage *image;
NSArray *conditionOptions;



@interface Donate : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate> {
    
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *conditionTextField;
    IBOutlet UITextField *priceTextField;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *cameraButton;
    
}

@property (strong, nonatomic) UIPickerView *conditionPicker;

-(IBAction)done:(id)sender;

@end
