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






#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

//run when the view has appeared (so that alerts can pop up)
-(void)viewDidAppear:(BOOL)animated {
    //loads an instance of UserDefaults to check for username
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //loads username
    _username = [defaults objectForKey:@"username"];
    //NSLog(@"%@", _username);
    
    /* old way of doing username
    //creates alert controller for the username
    UIAlertController *usernameInput = [UIAlertController alertControllerWithTitle:@"Input Username" message:@"Please create a username." preferredStyle:UIAlertControllerStyleAlert];
    
    //adds a textfield to the alert controller for username to be typed in
    [usernameInput addTextFieldWithConfigurationHandler:^(UITextField *textField) {
     textField.placeholder = NSLocalizedString(@"username", @"Username");
     }];
    
    //adds an OK button for the user to finalize their username
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        //when ok pressed it saves the input username and writes it to defaults
        _username = usernameInput.textFields.firstObject.text;
        [defaults setObject:_username forKey:@"username"];
        NSLog(@"%@", [defaults objectForKey:@"username"]);
    }];
    
    
    //adds the ok button to the controller
    [usernameInput addAction:defaultAction];
    */
    
    
    //if no username loaded from defaults (first time user has used the app or first time reusing after deleting the app) then it shows the controller to get a username
    if (_username == nil) {
        [self performSegueWithIdentifier:@"toLogin" sender:self];
        
        /*old way of doing username
        //code to show alert controller
        [self presentViewController:usernameInput animated:YES completion:nil];
         */
    }

    //loads the options for conditions
    NSArray *conditionOptions = [defaults objectForKey:@"conditions"];
    
    //if no options set, writes the options below (first time app is loaded)
    if (conditionOptions == nil) {
    
        //options available for item condition
        [defaults setObject:[NSArray arrayWithObjects:@"--Select--", @"Unopened", @"Brand New", @"Exceptional", @"Great Condition", @"Used", @"Falling Apart", @"Broken", nil] forKey:@"conditions"];
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
