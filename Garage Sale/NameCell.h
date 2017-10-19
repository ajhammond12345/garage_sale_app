//
//  NameCell.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/18/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettings.h"

@interface NameCell : UITableViewCell <UITextFieldDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UIButton *userPhotoView;
    IBOutlet UITextField *firstNameTextField;
    IBOutlet UITextField *lastNameTextField;
}

-(void)updateCell;

@property UIImage *userPhoto;
@property NSString *firstName;
@property UserSettings *superView;
@property NSString *lastName;

@end
