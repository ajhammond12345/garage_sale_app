//
//  UserSettings.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/10/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSettings : UIViewController {
    IBOutlet UITableView *settingsList;
}

//property 1
@property NSString *firstName;
@property NSString *lastName;
//property 2
@property NSString *username;
//property 3
@property NSString *address;
//property 4
@property NSString *email;
//property 5
@property NSString *password;

@property NSMutableArray *cells;

@property UIImage *userPhoto;

@end
