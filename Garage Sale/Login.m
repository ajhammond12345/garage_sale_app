//
//  Login.m
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Login.h"

@interface Login () <UITextFieldDelegate>

@end

@implementation Login



-(IBAction)signIn:(id)sender {
    [self.view endEditing:YES];
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    //improve by running checks against the input (for @ symbol and such)
    if (username != nil && password != nil) {
        //sends url request to login - just needs to store UserID in the defaults
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(transition)
                                                     name:@"loggedIn"
                                                   object:nil];
        [self login];
    }
    else {
        //error prompting user to put in email and password
    }
}

-(void)transition {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"loggedIn"
                                                  object:nil];
    [self performSegueWithIdentifier:@"toHomeFromLogin" sender:self];
}

-(void)login {
    NSString *username = usernameTextField.text;
    NSString *password = passwordTextField.text;
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    //goes through every field, if it is not empty it adds it to the dictionary (empty fields are handled by the database with default values)
    [dataDic setObject:username forKey:@"username"];
    [dataDic setObject:password forKey:@"password"];
    //creates a dictionary for sending the request - puts it under the data heading to match what the database expects
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:dataDic forKey:@"data"];
    //NSLog(@"%@", tmpDic);
    
    //error handler
    NSError *error;
    
    //creates the json data for the url request
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    
    //creates url for request
    //production URL
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/users/login.json"];
    //testing URL
    //NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users/login.json"];
    
    //creates a URL request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //specifics for the request (it is a post request with json content)
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody: jsonData];
    
    //creates the URLSession to start the request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //sets the boolean to false to indicate the download has not yet finished
    _loginSuccessful = false;
    //creates empty array to store the response from the server
    _requestResult = [[NSDictionary alloc] init];
    
    //initiates the url session with a handler that processes the data returned from the server
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
        //if the data is empty it will report an error, if not it will process the list of items returned by the filter parameters
        if (data != nil) {
            //error handler
            NSError *jsonError;
            //stores the response
            _requestResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            NSLog(@"requestReply: %@", _requestResult);
            NSLog(@"%@", [[_requestResult class] description]);
            
            //if the response is the valid type it indicates the download is successful and proceeds with the segue back to the main page, if unsuccessful it proceeds while leaving the downloadSuccessful as false (the segue delegate method uses this to determine what data to pass to the Items view controller
            NSInteger *userIDCheck = (NSInteger *)[[_requestResult objectForKey:@"id"] integerValue];
            if (userIDCheck != 0) {
                _loginSuccessful = true;
                NSInteger *userID = (NSInteger *)[[_requestResult objectForKey:@"id"] integerValue];
                NSLog(@"User ID From download: %@", [NSString stringWithFormat:@"%zd", userID]);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"user_id"];
                [defaults setObject:[_requestResult objectForKey:@"user_unique_key"] forKey:@"unique_key"];
                [defaults setObject:[_requestResult objectForKey:@"username"] forKey:@"username"];
                [defaults setObject:[NSNumber numberWithBool:true] forKey:@"logged_in"];
                [defaults setObject:password forKey:@"password"];
                [defaults setObject:[_requestResult objectForKey:@"user_first_name"] forKey:@"first_name"];
                [defaults setObject:[_requestResult objectForKey:@"user_last_name"] forKey:@"last_name"];
                [defaults setObject:[_requestResult objectForKey:@"user_address"] forKey:@"address"];
                [defaults setObject:[_requestResult objectForKey:@"email_address"] forKey:@"email"];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"toHomeFromLogin" sender:self];
                });
                
                
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Login" message:@"Please try again" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                {
                                                    
                                                }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        //logs if data is nil and the phone did not connect to a server
        else {
            NSLog(@"NO DATA RECEIVED FROM USER CREATION REQUEST");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Error" message:@"Could not connect to server." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                            {
                                                
                                            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
    }] resume];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    usernameTextField.delegate = self;
    passwordTextField.delegate = self;
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
