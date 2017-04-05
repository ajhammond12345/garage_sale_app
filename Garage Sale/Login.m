//
//  Login.m
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Login.h"

@interface Login ()

@end

@implementation Login

-(IBAction)signIn:(id)sender {
    NSString *email = emailTextField.text;
    NSString *password = passwordTextField.text;
    //improve by running checks against the input (for @ symbol and such)
    if (email != nil && password != nil) {
        //sends url request to login - just needs to store UserID in the defaults
    }
    else {
        //error prompting user to put in email and password
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
