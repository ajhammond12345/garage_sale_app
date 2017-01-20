//
//  Donate.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Donate.h"

@interface Donate () <UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation Donate

-(IBAction)done:(id)sender {
    
}

// Control methods for each text/image view

//makes keyboard disappear after finished editing
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

//makes keyboard disappear after finished editing
-(BOOL) textViewShouldReturn:(UITextView *)textView{
    
    [textView resignFirstResponder];
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
        int finalPriceInCents;
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
        NSLog(@"%@%i", dollars, priceDollars);
        finalPriceInCents = (priceDollars * 100) + priceCents;
        priceInCents = finalPriceInCents;
        priceTextField.text = [NSString stringWithFormat:@"%@.%@", dollars, cents];
    }
    [textField resignFirstResponder];
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
    image = nil;
    conditionOptions = [NSArray arrayWithObjects:@"Option 1", @"Option 2", @"Option 3", @"Option 4", nil];
    
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
