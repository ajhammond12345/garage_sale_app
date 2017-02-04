//
//  Filters.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/27/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Filters : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> {
    //declares all of the UI elements
    IBOutlet UITextField *bestCondition;
    IBOutlet UITextField *worstCondition;
    IBOutlet UITextField *minimumPrice;
    IBOutlet UITextField *maximumPrice;
}

//declares all of the properties within the view
@property (strong, nonatomic) UIPickerView *conditionPicker;
@property UIToolbar *toolBar;
@property NSArray *requestResult;
//1 for worst, 2 for best (this is a property so it can be accessed in delegate methods)
@property int conditionFieldBeingEdited;

//all of these fields are properties so that there will be no linker error when communicating with other view controllers (this is true for most fields in all view controllers that communicate with other view controllers)
@property NSDictionary *filtersInPlace;
@property NSArray *filteredItemsList;
@property NSArray *conditionOptionsFilter;
@property bool downloadSuccessful;
//Note: this holds the highest integer value allowed (since the higher the int in this case the worse the condition) = condition_max
@property NSInteger *worstConditionInt;
//Note: this holds the lowest integer value allowed (since the lower the int in this case the better the condition) = condition_min
@property NSInteger *bestConditionInt;

@property NSInteger *minPriceInCents;
@property NSInteger *maxPriceInCents;


-(IBAction)sendFilters:(id)sender;

@end
