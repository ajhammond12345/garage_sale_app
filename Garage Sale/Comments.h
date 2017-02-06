//
//  Comments.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/23/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

//imports
#import <UIKit/UIKit.h>
#import "Item.h"
#import "ItemDetail.h"

//declarig interface outlets
@interface Comments : UIViewController <UITextViewDelegate, NSURLSessionDelegate> {
    IBOutlet UITextView *otherComments;
    IBOutlet UITextView *inputComment;
    IBOutlet UIImageView *showImage;
    IBOutlet UIImageView *purchased;
}

//class properties
@property Item *item;
@property NSString *userComment;

-(IBAction)postComment:(id)sender;
-(IBAction)back:(id)sender;

@end
