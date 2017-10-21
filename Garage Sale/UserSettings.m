//
//  UserSettings.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/10/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "UserSettings.h"
#import "NameCell.h"
#import "EditableCell.h"
#import "Utility.h"

@interface UserSettings () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation UserSettings

-(IBAction)save:(id)sender {
    [self.view endEditing:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *originalUsername = [defaults objectForKey:@"username"];
    NSString *originalFirstName = [defaults objectForKey:@"first_name"];
    NSString *originalLastName = [defaults objectForKey:@"last_name"];
    NSString *originalAddress = [defaults objectForKey:@"address"];
    NSString *originalEmail = [defaults objectForKey:@"email"];

    
    NSLog(@"%@", _username);
    NSLog(@"%@", _firstName);
    NSLog(@"%@", _lastName);
    NSLog(@"%@", _email);
    NSLog(@"%@", _address);

    
    
    //NEED TO ADD PASSWORD
    if (![_username isEqualToString:originalUsername]
        || ![_firstName isEqualToString:originalFirstName]
        || ![_lastName isEqualToString:originalLastName]
        || ![_email isEqualToString:originalEmail]
        || ![_address isEqualToString:originalAddress]) {
        NSLog(@"FUCK XCODE");
        NSError *error;
        
        //creates mutable copy of the dictionary to remove extra keys
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
        [tmpDic setObject:_username forKey:@"username"];
        [tmpDic setObject:_firstName forKey:@"user_first_name"];
        [tmpDic setObject:_lastName forKey:@"user_last_name"];
        [tmpDic setObject:_email forKey:@"email_address"];
        [tmpDic setObject:_address forKey:@"user_address"];
        //removes extra keys (item_image is replaced with a different key for the image data)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *userID = [defaults objectForKey:@"user_id"];
        [tmpDic setObject:userID forKey:@"id"];
        
        //JSON Upload - does not upload the image
        //converts the dictionary to json
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
        //logs the data to check if it is created successfully
        NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        //creates url for the request
        
        //production url
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/users/%zd.json", [userID integerValue]]];
        //testing url
        //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3001/users/%zd.json", [userID integerValue]]];
        //NSLog(url.path);
        //creates a URL request
        NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        //specifics for the request (it is a post request with json content)
        [uploadRequest setHTTPMethod:@"PATCH"];
        [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [uploadRequest setHTTPBody: jsonData];
        
        //create some type of waiting image here
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        //runs the data task
        [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"requestReply Type: %@\nrequestReply: %@", [[requestReply class] description], requestReply);
                //if the result has the class type __NSCFConstantString then the item failed to upload
                if ([[[requestReply class] description] isEqualToString:@"__NSCFConstantString"]) {
                    //alert for failing to upload
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection\n" message:@"Could not update the item. Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    [defaults setObject:_username forKey:@"username"];
                    [defaults setObject:_firstName forKey:@"first_name"];
                    [defaults setObject:_lastName forKey:@"last_name"];
                    [defaults setObject:_address forKey:@"address"];
                    [defaults setObject:_email forKey:@"email"];
                    [self performSegueWithIdentifier:@"returnFromSettings" sender:self];

                }
            });
        }] resume];
    }
    else {
        NSLog(@"FUCK XCODE");
        [self performSegueWithIdentifier:@"returnFromSettings" sender:self];
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
        EditableCell *cell = (EditableCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell startEditing];
    }
    if (indexPath.row == 8) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *loggedOut = [NSNumber numberWithBool:false];
        [defaults setObject:loggedOut forKey:@"logged_in"];
        [self performSegueWithIdentifier:@"returnToHomePage" sender:self];
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            NameCell *cell = (NameCell *)[tableView dequeueReusableCellWithIdentifier:@"nameCell" forIndexPath:indexPath];
            cell.firstName = _firstName;
            cell.lastName = _lastName;
            cell.userPhoto = _userPhoto;
            cell.superView = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell updateCell];
            //[cells addObject:cell];
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        case 2: {
            EditableCell *cell = (EditableCell *)[tableView dequeueReusableCellWithIdentifier:@"editableCell" forIndexPath:indexPath];
            cell.type = @"Username";
            cell.text = _username;
            cell.fieldBeingEditted = 2;
            cell.superView = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell updateCell];
            return cell;
        }
        case 3: {
            EditableCell *cell = (EditableCell *)[tableView dequeueReusableCellWithIdentifier:@"editableCell" forIndexPath:indexPath];
            cell.type = @"Email";
            cell.text = _email;
            cell.fieldBeingEditted = 3;
            cell.superView = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell updateCell];
            return cell;
        }
        case 4: {
            EditableCell *cell = (EditableCell *)[tableView dequeueReusableCellWithIdentifier:@"editableCell" forIndexPath:indexPath];
            cell.type = @"Address";
            cell.text = _address;
            cell.fieldBeingEditted = 4;
            cell.superView = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell updateCell];
            return cell;
        }
        case 5: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        case 6: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"passwordCell" forIndexPath:indexPath];
            return cell;
        }
        case 7: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        case 8: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signOutCell" forIndexPath:indexPath];
            return cell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCell" forIndexPath:indexPath];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (void)viewDidLoad {
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _userPhoto = [Utility loadImageWithFileName:@"user_photo" ofType:@"jpg" inDirectory:documentsDirectory];
    /*
     The layout for the settings page is created here
         0. An Image/Name cell that opens to another view controller where they can change their profile pic and name
             identifier: "nameCell"
         1. EMPTY CELL
             identifier: "emptyCell"
         2. username cell
             identifier: "editableCell"
         3. email cell
             identifier: "editableCell"
         4. address cell
             identifier: "editableCell"
         5. EMPTY CELL
             identifier: "emptyCell"
         6. change password cell -> opens a pop up
             identified: "passwordCell"
         7. EMPTY CELL
             identifier: "emptyCell"
         8. sign out cell
             identifier: "signOutCell"
     */
    [super viewDidLoad];
    settingsList.delegate = self;
    settingsList.dataSource = self;
    
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
