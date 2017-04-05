//
//  Login.h
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Login : UIViewController {
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *signInButton;
    IBOutlet UIButton *signUpButton;
}

-(IBAction)signIn:(id)sender;

@end
