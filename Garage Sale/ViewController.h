//
//  ViewController.h
//  Garage Sale
//
//  Created by Alexander Hammond on 12/14/16.
//  Copyright © 2016 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
}

//defines username property - used to check if user has username and to store one if they don't
@property NSString *username;
@property NSNumber *loggedOn;

-(IBAction)donate:(id)sender;



@end

