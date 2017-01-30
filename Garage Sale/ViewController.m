//
//  ViewController.m
//  Garage Sale
//
//  Created by Alexander Hammond on 12/14/16.
//  Copyright © 2016 TripleA. All rights reserved.
//

/*
 Create a mobile application that would allow a platform for a digital yard sale to raise funds to
 attend NLC. The app should allow for the donation of items, including picture, suggested price,
 and a rating for the condition of the item. The app should allow for interaction/comments on
 the items. Code should be error free.
 
 Required Functionality:
 Donation of items
 Items must have:
    Picture
    Suggested Price
    Rating
    Interact/Comments on the items

 UI
    Home Screen
        See the garage sale details
            Name at the top center (label)
            amount raised on left side (label)
            goal on right side (label)
            completion date beneath (label)
        List of items available for purchase (ScrollView?)
        + button to add item (location tbd) (button)
        
    Add Item:
        Starts with adding image screen
            Functionality:
                Pulls up camera in top half of screen - camera library in bottom half
                User clicks picture button (circle) and it saves camera image or selects library image which gets highlighted and they press next
            Appearance:
                //ignore this, this will be learned
                UIImageView in top half
                UIButton (shaped to be a circle) in center and toward bottom of this half
        Next is adding details screen
            Functionality:
                Adds the suggested price, rating, and name of the item, as well as an optional comment
            Appearance:
                UIImageView in top half (will display the selected image)
                TextField for Name below
                TextField for Price below
                Slider for rating
                TextField for comments
                Bottom right should be a "Post button" //this can be moved for appearance's sake, maybe to bottom center
                Confirm Post View should pop up (comprised of a Label and Yes No buttons all on a background imageview that is a transparent grey with a center rounded rectangle outline
 
    Selected Item
        Functionality:
            Displays name, price, rating along the top
            Displays image
            Displays comments below
            Buy button
        Appearance:
            UILabel for Name top center
            UILabel for Price top right
            UILabel for Rating top left
            UIImageView for image (should fill screen width wise - take up 50% of screen)
            UIScrollView for comments
 
    Buy Item
        TBD
 
 
    Classes
        Item
            Fields
                Image (idk)
                Name (String)
                SuggestedPrice (float)
                Rating (int) //out of 10
                Comments (MutableArray //of Strings)
            Functions: 
                saveImage
                setName
                getName
                setPrice
                getPrice
                setRating
                getRating
                addComment
                removeComment
 
        HomeViewController
        AddItemViewController
 

 
 */


/*
 Create a mobile application that would allow a platform for a digital yard sale to raise funds to
 attend NLC. The app should allow for the donation of items, including picture, suggested price,
 and a rating for the condition of the item. The app should allow for interaction/comments on
 the items. Code should be error free.
 
 Required Functionality:
 Donation of items
 Items must have:
    Picture
    Suggested Price
    Rating
    Interact/Comments on the items
 
 UI:
    //All screens except home should have a back button in the top left corner (whether <- or x depends on the screen)
 
    Home Screen
        See local garage sales
        Create garage sale
        Manage sale
        //user either sees create or manage, never both - depends on whether they have an active sale (should be determined both by server and locally)
 
    See yard sales
        //tbd
 
    Details
        Header
            Shows garage sale name at top
            Beneath it shows:
                Funds raised -> if clicked on shows the list of items that have been sold
                goal
                End date
        ScrollView
            Shows list of items available for sale (rating name price) -> if item clicked on it is shown
        Add button
            Lets them add an item (Item entry screen)
 
    List of Items that have been sold
        Displays item rating name price
 
    Display Item
        //pulled up whenever item for sale or item sold is viewed
        Shows rating, name, price at the top
        Shows image in the middle
        //if item sold:
        Says SOLD at the bottom
        //if item not sold
        BUY button at the bottom
 
    Add Item
        Input:
            Name
            Suggested Price
            Rating
 
    Checkout (pulled up when BUY is clicked)
        //TBD
 
 
    Create garage sale
        Input:
            name (String - entered with text field)
            end date (Date thing)
            fundraising goal (float - entered with text field)
        Create (button)
            //sets the start date
 
 
 
 
 Classes:
    GarageSale 
        User sets:
            Name
            End Date (NSDate or String tbd)
            Goal (float)
        Computer controls:
            Start Date (NSDate or String tbd) //set to when it is created
            Funds Raised (float)
            MutableArray of Items (NSMutableArray)
    Items
        Image (File)
        SuggestedPrice (float)
        Condition (int)
        Comments (String)
        Sold/Not Sold (boolean)
 
 */


/* Views that load data from the server (need loading thing)
    ItemDetail (for Buy)
    Filters (when sending filter and waiting on data)
    Comments (when loading comments)
    Items (when downloading items and downloading image for item from URL)
    Item (when uploading comments)
    Donate (when uploading the item)
    About (when loading the amount raised) (also needs error message)
 
 */


///dictionary with key data with object dictionary
    //second dictionary must have condition_min, condition_max, price_min, price_max



#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _username = [defaults objectForKey:@"username"];
    NSLog(@"%@", _username);
    UIAlertController *usernameInput = [UIAlertController alertControllerWithTitle:@"Input Username" message:@"Please create a username." preferredStyle:UIAlertControllerStyleAlert];
    [usernameInput addTextFieldWithConfigurationHandler:^(UITextField *textField) {
     textField.placeholder = NSLocalizedString(@"username", @"Username");
     }];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        _username = usernameInput.textFields.firstObject.text;
        [defaults setObject:_username forKey:@"username"];
        NSLog(@"%@", [defaults objectForKey:@"username"]);
    }];
    [usernameInput addAction:defaultAction];
    if (_username == nil) {
        
        [self presentViewController:usernameInput animated:YES completion:nil];
    }

    NSArray *conditionOptions = [defaults objectForKey:@"conditions"];
    if (conditionOptions == nil) {
    
        [defaults setObject:[NSArray arrayWithObjects:@"--Select--", @"Unopened", @"Brand New", @"Exceptional", @"Great Condition", @"Used", @"Falling Apart", @"Broken", nil] forKey:@"conditions"];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
