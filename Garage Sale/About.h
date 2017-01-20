//
//  About.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>

int amountRaisedInCents;
int goalInCents;
int daysRemaining;


@interface About : UIViewController {
    IBOutlet UILabel *amountRaisedText;
    IBOutlet UIImageView *progressBar;
    IBOutlet UIImageView *totalBar;
    IBOutlet UILabel *daysUntilNLC;
    IBOutlet UILabel *percentRaise;
    
}

@end
