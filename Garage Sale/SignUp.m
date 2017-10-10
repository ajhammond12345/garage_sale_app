//
//  SignUp.m
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

/*
 Things left for this page:
    Test unique verification
    Test ID saving
    Transistions back to page it comes from
 
 */

#import "SignUp.h"

@interface SignUp () <UITextFieldDelegate>

@end

@implementation SignUp


//assumes non-nil username given
-(void)uniqueUsername:(NSString *)username {
    NSLog(@"Started checking for username");
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    //goes through every field, if it is not empty it adds it to the dictionary (empty fields are handled by the database with default values)
    [dataDic setObject:username forKey:@"username"];
    //creates a dictionary for sending the request - puts it under the data heading to match what the database expects
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:dataDic forKey:@"data"];
        //NSLog(@"%@", tmpDic);
        
        //error handler
        NSError *error;
        
        //creates the json data for the url request
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
        
        //creates url for request
        NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users/unique_username.json"];
        
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
        _usernameDataDownloadSuccessful = false;
        //creates empty array to store the response from the server
        _requestResult = [[NSArray alloc] init];
        
        //initiates the url session with a handler that processes the data returned from the server
        [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
                //if the data is empty it will report an error, if not it will process the list of items returned by the filter parameters
                if (data != nil) {
                    //error handler
                    NSError *jsonError;
                    //stores the response
                    _requestResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    //NSLog(@"requestReply: %@", _requestResult);
                    //NSLog(@"%@", [[_requestResult class] description]);
                    
                    //if the response is the valid type it indicates the download is successful and proceeds with the segue back to the main page, if unsuccessful it proceeds while leaving the downloadSuccessful as false (the segue delegate method uses this to determine what data to pass to the Items view controller
                    if ([[[_requestResult class] description] isEqualToString:@"__NSArrayM"]) {
                        _usernameDataDownloadSuccessful = true;
                        if (_requestResult.count < 1) {
                            NSLog(@"Verified username is Unique");
                            _usernameUnique = true;
                            if (_usernameUnique && _emailUnique) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpVerified" object:self userInfo:nil];
                            }
                            //SHOW USERNAME IS VALID SOMEWHERE IN UI
                        }
                        else {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Username already in use" message:@"Please choose a different username" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                            [alert addAction:defaultAction];
                            [self presentViewController:alert animated:YES completion:nil];
                            _usernameUnique = false;
                        }
                    }
                    else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Unable to process your request at this moment." preferredStyle:UIAlertControllerStyleAlert];
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
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Error" message:@"Could not connect to create user." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                    {
                                                        
                                                    }];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
        }] resume];
}

//assumes non-nil and preprocessed (checked to verify actually resembles an email address) email given
-(void)uniqueEmail:(NSString *)email {
    NSLog(@"Started checking for email");
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    //goes through every field, if it is not empty it adds it to the dictionary (empty fields are handled by the database with default values)
    [dataDic setObject:email forKey:@"email"];
    //creates a dictionary for sending the request - puts it under the data heading to match what the database expects
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:dataDic forKey:@"data"];
    //NSLog(@"%@", tmpDic);
    
    //error handler
    NSError *error;
    
    //creates the json data for the url request
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    
    //creates url for request
    NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users/unique_email.json"];
    
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
    _emailDataDownloadSuccessful = false;
    //creates empty array to store the response from the server
    _requestResult = [[NSArray alloc] init];
    
    //initiates the url session with a handler that processes the data returned from the server
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
            //if the data is empty it will report an error, if not it will process the list of items returned by the filter parameters
            if (data != nil) {
                //error handler
                NSError *jsonError;
                //stores the response
                _requestResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                //NSLog(@"requestReply: %@", _requestResult);
                //NSLog(@"%@", [[_requestResult class] description]);
                
                //if the response is the valid type it indicates the download is successful and proceeds with the segue back to the main page, if unsuccessful it proceeds while leaving the downloadSuccessful as false (the segue delegate method uses this to determine what data to pass to the Items view controller
                if ([[[_requestResult class] description] isEqualToString:@"__NSArrayM"]) {
                    _emailDataDownloadSuccessful = true;
                    if (_requestResult.count < 1) {
                        NSLog(@"Verified email is Unique");
                        _emailUnique = true;
                        if (_usernameUnique && _emailUnique) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpVerified"
                                                                                object:self
                                                                              userInfo:nil];
                        }
                        //SHOW EMAIL IS VALID SOMEWHERE IN UI
                    }
                    else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Email already in use" message:@"Please choose a different email" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        _emailUnique = false;
                    }
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Unable to process your request at this moment." preferredStyle:UIAlertControllerStyleAlert];
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
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Error" message:@"Could not connect to create user." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                {
                                                    
                                                }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                
            }
    }] resume];
}

-(void)addAccount {
    
    //creates error handler
    NSError *myError;
    
    //creates mutable dictionary to add keys
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:_email forKey:@"email_address"];
    [tmpDic setObject:_password forKey:@"user_password"];
    [tmpDic setObject:_username forKey:@"username"];
    //JSON Upload
    //converts the dictionary to json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&myError];
    //logs the data to check if it is created successfully
    //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    //creates url for the request
    NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users.json"];
    
    //creates a URL request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //specifics for the request (it is a post request with json content)
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody: jsonData];
    
    //create some type of waiting image here
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    //runs the data task
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //saves the data to find user id
        _result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", [[requestReply class] description]);
            //if the result has the class type __NSCFConstantString then the item failed to upload
            if ([[[requestReply class] description] isEqualToString:@"__NSCFConstantString"]) {
                //alert for failing to upload
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection\n" message:@"Could not create user. Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                //opens user defaults to save data locally
                NSLog(@"%@", _result);
                NSInteger *userID = (NSInteger *)[[_result objectForKey:@"id"] integerValue];
                NSLog(@"User ID From download: %@", [NSString stringWithFormat:@"%zd", userID]);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"user_id"];
                [defaults setObject:[NSNumber numberWithBool:true] forKey:@"logged_in"];
                [defaults setObject:[_result objectForKey:@"username"] forKey:@"username"];
                
                //transitions back to page it came from (property booleans needed here
                [self performSegueWithIdentifier:@"toHome" sender:(self)];
            }
        });
    }] resume];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"signUpVerified"
                                                  object:nil];
}


-(IBAction)signUp:(id)sender {
    _usernameUnique = false;
    _emailUnique = false;
    _email = emailTextField.text;
    _username = usernameTextField.text;
    _password = passwordTextField.text;
    [self uniqueUsername:_username];
    [self uniqueEmail:_email];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addAccount)
                                                 name:@"signUpVerified"
                                               object:nil];
    //closes all keyboards
    [self.view endEditing:YES];
    
    //creates an empty dictionary for data to be added
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernameUnique = false;
    _emailUnique = false;
    usernameTextField.delegate = self;
    emailTextField.delegate = self;
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
