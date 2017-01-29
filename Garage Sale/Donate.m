//
//  Donate.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Donate.h"
#import "Item.h"
#import "AFNetworking.h"


@interface Donate () <UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation Donate

-(IBAction)selectImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:picker animated:true completion:nil];
    }];
    UIAlertAction *photoAlbum = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:picker animated:true completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [alert addAction:camera];
    [alert addAction:photoAlbum];
    [alert addAction:cancel];
    [self presentViewController:alert animated:true completion:nil];
}

//delegate methods for image picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //saves the selected image to the image field
    UIImage *tmpImage = info[UIImagePickerControllerEditedImage];
    image = tmpImage;
    [imageView setBackgroundImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


-(IBAction)done:(id)sender {
    [self.view endEditing:YES];

    //first need to check that all fields have data
    if ([name isEqualToString:@""] || [condition isEqualToString:@""] || [description isEqualToString:@""] || priceInCents == 0 || [image isEqual:nil]) {
        //shows error message for missing information
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill out all of the required information." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        [self.view endEditing:YES];
        //Then create the Item object
        Item *newItem = [[Item alloc] init];
        newItem.name = name;
        newItem.image = image;
        newItem.condition = conditionInt;
        newItem.priceInCents = priceInCents;
        NSLog(@"%zd", newItem.priceInCents);
        newItem.itemDescription = description;
        //item has not been liked (does nothing except prevent nil from stopping dictionary creation)
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
        
        //removes extra keys (image is uploaded later)
        [tmpDic removeObjectForKey:@"liked"];
        [tmpDic removeObjectForKey:@"id"];
        [tmpDic removeObjectForKey:@"item_image"];
        NSData *imageData = UIImageJPEGRepresentation(image, .6);
        NSString *imageBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        //NSLog(@"Upload Data: %@", imageBase64);
        [tmpDic setObject:imageBase64 forKey:@"va_image_data"];
        [tmpDic setObject:[NSString stringWithFormat:@"%i", 0] forKey:@"item_purchase_state"];

 //JSON Upload - does not upload the image
        //converts the dictionary to json
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
        //logs the data to check if it is created successfully
        //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        //creates url for the request
        NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/items.json"];

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
        
        [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"requestReply: %@", [[requestReply class] description]);
                if ([[[requestReply class] description] isEqualToString:@"__NSCFConstantString"]) {
                    //alert for failing to upload
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection\n" message:@"Could not donate the item. Please check your internet connection and try again." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else {
                    [self performSegueWithIdentifier:@"showDonationThankYou" sender:(self)];
                }
            });
        }] resume];
                           
  
    }
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
    if ([textField isEqual: nameTextField]) {
        NSString *tmpName = nameTextField.text;
        tmpLabel.text = tmpName;
        tmpLabel.hidden = YES;
        [tmpLabel sizeToFit];
        NSLog(@"%f", tmpLabel.frame.size.width);
        if (tmpLabel.frame.size.width < 180) {
            name = tmpName;
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
    if ([textField isEqual: priceTextField]) {
        NSString *cents;
        NSString *dollars;
        int priceCents;
        int priceDollars;
        long finalPriceInCents;
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
        finalPriceInCents = (priceDollars * 100) + priceCents;
        priceInCents = (NSInteger *)finalPriceInCents;
        NSLog(@"%zd", priceInCents);
        priceTextField.text = [NSString stringWithFormat:@"$%@.%@", dollars, cents];
        if ([priceTextField.text isEqualToString:@"$0.00"]) {
            priceTextField.text = @"";
            priceInCents = nil;
            priceTextField.placeholder = @"$0.00";
        }
    }
    [textField resignFirstResponder];
    [self.view endEditing:YES];
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
    }
    return YES;
    
}

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
    if (row != 0) {
        conditionTextField.text = conditionOptionsDonate[row];
        long rowTmp = row;
        conditionInt = (NSInteger *)rowTmp;
        condition = conditionOptionsDonate[row];
    }
    else {
        conditionTextField.text = @"";
        conditionTextField.placeholder = @"Condition";
        condition = @"";
    }
}

//for the description
-(void)textViewDidEndEditing:(UITextView *)textView {
    //creates a copy of the string with whitespace removed to check if visible text has been entered so they will not lose the text box
    NSString *tmp = [descriptionTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tmp isEqual: @""]) {
        descriptionTextView.text = [NSString stringWithFormat:@"Insert description here"];
    }
    else {
        description = descriptionTextView.text;
    }
    [textView resignFirstResponder];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Insert description here"]) {
        textView.text = [NSString stringWithFormat:@""];
    }
}

-(IBAction)dismissKeyBoards:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    name = @"";
    condition = @"";
    priceInCents = 0;
    description = @"";
    conditionOptionsDonate = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    
    nameTextField.delegate = self;
    conditionTextField.delegate = self;
    descriptionTextView.delegate = self;
    priceTextField.delegate = self;
    tmpLabel.hidden = YES;
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
