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
    [self.view endEditing:YES];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    
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
    NSString *worstConditionString = [NSString stringWithFormat:@"%zd", _worstConditionInt];
    NSString *bestConditionString = [NSString stringWithFormat:@"%zd", _bestConditionInt];
    NSString *minPriceString = [NSString stringWithFormat:@"%zd", _minPriceInCents];
    NSString *maxPriceString = [NSString stringWithFormat:@"%zd", _maxPriceInCents];
    _filtersInPlace = [NSDictionary dictionaryWithObjectsAndKeys:worstConditionString, @"worst_condition", bestConditionString, @"best_condition", minPriceString, @"min_price", maxPriceString, @"max_price", nil];
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:dataDic forKey:@"data"];
    NSLog(@"%@", tmpDic);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    
    //send the push request
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/items/filtered_list.json"];
    
    //creates a URL request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //specifics for the request (it is a post request with json content)
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody: jsonData];
    
    //put loading thing here
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _downloadSuccessful = false;
    _requestResult = [[NSArray alloc] init];
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Error: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                NSError *jsonError;
                _requestResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                NSLog(@"requestReply: %@", _requestResult);
                NSLog(@"%@", [[_requestResult class] description]);
                if ([[[_requestResult class] description] isEqualToString:@"__NSArrayM"]) {
                    _downloadSuccessful = true;
                    [self performSegueWithIdentifier:@"loadItemsWithFilters" sender:self];
                }
                else {
                    //server error, do some output
                    [self performSegueWithIdentifier:@"loadItemsWithFilters" sender:self];
                }
            }
            else {
                NSLog(@"NO DATA RECEIVED FROM FILTER REQUEST");
                [self performSegueWithIdentifier:@"loadItemsWithFilters" sender:self];
            }
        });
        
    }] resume];
    
    
    //needs to be run in the code for push completed
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loadItemsWithFilters"]) {
        Items *destinationController = segue.destinationViewController;
        destinationController.filters = _filtersInPlace;
        NSLog(@"Minimum Price Constant: %zd", _minPriceInCents);
        NSLog(@"Currently stored result: %@", _requestResult);
        if (_downloadSuccessful) {
            /*
            NSMutableArray *tmpItemArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < _requestResult.count; i++) {
                NSDictionary *tmpDic = [_requestResult objectAtIndex:i];
            //NSLog(@"Dictionary %@", tmpDic);
            
                [tmpItemArray addObject:[destinationController itemFromDictionaryExternal:tmpDic]];
            }
            NSLog(@"TmpItemArray: %@", tmpItemArray);*/
            //if fails replace with tmpItemArray
            destinationController.filteredResults = _requestResult;
            destinationController.showFiltered = true;
        }
        else {
            //show error saying filters could not load
            destinationController.showFiltered = false;
        }
    }
}


//condition picker view
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _conditionOptionsFilter.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _conditionOptionsFilter[row];
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
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

-(IBAction)dismissKeyBoards:(id)sender {
    [self.view endEditing:YES];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
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



- (void)viewDidLoad {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
