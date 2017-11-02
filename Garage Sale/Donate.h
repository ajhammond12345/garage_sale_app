//
//  Donate.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

//variable declarations
NSString *name;
NSInteger *conditionInt;
NSString *condition;
NSInteger *priceInCents;
NSString *description;
UIImage *image;
bool imageUploaded;

NSArray *conditionOptionsDonate;



@interface Donate : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    //outlet declarations (UI elements)
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *conditionTextField;
    IBOutlet UITextField *priceTextField;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UIActivityIndicatorView *loading;
    IBOutlet UIButton *imageView;
    IBOutlet UIButton *cameraButton;
    IBOutlet UILabel *tmpLabel;
}

//class properties
@property (strong, nonatomic) UIPickerView *conditionPicker;
@property UIToolbar *toolBar;
@property bool doneClicked;

//Action methods (actions are linked to UI events)
-(IBAction)done:(id)sender;
-(IBAction)selectImage:(id)sender;

@end
