//
//  Login.h
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Login : UIViewController <UITextFieldDelegate> {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *signInButton;
    IBOutlet UIButton *signUpButton;
}

@property bool loginTried;
@property bool loginSuccessful;
@property NSDictionary *requestResult;


-(IBAction)signIn:(id)sender;

@end
