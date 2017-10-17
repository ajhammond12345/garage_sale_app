//
//  SignUp.h
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SignUp : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UITextField *firstNameTextField;
    IBOutlet UITextField *lastNameTextField;
    IBOutlet UITextField *addressTextField;
    IBOutlet UITextField *passwordVerificationTextField;
}

@property NSArray *requestResult;
@property bool usernameDataDownloadSuccessful;
@property bool emailDataDownloadSuccessful;
@property bool usernameUnique;
@property bool emailUnique;
@property NSString *email;
@property NSString *username;
@property NSString *password;
@property NSString *firstName;
@property NSString *lastName;
@property NSString *address;

@property NSDictionary *result;


-(IBAction)signUp:(id)sender;

@end
