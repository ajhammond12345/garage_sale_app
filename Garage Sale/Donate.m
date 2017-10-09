//
//  Donate.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Donate.h"
#import "Item.h"


@interface Donate () <UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation Donate

//run when user clicks on the image or the camera button
-(IBAction)selectImage:(id)sender {
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
    image = tmpImage;
    imageUploaded = true;
    [imageView setBackgroundImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//this is the method run when the users submits an item
-(IBAction)done:(id)sender {
    [self.view endEditing:YES];

    //first need to check that all fields have data
    if ([name isEqualToString:@""] || [condition isEqualToString:@""] || [description isEqualToString:@""] || priceInCents == 0 || !imageUploaded) {
        NSString *errorMessage;
        if ([name isEqualToString:@""]) {
            errorMessage = @"Please put in a name for the item";
        }
        else if ([condition isEqualToString:@""]) {
            errorMessage = @"Please select a condition for this item";
        }
        else if ([description isEqualToString:@""]) {
            errorMessage = [NSString stringWithFormat: @"Please provide a brief description of your item"];
        }
        else if (priceInCents == 0) {
            errorMessage = @"Please suggest a price";
        }
        else if (!imageUploaded) {
            errorMessage = @"Please take a picture of this item by selecting the camera button.";
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
        Item *newItem = [[Item alloc] init];
        newItem.name = name;
        newItem.image = image;
        newItem.condition = conditionInt;
        newItem.priceInCents = priceInCents;
        NSLog(@"%zd", newItem.priceInCents);
        newItem.itemDescription = description;
        //Note: item has not been liked (does nothing except prevent nil from stopping dictionary creation)
        newItem.liked = false;
        //0 means it has not been purchased
        newItem.itemPurchaseState = 0;
    
        
        //Then upload the item to the database
        //refreshes the internal item dictionary
        [newItem setItemDictionary];
        
        //creates error handler
        NSError *error;
        
        //creates mutable copy of the dictionary to remove extra keys
        NSMutableDictionary *tmpDic = [newItem.localDictionary mutableCopy];
        
        //removes extra keys (item_image is replaced with a different key for the image data)
        [tmpDic removeObjectForKey:@"id"];
        [tmpDic removeObjectForKey:@"item_image"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *userID = [defaults objectForKey:@"user_id"];
        [tmpDic setObject:userID forKey:@"user_id"];
        NSData *imageData = UIImageJPEGRepresentation(image, .6);
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
        NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/items.json"];
        //testing url
        //NSURL *url = [NSURL URLWithString:@"http://localhost:3001/items.json"];

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
            dispatch_async(dispatch_get_main_queue(), ^{
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"requestReply: %@", [[requestReply class] description]);
                //if the result has the class type __NSCFConstantString then the item failed to upload
                if ([[[requestReply class] description] isEqualToString:@"__NSCFConstantString"]) {
                    //alert for failing to upload
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection\n" message:@"Could not donate the item. Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    //opens user defaults to save data locally
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSArray *donatedArray = [defaults objectForKey:@"DonatedItems"];
                    NSMutableArray *tmpDonatedItems = [[NSMutableArray alloc] init];
                    //creates array with all of the saved items
                    for (int i = 0; i < donatedArray.count; i++) {
                        NSDictionary *tmpDic = [donatedArray objectAtIndex:i];
                        [tmpDonatedItems addObject:[self itemFromDictionaryInternal:tmpDic]];
                    }
                    //adds the new item to the donated list
                    [tmpDonatedItems addObject:[self itemFromDictionaryInternal:newItem.localDictionary]];
                    //transitions to the thank you page
                    [self performSegueWithIdentifier:@"showDonationThankYou" sender:(self)];
                }
            });
        }] resume];
                           
  
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
            tmpName = [NSString stringWithFormat:@"%@%@",[[tmpName substringToIndex:1] uppercaseString],[tmpName substringFromIndex:1] ];
            name = tmpName;
            nameTextField.text = tmpName;
        }
        else {
            nameTextField.text = @"";
            name = @"";
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
        priceInCents = (NSInteger *)finalPriceInCents;
        NSLog(@"%zd", priceInCents);
        //outputting formatted input
        priceTextField.text = [NSString stringWithFormat:@"$%@.%@", dollars, cents];
        if ([priceTextField.text isEqualToString:@"$0.00"]) {
            priceTextField.text = @"";
            priceInCents = nil;
            priceTextField.placeholder = @"$0.00";
        }
    }
    //closes keyboard
    [textField resignFirstResponder];
    [self.view endEditing:YES];
}

//closes the picker view
-(void)clearPickerView {
    [conditionTextField resignFirstResponder];
}

//for condition (not directly edited, uses a picker instead)
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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
    return conditionOptionsDonate.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return conditionOptionsDonate[row];
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //if user selected a row with data in it, it saves that data as the selected condition
    if (row != 0) {
        conditionTextField.text = conditionOptionsDonate[row];
        long rowTmp = row;
        conditionInt = (NSInteger *)rowTmp;
        condition = conditionOptionsDonate[row];
    }
    //if user selects --select-- (meant to be an empty option) it saves the condition selected as empty
    else {
        conditionTextField.text = @"";
        conditionTextField.placeholder = @"Condition";
        condition = @"";
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
        description = [NSString stringWithFormat:@"%@%@",[[descriptionTextView.text substringToIndex:1] uppercaseString],[descriptionTextView.text substringFromIndex:1] ];
        descriptionTextView.text = description;
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
    UIBarButtonItem *finished = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(clearPickerView)];
    //adds the done button
    [_toolBar setItems:@[finished] animated: false];
    _toolBar.userInteractionEnabled = true;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //initializes the variables to be empty (prevents needing to account for both empty and null when verifying user input)
    name = @"";
    condition = @"";
    priceInCents = 0;
    description = @"";
    //creats the conditions array
    conditionOptionsDonate = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    
    //sets the delegate for the text fields
    nameTextField.delegate = self;
    conditionTextField.delegate = self;
    descriptionTextView.delegate = self;
    priceTextField.delegate = self;
    tmpLabel.hidden = YES;
    imageUploaded = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
