//
//  SignUp.m
//  Garage Sale
//
//  Created by Alexander Hammond on 3/29/17.
//  Copyright © 2017 TripleA. All rights reserved.
//



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
    //production URL
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/users/unique_username.json"];
    //testing URL
    //NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users/unique_username.json"];
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
                    _usernameUniqueRequestReply = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    NSLog(@"Email requestReply: %@", _usernameUniqueRequestReply);
                    NSLog(@"%@", [[_usernameUniqueRequestReply class] description]);
                    
                    //if the response is the valid type it indicates the download is successful and proceeds with the segue back to the main page, if unsuccessful it proceeds while leaving the downloadSuccessful as false (the segue delegate method uses this to determine what data to pass to the Items view controller
                    if ([_usernameUniqueRequestReply objectForKey:@"msg"] != nil) {
                        _usernameDataDownloadSuccessful = true;
                        if ([[_usernameUniqueRequestReply objectForKey:@"msg"] isEqualToString:@"unique"]) {
                            NSLog(@"Verified username is Unique");
                            _usernameUnique = true;
                            if (_usernameUnique && _emailUnique) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpVerified" object:self userInfo:nil];
                            }
                            //SHOW USERNAME IS VALID SOMEWHERE IN UI
                        }
                        else {
                            if (!_isShowingError) {
                                _isShowingError = true;
                                [self throwAlertWithTitle:@"Username already in use" message:@"Please choose a different username"];
                            }
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
    [dataDic setObject:email forKey:@"email_address"];
    //creates a dictionary for sending the request - puts it under the data heading to match what the database expects
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:dataDic forKey:@"data"];
    //NSLog(@"%@", tmpDic);
    
    //error handler
    NSError *error;
    
    //creates the json data for the url request
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    
    //creates url for request
    //production URL
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/users/unique_email.json"];
    //testing URL
    //NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users/unique_email.json"];
    
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
                _emailUniqueRequestReply = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                NSLog(@"Email requestReply: %@", _emailUniqueRequestReply);
                NSLog(@"%@", [[_emailUniqueRequestReply class] description]);
                
                //if the response is the valid type it indicates the download is successful and proceeds with the segue back to the main page, if unsuccessful it proceeds while leaving the downloadSuccessful as false (the segue delegate method uses this to determine what data to pass to the Items view controller
                if ([_emailUniqueRequestReply objectForKey:@"msg"] != nil) {
                    _emailDataDownloadSuccessful = true;
                    if ([[_emailUniqueRequestReply objectForKey:@"msg"] isEqualToString:@"unique"]) {
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
                        if (!_isShowingError) {
                            _isShowingError = true;
                            [self throwAlertWithTitle:@"Email already in use" message:@"Please choose a different email"];
                        }
                        _emailUnique = false;
                    }
                }
                else {
                    [self throwAlertWithTitle:@"Server Error" message:@"Unable to process your request."];
                }
            }
            //logs if data is nil and the phone did not connect to a server
            else {
                NSLog(@"NO DATA RECEIVED FROM USER CREATION REQUEST");
                [self throwAlertWithTitle:@"Connection Error" message:@"Could not connect to create user."];
                
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
    [tmpDic setObject:_firstName forKey:@"user_first_name"];
    [tmpDic setObject:_lastName forKey:@"user_last_name"];
    [tmpDic setObject:_address forKey:@"user_address"];
    //JSON Upload
    //converts the dictionary to json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&myError];
    //logs the data to check if it is created successfully
    //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    //creates url for the request
    //production URL
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/users.json"];
    //testing URL
    //NSURL *url = [NSURL URLWithString:@"http://localhost:3001/users.json"];
    
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
            NSLog(@"requestReply: %@", requestReply);
            //if the result has the class type __NSCFConstantString then the item failed to upload
            if ([[[requestReply class] description] isEqualToString:@"__NSCFConstantString"]) {
                //alert for failing to upload
                [self throwAlertWithTitle:@"No Connection\n" message:@"Could not create user. Please check your internet connection and try again."];
            }
            else {
                //opens user defaults to save data locally
                NSLog(@"%@", _result);
                NSInteger *userID = (NSInteger *)[[_result objectForKey:@"id"] integerValue];
                if (userID == 0) {
                    [self throwAlertWithTitle:@"No Connection\n" message:@"Could not create user. Please check your internet connection and try again."];
                }
                else {
                    NSLog(@"User ID From download: %@", [NSString stringWithFormat:@"%zd", userID]);
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[NSString stringWithFormat:@"%zd", userID] forKey:@"user_id"];
                    [defaults setObject:[NSNumber numberWithBool:true] forKey:@"logged_in"];
                    [defaults setObject:[_result objectForKey:@"username"] forKey:@"username"];
                    [defaults setObject:_password forKey:@"password"];
                    [defaults setObject:[_result objectForKey:@"user_first_name"] forKey:@"first_name"];
                    [defaults setObject:[_result objectForKey:@"user_last_name"] forKey:@"last_name"];
                    [defaults setObject:[_result objectForKey:@"user_address"] forKey:@"address"];
                    [defaults setObject:[_result objectForKey:@"email_address"] forKey:@"email"];
                    [defaults setObject:[_result objectForKey:@"user_unique_key"] forKey:@"unique_key"];
                    NSLog(@"Unique Key: %@", [_result objectForKey:@"user_unique_key"]);
                    //transitions back to page it came from (property booleans needed here
                    [self performSegueWithIdentifier:@"toHome" sender:(self)];
                }
            }
        });
    }] resume];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"signUpVerified"
                                                  object:nil];
}

-(void)throwAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


-(IBAction)signUp:(id)sender {
    //closes all keyboards
    [self.view endEditing:YES];
    
    _usernameUnique = false;
    _emailUnique = false;
    _isShowingError = false;
    _email = emailTextField.text;
    _username = usernameTextField.text;
    _password = passwordTextField.text;
    _firstName = firstNameTextField.text;
    _lastName = lastNameTextField.text;
    _address = addressTextField.text;
    NSString *passwordCheck = passwordVerificationTextField.text;
    if ([_email isEqualToString:@""]
        || [_username isEqualToString:@""]
        || [_firstName isEqualToString:@""]
        || [_lastName isEqualToString:@""]
        || [_address isEqualToString:@""]
        || [_password isEqualToString:@""]
        || [passwordCheck isEqualToString:@""]) {
        
        if ([_firstName isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing First Name" message:@"Please add your first name. This is required to ship your purchases to you."];
        }
        else if ([_lastName isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing Last Name" message:@"Please add your last name. This is required to ship your purchases to you."];
        }
        else if ([_address isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing Address" message:@"Please add your address. This is required to ship your purchases to you."];
        }
        else if ([_username isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing Username" message:@"Please create your username."];
        }
        else if ([_email isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing Email" message:@"Please add email, this is used to contact you about purchases."];
        }
        else if ([_password isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing Password" message:@"Please make your password."];
        }
        else if ([passwordCheck isEqualToString:@""]) {
            [self throwAlertWithTitle:@"Missing Password Verification" message:@"Please verify your password."];
        }
        else {
            [self throwAlertWithTitle:@"Missing Information" message:@"Please ensure you typed all of your information."];
        }
    }
    else {
        if ([_password isEqualToString:passwordCheck]) {
            [self uniqueUsername:_username];
            [self uniqueEmail:_email];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(addAccount)
                                                         name:@"signUpVerified"
                                                       object:nil];
        }
        else {
            [self throwAlertWithTitle:@"Passwords Don't Match" message:@"Please retype your password."];
        }
    }
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
    firstNameTextField.delegate = self;
    lastNameTextField.delegate = self;
    addressTextField.delegate = self;
    passwordVerificationTextField.delegate = self;
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
