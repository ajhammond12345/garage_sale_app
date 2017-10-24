//
//  UserPage.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/10/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "UserPage.h"
#import "Utility.h"
#import "UserSettings.h"


@interface UserPage () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation UserPage


-(void)viewSwitched {
    if (_showAll) {
        _showAll = false;
        [donatedItemsView reloadData];
    }
    else {
        _showAll = true;
        [donatedItemsView reloadData];
    }
}


//when an item clicked in the table view it passes on the item info and shows the item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DonatedItemCustomCell *tmpCell = [donatedItemsView cellForRowAtIndexPath:indexPath];
    _itemToSend = tmpCell.item;
    [self performSegueWithIdentifier:@"showItemUpdate" sender:indexPath];
}

//delegate method used to load table view
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DonatedItemCustomCell *cell = (DonatedItemCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"displayDonatedItem" forIndexPath:indexPath];
    if (!_showAll) {
        //loads item from array of liked items if set to not show all
        cell.item = [_purchasedItems objectAtIndex:indexPath.row];
    }
    else {
        //loads item from array of all items if set to show all
        cell.item = [_donatedItems objectAtIndex:indexPath.row];
    }
    cell.parentTable = donatedItemsView;
    cell.cellPath = indexPath;
    //updates the views in the cell
    [cell updateCell];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showItemUpdate"]) {
        ItemDetailChange *destViewController = segue.destinationViewController;
        destViewController.itemOnDisplay = _itemToSend;
        destViewController.items = _donatedItems;
        [destViewController updateView];
    }
    if ([segue.identifier isEqualToString:@"toSettings"]) {
        UserSettings *destination = segue.destinationViewController;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        destination.username = [defaults objectForKey:@"username"];
        destination.firstName = [defaults objectForKey:@"first_name"];
        destination.lastName = [defaults objectForKey:@"last_name"];
        destination.address = [defaults objectForKey:@"address"];
        destination.email = [defaults objectForKey:@"email"];
    }
}

//provides the number of rows that will be in table view (just a count of the array)
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_showAll) {
        return _purchasedItems.count;
    }
    else {
        return _donatedItems.count;
    }
}

-(void)loadDonatedItems {
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    //goes through every field, if it is not empty it adds it to the dictionary (empty fields are handled by the database with default values)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    NSString *unique_key = [defaults objectForKey:@"unique_key"];
    [dataDic setObject:userID forKey:@"user_id"];
    [dataDic setObject:unique_key forKey:@"user_unique_key"];
    
    //error handler
    NSError *error;
    
    //creates the json data for the url request
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDic options:NSJSONWritingPrettyPrinted error:&error];
    
    
    
    //production URL
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/users/%@.json", userID]];
    //testing URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3001/users/%@/info.json", userID]];
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
    //initiates the url session with a handler that processes the data returned from the server
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
        //if the data is empty it will report an error, if not it will process the list of items returned by the filter parameters
        if (data != nil) {
            //error handler
            NSError *jsonError;
            //stores the response
            _result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            NSLog(@"Result: %@", _result);
            dispatch_async(dispatch_get_main_queue(), ^{
                //if the response is the valid type it indicates the download is successful and proceeds with the segue back to the main page, if unsuccessful it proceeds while leaving the downloadSuccessful as false (the segue delegate method uses this to determine what data to pass to the Items view controller
                if ([[_result objectForKey:@"msg"] isEqualToString:@"invalid_key"]) {
                    NSLog(@"Invalid login session");
                    [Utility throwAlertWithTitle:@"Invalid Session" message:@"Cannot verify login session. Please logout and log back in." sender:self];
                }
                else if ([_result objectForKey:@"items"] != nil) {
                    NSMutableArray *tmpDonatedItemArray = [[NSMutableArray alloc] init];
                    NSMutableArray *tmpPurchasedItemArray = [[NSMutableArray alloc] init];
                    NSArray *items = [_result objectForKey:@"items"];
                    NSLog(@"%@",items);
                    for (int i = 0; i < items.count; i++) {
                        NSDictionary *tmpDic = [items objectAtIndex:i];
                        NSLog(@"Dictionary %@", tmpDic);
                        Item *loadItem = [self itemFromDictionaryExternal:tmpDic];
                        NSLog(@"LoadItemID: %zd", loadItem.itemID);
                        //[self loadItemImage:loadItem];
                        [tmpDonatedItemArray addObject:loadItem];
                        if ([loadItem.itemPurchaseState isEqualToNumber:[[NSNumber alloc] initWithInt:1]]) {
                            [tmpPurchasedItemArray addObject:loadItem];
                        }
                    }
                    
                    //if data receieved it saves the interpreted data to the local array
                    if (tmpDonatedItemArray != nil) {
                        _donatedItems = tmpDonatedItemArray;
                    }
                    if (tmpPurchasedItemArray != nil) {
                        _purchasedItems = tmpPurchasedItemArray;
                    }
                    [donatedItemsView reloadData];
                    NSLog(@"%@", tmpDonatedItemArray);
                }
                else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Unable to process your request at this moment." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                                    {
                                                        
                                                    }];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
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

//Loads items from the dictionary passed by the server (uses URL for image grab)
-(Item *)itemFromDictionaryExternal:(NSDictionary *) dictionary {
    Item *tmpItem = [[Item alloc] init];
    tmpItem.name = [dictionary objectForKey:@"item_name"];
    tmpItem.condition = (NSInteger *)[[dictionary objectForKey:@"item_condition"] integerValue];
    tmpItem.itemDescription = [dictionary objectForKey:@"item_description"];
    NSDictionary *jsonImageFilepath = [dictionary objectForKey:@"item_image"];
    
    NSString *imageFilepath = [jsonImageFilepath objectForKey:@"url"];
    tmpItem.url = [NSString stringWithFormat:@"%@", imageFilepath];
    NSLog(@"%@", tmpItem.url);
    
    NSArray *fullComments =  [dictionary objectForKey:@"comments"];
    //NSLog(@"All comments:\n%@", fullComments);
    tmpItem.comments = [[NSMutableArray alloc] init];
    for (int i = 0; i < fullComments.count; i++) {
        NSDictionary *tmpDic = [fullComments objectAtIndex:i];
        //NSLog(@"Dictionary: %@", tmpDic);
        NSString *tmpString = [tmpDic objectForKey:@"comment_text"];
        //NSLog(@"Comment Text: %@", tmpString);
        [tmpItem addComment:tmpString];
        //NSLog(@"Comment Text in comments: %@", tmpItem.comments);
    }
    //NSLog(@"Item Comments: %@", tmpItem.comments);
    
    
    tmpItem.priceInCents = (NSInteger*)[[dictionary objectForKey:@"item_price_in_cents"] integerValue];
    
    tmpItem.liked = [[dictionary objectForKey:@"liked"] boolValue];
    tmpItem.userID = (NSInteger*)[[dictionary objectForKey:@"user_id"] integerValue];
    NSInteger *tmpID = (NSInteger*)[[dictionary objectForKey:@"id"] integerValue];
    NSLog(@"%@", [dictionary objectForKey:@"id"]);
    //NSLog(@"%zd", tmpID);
    tmpItem.itemID = tmpID;
    NSLog(@"Item ID when saved: %zd", tmpItem.itemID);
    tmpItem.itemPurchaseState = (NSNumber *)[dictionary objectForKey:@"item_purchase_state"];
    return tmpItem;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    _showAll = true;
    // Do any additional setup after loading the view.
    donatedItemsView.delegate = self;
    donatedItemsView.dataSource = self;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *firstName = [defaults objectForKey:@"first_name"];
    NSString *lastName = [defaults objectForKey:@"last_name"];
    NSString *address = [defaults objectForKey:@"address"];
    NSString *email = [defaults objectForKey:@"email"];
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    UIImage *image = [Utility loadImageWithFileName:@"user_photo" ofType:@"jpg" inDirectory:documentsDirectory];
    if (image) {
        [userImageButton setImage:image forState:UIControlStateNormal];
    }
    else {
        [userImageButton setImage:[UIImage imageNamed:@"userlogo.png"] forState:UIControlStateNormal];
    }
    userImageButton.imageView.layer.cornerRadius = userImageButton.frame.size.height / 2;
    navBar.title = username;
    name.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    addressLabel.text = address;
    emailLabel.text = email;
    [itemListType addTarget:self
                     action:@selector(viewSwitched)
           forControlEvents:UIControlEventValueChanged];
    [self loadDonatedItems];
}

-(IBAction)userPhoto:(id)sender {
    //creates image picker
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    //lets user choose camera or photo library
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //camera action
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //initiates picker with camera
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:picker animated:true completion:nil];
    }];
    //photo library action
    UIAlertAction *photoAlbum = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //initiates picker with photo library
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:picker animated:true completion:nil];
    }];
    //cancel action
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    //adds all of the actions
    [alert addAction:camera];
    [alert addAction:photoAlbum];
    [alert addAction:cancel];
    //presents the options
    [self presentViewController:alert animated:true completion:nil];
}

//delegate methods for image picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //saves the selected image to the image field
    UIImage *tmpImage = info[UIImagePickerControllerEditedImage];
    [userImageButton setImage:tmpImage forState:UIControlStateNormal];
    NSString * documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [Utility saveImage:tmpImage withFileName:@"user_photo" ofType:@"jpg" inDirectory:documentsDirectory];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(IBAction)toSettings:(id)sender {
    [self performSegueWithIdentifier:@"toSettings" sender:self];
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
