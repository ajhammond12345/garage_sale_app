//
//  Filters.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/27/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Filters.h"
#import "Items.h"

@interface Filters () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@end

@implementation Filters

-(IBAction)sendFilters:(id)sender {
    //closes all keyboards
    [self.view endEditing:YES];
    
    //creates an empty dictionary for data to be added
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
    //goes through every field, if it is not empty it adds it to the dictionary (empty fields are handled by the database with default values)
    if (_worstConditionInt != nil) {
        NSString *condition_max = [NSString stringWithFormat:@"%zd", _worstConditionInt];
        [dataDic setObject:condition_max forKey:@"condition_max"];
    }
    if (_bestConditionInt != nil) {
        NSString *condition_min = [NSString stringWithFormat:@"%zd", _bestConditionInt];
        [dataDic setObject:condition_min forKey:@"condition_min"];
    }
    if (_minPriceInCents != nil) {
        NSString *price_min = [NSString stringWithFormat:@"%zd", _minPriceInCents];
        [dataDic setObject:price_min forKey:@"price_min"];
    }
    if (_maxPriceInCents != nil) {
        NSString *price_max = [NSString stringWithFormat:@"%zd", _maxPriceInCents];
        [dataDic setObject:price_max forKey:@"price_max"];
    }
    //creates a string from all of the fields to be put into an array that will go to the main items view controller to store the currently loaded filters
    NSString *worstConditionString = [NSString stringWithFormat:@"%zd", _worstConditionInt];
    NSString *bestConditionString = [NSString stringWithFormat:@"%zd", _bestConditionInt];
    NSString *minPriceString = [NSString stringWithFormat:@"%zd", _minPriceInCents];
    NSString *maxPriceString = [NSString stringWithFormat:@"%zd", _maxPriceInCents];
    //stores the current filters to be sent to items page and saved for when filters page reloads
    _filtersInPlace = [NSDictionary dictionaryWithObjectsAndKeys:worstConditionString, @"worst_condition", bestConditionString, @"best_condition", minPriceString, @"min_price", maxPriceString, @"max_price", nil];
    //creates a dictionary for sending the request - puts it under the data heading to match what the database expects
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:dataDic forKey:@"data"];
    //NSLog(@"%@", tmpDic);
    
    //error handler
    NSError *error;
    
    //creates the json data for the url request
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    
    //creates url for request
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/items/filtered_list.json"];
    
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
    _downloadSuccessful = false;
    //creates empty array to store the response from the server
    _requestResult = [[NSArray alloc] init];
    
    //initiates the url session with a handler that processes the data returned from the server
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
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
                    _downloadSuccessful = true;
                    [self performSegueWithIdentifier:@"loadItemsWithFilters" sender:self];
                }
                else {
                    //server error, do some output
                    [self performSegueWithIdentifier:@"loadItemsWithFilters" sender:self];
                }
            }
            //logs if data is nil and the phone did not connect to a server
            else {
                NSLog(@"NO DATA RECEIVED FROM FILTER REQUEST");
                [self performSegueWithIdentifier:@"loadItemsWithFilters" sender:self];
            }
        });
        
    }] resume];
}

//hanldes segue back to main view controller based on whether or not the filtered items were successfully downloaded
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loadItemsWithFilters"]) {
        //loads destination view controller
        Items *destinationController = segue.destinationViewController;
        //stores the filters in place to save the user's filter options for the next time they return to this page
        destinationController.filters = _filtersInPlace;
        //if download successful it tells the Items page to show the filtered content
        if (_downloadSuccessful) {
            
            destinationController.filteredResults = _requestResult;
            destinationController.showFiltered = true;
        }
        else {
            //show error saying filters could not load
            destinationController.showFiltered = false;
        }
    }
}


//condition picker view - sets the number of columns
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//sets the number of rows for the picker condition to the number of items in the conditions array
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _conditionOptionsFilter.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _conditionOptionsFilter[row];
}


//runs when a row selected (note: this occurs when user stops scrolling, not necessarily their final choice)
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //if row is not 0 (--Select--) logs their condition
    if (row != 0) {
        if (self.conditionFieldBeingEdited == 1) {
            worstCondition.text = _conditionOptionsFilter[row];
            long rowTmp = row;
            _worstConditionInt = (NSInteger *)rowTmp;
        }
        else {
            bestCondition.text = _conditionOptionsFilter[row];
            long rowTmp = row;
            _bestConditionInt = (NSInteger *)rowTmp;
        }
    }
    //if --Select-- chosen - logs their condition as being empty
    else {
        if (_conditionFieldBeingEdited == 1) {
            worstCondition.text = @"";
            worstCondition.placeholder = @"Worst Condition";
            _worstConditionInt = nil;
        }
        if (_conditionFieldBeingEdited == 2) {
            bestCondition.text = @"";
            bestCondition.placeholder = @"Best Condition";
            _bestConditionInt = nil;
        }
    }
    
}

//outlet to dismiss keyboards - goes to background button on the UI
-(IBAction)dismissKeyBoards:(id)sender {
    [self.view endEditing:YES];
}


//run if the text field is about to begin editing
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //for condition pickers it changes their input view to the scroller instead of the keyboard
    if ([textField isEqual:worstCondition]) {
        
        worstCondition.inputView = _conditionPicker;
        textField.inputView = _conditionPicker;
        _conditionFieldBeingEdited = 1;
    }
    if ([textField isEqual:bestCondition]) {
        bestCondition.inputView = _conditionPicker;
        textField.inputView = _conditionPicker;
        _conditionFieldBeingEdited = 2;
    }
    //adds the toolbar to provide a done button for users
    textField.inputAccessoryView = _toolBar;
    return YES;
    
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual: minimumPrice]) {
        NSString *cents;
        NSString *dollars;
        int priceCents;
        int priceDollars;
        long finalPriceInCents;
        for (int i = 0; i < minimumPrice.text.length; i++) {
            if ([[[minimumPrice.text substringFromIndex:i] substringToIndex:1] isEqualToString:@"."]) {
                cents = [minimumPrice.text substringFromIndex:i];
                dollars = [minimumPrice.text substringToIndex:i];
                break;
            }
        }
        if (dollars == nil) {
            dollars = minimumPrice.text;
            if ([dollars isEqualToString:@""]) {
                dollars = @"0";
            }
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
        _minPriceInCents = (NSInteger *)finalPriceInCents;
        NSLog(@"%zd", _minPriceInCents);
        minimumPrice.text = [NSString stringWithFormat:@"$%@.%@", dollars, cents];
        if ([minimumPrice.text isEqualToString:@"$0.00"]) {
            minimumPrice.text = @"";
            _minPriceInCents = nil;
            minimumPrice.placeholder = @"$0.00";
        }
    }
    if ([textField isEqual: maximumPrice]) {
        NSString *cents;
        NSString *dollars;
        int priceCents;
        int priceDollars;
        long finalPriceInCents;
        for (int i = 0; i < maximumPrice.text.length; i++) {
            if ([[[maximumPrice.text substringFromIndex:i] substringToIndex:1] isEqualToString:@"."]) {
                cents = [maximumPrice.text substringFromIndex:i];
                dollars = [maximumPrice.text substringToIndex:i];
                break;
            }
        }
        if (dollars == nil) {
            dollars = maximumPrice.text;
            if ([dollars isEqualToString:@""]) {
                dollars = @"0";
            }
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
        _maxPriceInCents = (NSInteger *)finalPriceInCents;
        NSLog(@"%zd", _maxPriceInCents);
        maximumPrice.text = [NSString stringWithFormat:@"$%@.%@", dollars, cents];
        if ([maximumPrice.text isEqualToString:@"$0.00"]) {
            maximumPrice.text = @"";
            _maxPriceInCents = nil;
            maximumPrice.placeholder = @"$0.00";
        }
    }
    [textField resignFirstResponder];
    [self.view endEditing:YES];
}

-(void)clearPickerView {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    _toolBar = [[UIToolbar alloc] init];
    _toolBar.barStyle = UIBarStyleDefault;
    _toolBar.translucent = true;
    [_toolBar sizeToFit];
    
    UIBarButtonItem *finished = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(clearPickerView)];
    
    [_toolBar setItems:@[finished] animated: false];
    _toolBar.userInteractionEnabled = true;
    _conditionOptionsFilter = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    _conditionPicker = [[UIPickerView alloc] init];
    _conditionPicker.dataSource = self;
    _conditionPicker.delegate = self;
    _conditionPicker.showsSelectionIndicator = YES;
    worstCondition.delegate = self;
    bestCondition.delegate = self;
    maximumPrice.delegate = self;
    minimumPrice.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //sets up the filters in case there were previous filters
    if (_filtersInPlace != nil) {
        _worstConditionInt = (NSInteger *)[[_filtersInPlace objectForKey:@"worst_condition"] integerValue];
        _bestConditionInt = (NSInteger *)[[_filtersInPlace objectForKey:@"best_condition"] integerValue];
        _minPriceInCents = (NSInteger *)[[_filtersInPlace objectForKey:@"min_price"] integerValue];
        _maxPriceInCents = (NSInteger *)[[_filtersInPlace objectForKey:@"max_price"] integerValue];
        if (_worstConditionInt != nil) {
            worstCondition.text = _conditionOptionsFilter[(int)_worstConditionInt];
        }
        if (_bestConditionInt != nil) {
            bestCondition.text = _conditionOptionsFilter[(int)_bestConditionInt];
        }
        if (_maxPriceInCents != nil) {
            maximumPrice.text = [self getPriceString:_maxPriceInCents];
        }
        if (_minPriceInCents != nil) {
            minimumPrice.text = [self getPriceString:_minPriceInCents];
        }
    }
}


-(NSString *)getPriceString:(NSInteger *)priceInCents {
    int tmpPriceInCents = (int)priceInCents;
    //NSLog(@"Price in cents: %zd\nPriceInCents %i", _priceInCents, tmpPriceInCents);
    int tmpCentsOnes = tmpPriceInCents %10;
    int tmpCentsTens = ((tmpPriceInCents - tmpCentsOnes)%100)/10;
    NSString *priceCents = [NSString stringWithFormat:@"%i%i", tmpCentsTens, tmpCentsOnes];
    NSString *priceDollars = [NSString stringWithFormat:@"%i", (tmpPriceInCents/100)];
    
    NSString *priceString =[NSString stringWithFormat:@"$%@.%@", priceDollars, priceCents];
    return priceString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
