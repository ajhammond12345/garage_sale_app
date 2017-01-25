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
        newItem.condition = condition;
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
        
        //removes extra keys
        [tmpDic removeObjectForKey:@"liked"];
        [tmpDic removeObjectForKey:@"id"];
        NSString *priceString = [tmpDic objectForKey:@"item_price_in_cents"];
        NSLog(@"%@", priceString);
        NSString *imageData = [[tmpDic objectForKey:@"item_image"] base64EncodedStringWithOptions:0];
        [tmpDic setObject:imageData forKey:@"item_image"];
        //converts the dictionary to json
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
        //logs the data to check if it is created successfully
        //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        //creates url for the request
        NSURL *url = [NSURL URLWithString:@"http://localhost:3001/items.json"];

        //creates a URL request
        NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        //specifics for the request (it is a post request with json content)
        [uploadRequest setHTTPMethod:@"POST"];
        [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [uploadRequest setHTTPBody: jsonData];
        
        //
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", requestReply);
        }] resume];
        
        //perform segue to thank you screen
        [self performSegueWithIdentifier:@"showDonationThankYou" sender:(self)];
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
    name = nameTextField.text;
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
        }
        if (cents == nil) {
            cents = @".00";
        }
        NSCharacterSet *mySet = [NSCharacterSet characterSetWithCharactersInString:@"."];
        cents = [cents stringByTrimmingCharactersInSet:mySet];
        priceCents = (int)[cents integerValue];
        dollars = [dollars stringByTrimmingCharactersInSet:mySet];
        priceDollars = (int)[dollars integerValue];
        NSLog(@"Price: %@%i", dollars, priceDollars);
        finalPriceInCents = (priceDollars * 100) + priceCents;
        priceInCents = (NSInteger *)finalPriceInCents;
        NSLog(@"%zd", priceInCents);
        priceTextField.text = [NSString stringWithFormat:@"%@.%@", dollars, cents];
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
    return conditionOptions.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return conditionOptions[row];
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    conditionTextField.text = conditionOptions[row];
    condition = conditionOptions[row];
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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    name = @"";
    condition = @"";
    priceInCents = 0;
    description = @"";
    
    conditionOptions = [NSArray arrayWithObjects:@"Brand New", @"Exceptional", @"Great Condition", @"Used", @"Falling Apart", @"Broken", nil];
    
    nameTextField.delegate = self;
    conditionTextField.delegate = self;
    descriptionTextView.delegate = self;
    priceTextField.delegate = self;
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
