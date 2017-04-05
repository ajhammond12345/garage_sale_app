//
//  SignUp.h
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUp : UIViewController {
    IBOutlet UITextField *usernameTextField;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
}

@property NSArray *requestResult;
@property bool usernameDataDownloadSuccessful;
@property bool emailDataDownloadSuccessful;
@property bool usernameUnique;
@property bool emailUnique;

@property NSDictionary *result;


-(IBAction)signUp:(id)sender;

@end
