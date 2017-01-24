//
//  About.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface About : UIViewController {
    IBOutlet UILabel *amountRaisedText;
    IBOutlet UIImageView *progressBar;
    IBOutlet UIImageView *totalBar;
    IBOutlet UILabel *daysUntilNLC;
    IBOutlet UILabel *percentRaised;
    IBOutlet NSLayoutConstraint *progressBarWidth;
    
    
}

@property int amountRaisedInCents;
@property int goalInCents;
@property int daysRemaining;

@end
