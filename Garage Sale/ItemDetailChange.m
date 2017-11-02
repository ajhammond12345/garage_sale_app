//
//  ItemDetailChange.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "ItemDetailChange.h"
#import "Utility.h"




@interface ItemDetailChange () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ItemDetailChange






-(IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"returnToItems" sender:self];
}

//runs before segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //if going to the comments page it sets the current item to the item for the comments page to use when displaying comments
    if ([segue.identifier isEqualToString: @"returnToItems"]) {
        UserPage *destinationViewController = segue.destinationViewController;
        destinationViewController.donatedItems = _items;
        
    }
}

//updates all parts of the UI for the page (easy method to call when data loads or changes (i.e. liked or purchased)
-(void)updateView {
    //hides the purchased button to ensure it won't incorrectly show up
    purchased.hidden = YES;
    
    //sets the name text
    nameTextField.text = _itemOnDisplay.name;
    
    //gets the int that represents condition (indicative of its position in the conditions array)
    int index = (int) _itemOnDisplay.condition;
    
    //loads the conditions array
    NSArray *conditionOptionsDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    
    //sets the condition text based on index value
    conditionTextField.text = conditionOptionsDetail[index];
    
    //displays the price (uses helper method from the Item class to convert the int in cents to a string in $)
    priceTextField.text = [_itemOnDisplay getPriceString];
    
    //displays the description text
    descriptionTextView.text = _itemOnDisplay.itemDescription;
    
    //if item liked, sets the heart to solid
    
    //if the item has an image (server errors may cause it to be missing an image) it displays it
    if (_itemOnDisplay.image != nil) {
        [imageView setBackgroundImage:_itemOnDisplay.image forState:UIControlStateNormal];
    }
    else {
        //if missing the image it shows a default image that shows the image is missing
        [imageView setBackgroundImage:[UIImage imageNamed:@"missing.png"] forState:UIControlStateNormal];
    }
    
    //if item purchased, it shows the purchased image, if not it hides it
    if ([self isItemPurchased]) {
        purchased.hidden = NO;
    }
    else {
        purchased.hidden = YES;
    }
}








-(bool)textViewShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return true;
}












-(bool)isItemPurchased {
    if ([_itemOnDisplay.itemPurchaseState intValue] == 1) {
        return true;
    }
    else {
        return false;
    }
}


-(IBAction)selectImageAction:(id)sender {
    if (![self isItemPurchased]) {
        [self selectImage];
    }
}


//run when user clicks on the image or the camera button
-(void)selectImage {
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
    _itemOnDisplay.image = tmpImage;
    _imageUpdated = true;
    [imageView setBackgroundImage:_theNewImage forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//this is the method run when the users submits an item
-(IBAction)save:(id)sender {
    [self.view endEditing:YES];
    Item *newItem = [[Item alloc] init];
    
    //first need to check that all fields have data
    if ([_theNewName isEqualToString:@""]
        || [_theNewCondition isEqualToString:@""]
        || [_theNewDescription isEqualToString:@""]
        || _theNewPriceInCents == 0) {
        NSString *errorMessage;
        if ([_theNewName isEqualToString:@""]) {
            errorMessage = @"Please put in a name for the item";
        }
        else if ([_theNewCondition isEqualToString:@""]) {
            errorMessage = @"Please select a condition for this item";
        }
        else if ([_theNewDescription isEqualToString:@""]) {
            errorMessage = [NSString stringWithFormat: @"Please provide a brief description of your item"];
        }
        else if (_theNewPriceInCents == 0) {
            errorMessage = @"Please suggest a price";
        }
        //shows error message for missing information
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    //if all information present
    else {
        //closes keyboards
        [self.view endEditing:YES];
        //creates the Item object
        newItem.name = _theNewName;
        newItem.image = _theNewImage;
        newItem.condition = _theNewConditionInt;
        newItem.priceInCents = _theNewPriceInCents;
        NSLog(@"%zd", newItem.priceInCents);
        newItem.itemDescription = _theNewDescription;
        //Note: item has not been liked (does nothing except prevent nil from stopping dictionary creation)
        newItem.liked = _itemOnDisplay.liked;
        //0 means it has not been purchased
        newItem.itemPurchaseState = _itemOnDisplay.itemPurchaseState;
        //checks to see if any data changed, if any has it reuploads,
        //if not it simply presents the segue back to the main list
        if (![_theNewName isEqualToString:_itemOnDisplay.name]
            || ![_theNewDescription isEqualToString:_itemOnDisplay.itemDescription]
            || !(_theNewConditionInt == _itemOnDisplay.condition)
            || !(_theNewPriceInCents == _itemOnDisplay.priceInCents)
            || _imageUpdated) {
            
            
            //Then upload the item to the database
            //refreshes the internal item dictionary
            [newItem setItemDictionary];
            
            //creates error handler
            NSError *error;
            
            //creates mutable copy of the dictionary to remove extra keys
            NSMutableDictionary *tmpDic = [newItem.localDictionary mutableCopy];
            //removes extra keys (item_image is replaced with a different key for the image data)
            //NSLog(@"\n\n\n\n\n\nItem ID: %zd\n\n\n\n\n\n\n", _itemOnDisplay.itemID);
            [tmpDic removeObjectForKey:@"item_image"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSNumber *userID = [defaults objectForKey:@"user_id"];
            NSString *uniqueKey = [defaults objectForKey:@"unique_key"];
            [tmpDic setObject:userID forKey:@"user_id"];
            [tmpDic setObject:uniqueKey forKey:@"user_unique_key"];
            NSData *imageData = UIImageJPEGRepresentation(_theNewImage, .6);
            NSString *imageBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            //NSLog(@"Upload Data: %@", imageBase64);
            [tmpDic setObject:imageBase64 forKey:@"va_image_data"];
            [tmpDic setObject:[NSString stringWithFormat:@"%i", 0] forKey:@"item_purchase_state"];
            
            //JSON Upload - does not upload the image
            //converts the dictionary to json
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
            //logs the data to check if it is created successfully
            NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
            
            //creates url for the request
            
            //production url
            NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _itemOnDisplay.itemID]];
            //testing url
            //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3001/items/%zd.json", _itemOnDisplay.itemID]];
            
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
                    NSError *jsonError;
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSLog(@"requestReply Type: %@\nrequestReply: %@", [[requestReply class] description], requestReply);
                    NSDictionary *check = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    //if the result has the class type __NSCFConstantString then the item failed to upload
                    if (![[check objectForKey:@"msg"] isEqualToString:@"updated"]) {
                        //alert for failing to upload
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to update item\n" message:@"Could not update the item. Please check your internet connection and try again. You may need to logout and log back in." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                        [self performSegueWithIdentifier:@"returnToItems" sender:(self)];
                    }
                });
            }] resume];
        }
        else {
            [self performSegueWithIdentifier:@"returnToItems" sender:self];
        }
    }
    
}

-(Item *)itemFromDictionaryInternal:(NSDictionary *) dictionary {
    Item *tmpItem = [[Item alloc] init];
    tmpItem.name = [dictionary objectForKey:@"item_name"];
    tmpItem.condition = (NSInteger *)[[dictionary objectForKey:@"item_condition"] integerValue];
    tmpItem.itemDescription = [dictionary objectForKey:@"item_description"];
    NSData *imageData = [dictionary objectForKey:@"item_image"];
    if (imageData != nil) {
        tmpItem.image = [UIImage imageWithData:imageData];
    }
    tmpItem.priceInCents = (NSInteger*)[[dictionary objectForKey:@"item_price_in_cents"] integerValue];
    //NSLog(@"%@", [dictionary objectForKey:@"item_description"]);
    tmpItem.liked = [[dictionary objectForKey:@"liked"] boolValue];
    NSInteger *tmpID = (NSInteger*)[[dictionary objectForKey:@"id"] integerValue];
    //NSLog(@"%@", [dictionary objectForKey:@"id"]);
    //NSLog(@"%zd", tmpID);
    tmpItem.itemID = tmpID;
    tmpItem.itemPurchaseState = (NSNumber *)[dictionary objectForKey:@"item_purchase_state"];
    NSArray *tmpComments = [dictionary objectForKey:@"item_comments"];
    [tmpItem.comments removeAllObjects];
    for (int i = 0; i < tmpComments.count; i++) {
        [tmpItem.comments addObject:[tmpComments objectAtIndex:i]];
    }
    return tmpItem;
}

// Control methods for each text/image view

//makes keyboard disappear after finished editing
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}



//makes keyboard disappear after finished editing
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


//for the text fields that are directly edited (name and price)
-(void)textFieldDidEndEditing:(UITextField *)textField {
    //if editing the name text field it checks to see if the width of name (as it would appear on UI) is too wide, if not it adds it, if so it provides alert for shorter name
    if ([textField isEqual: nameTextField]) {
        NSString *tmpName = nameTextField.text;
        tmpLabel.text = tmpName;
        tmpLabel.hidden = YES;
        [tmpLabel sizeToFit];
        NSLog(@"%f", tmpLabel.frame.size.width);
        if (tmpLabel.frame.size.width < 180) {
            if (![tmpName isEqualToString:@""]) {
                tmpName = [NSString stringWithFormat:@"%@%@",[[tmpName substringToIndex:1] uppercaseString],[tmpName substringFromIndex:1] ];
                _theNewName = tmpName;
                nameTextField.text = tmpName;
            }
        }
        else {
            nameTextField.text = @"";
            _theNewName = @"";
            nameTextField.placeholder = @"Name of Item";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Name\n" message:@"Please use a shorter name" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    //if user was editting price it updates the price field and formats the input to be displayed in the text field
    if ([textField isEqual: priceTextField]) {
        NSString *cents;
        NSString *dollars;
        int priceCents;
        int priceDollars;
        long finalPriceInCents;
        //formatting input
        for (int i = 0; i < priceTextField.text.length; i++) {
            if ([[[priceTextField.text substringFromIndex:i] substringToIndex:1] isEqualToString:@"."]) {
                cents = [priceTextField.text substringFromIndex:i];
                dollars = [priceTextField.text substringToIndex:i];
                break;
            }
        }
        if (dollars == nil) {
            dollars = priceTextField.text;
            if ([dollars isEqualToString:@""]) {
                dollars = @"0";
            }
        }
        if (cents == nil) {
            cents = @".00";
        }
        NSCharacterSet *mySet = [NSCharacterSet characterSetWithCharactersInString:@"."];
        cents = [cents stringByTrimmingCharactersInSet:mySet];
        if (cents.length == 1) {
            [cents stringByAppendingString:@"0"];
        }
        priceCents = (int)[cents integerValue];
        dollars = [dollars stringByTrimmingCharactersInSet:mySet];
        priceDollars = (int)[dollars integerValue];
        NSLog(@"Price: %@%i", dollars, priceDollars);
        //saving input
        finalPriceInCents = (priceDollars * 100) + priceCents;
        _theNewPriceInCents = (NSInteger *)finalPriceInCents;
        NSLog(@"%zd", _theNewPriceInCents);
        //outputting formatted input
        priceTextField.text = [NSString stringWithFormat:@"$%@.%@", dollars, cents];
        if ([priceTextField.text isEqualToString:@"$0.00"]) {
            priceTextField.text = @"";
            _theNewPriceInCents = nil;
            priceTextField.placeholder = @"$0.00";
        }
    }
    //closes keyboard
    [textField resignFirstResponder];
    [self.view endEditing:YES];
}

//closes the picker view
-(void)clearEdit {
    [self.view endEditing:YES];
}

//for condition (not directly edited, uses a picker instead)
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self isItemPurchased]) {
        [Utility throwAlertWithTitle:@"Item Sold" message:@"This item has been purchased. No changes are allowed." sender:self];
        return false;
    }
    if (textField.tag == 2 || [textField isEqual:conditionTextField]) {
        _conditionPicker = [[UIPickerView alloc] init];
        _conditionPicker.dataSource = self;
        _conditionPicker.delegate = self;
        _conditionPicker.showsSelectionIndicator = YES;
        conditionTextField.inputView = _conditionPicker;
        textField.inputView = _conditionPicker;
        UIButton *doneButton = [[UIButton alloc] init];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        textField.inputAccessoryView = _toolBar;
    }
    if ([textField isEqual: priceTextField]) {
        textField.inputAccessoryView = _toolBar;
        priceTextField.text = @"";
    }
    return YES;
}


//number of columns - only one for condition
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _conditionOptionsItemUpdate.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _conditionOptionsItemUpdate[row];
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //if user selected a row with data in it, it saves that data as the selected condition
    if (row != 0) {
        conditionTextField.text = _conditionOptionsItemUpdate[row];
        long rowTmp = row;
        _theNewConditionInt = (NSInteger *)rowTmp;
        _theNewCondition = _conditionOptionsItemUpdate[row];
    }
    //if user selects --select-- (meant to be an empty option) it saves the condition selected as empty
    else {
        conditionTextField.text = @"";
        conditionTextField.placeholder = @"Condition";
        _theNewCondition = @"";
    }
}

//updates the description with the user input
-(void)textViewDidEndEditing:(UITextView *)textView {
    //creates a copy of the string with whitespace removed to check if visible text has been entered so they will not lose the text box
    NSString *tmp = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tmp isEqual: @""]) {
        descriptionTextView.text = [NSString stringWithFormat:@"Insert description here"];
    }
    else {
        _theNewDescription = [NSString stringWithFormat:@"%@%@",[[descriptionTextView.text substringToIndex:1] uppercaseString],[descriptionTextView.text substringFromIndex:1] ];
        descriptionTextView.text = _theNewDescription;
    }
    //closes keyboard
    [textView resignFirstResponder];
}

//if description has placeholder text in there it empties it (no built in support for placeholder text for text views)
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Insert description here"]) {
        textView.text = [NSString stringWithFormat:@""];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextField *)textField {
    if ([self isItemPurchased]) {
        [Utility throwAlertWithTitle:@"Item Sold" message:@"This item has been purchased. No changes are allowed." sender:self];
        return false;
    }
    return true;
}

//dismisses keyboards when large button in background clicked - enables users to navigate away from editting in an intelligent way
-(IBAction)dismissKeyBoards:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {

    //creates a 'done' toolbar to be used for all non-keyboard inputs
    _toolBar = [[UIToolbar alloc] init];
    _toolBar.barStyle = UIBarStyleDefault;
    _toolBar.translucent = true;
    [_toolBar sizeToFit];
    //creates the done button for the toolbar
    UIBarButtonItem *finished = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(clearEdit)];
    //adds the done button
    [_toolBar setItems:@[finished] animated: false];
    _toolBar.userInteractionEnabled = true;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //initializes the variables to be empty (prevents needing to account for both empty and null when verifying user input)
    _theNewName = _itemOnDisplay.name;
    _theNewConditionInt = _itemOnDisplay.condition;
    _theNewPriceInCents = _itemOnDisplay.priceInCents;
    _theNewDescription = _itemOnDisplay.itemDescription;
    //creats the conditions array
    _conditionOptionsItemUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    _theNewCondition = [_conditionOptionsItemUpdate objectAtIndex:(long)_theNewConditionInt];
    _theNewImage = _itemOnDisplay.image;
    
    
    //sets the delegate for the text fields
    nameTextField.delegate = self;
    conditionTextField.delegate = self;
    descriptionTextView.delegate = self;
    priceTextField.delegate = self;
    tmpLabel.hidden = YES;
    _imageUpdated = false;
    [self updateView];
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
