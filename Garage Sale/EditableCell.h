//
//  EditableCell.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/18/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSettings.h"

@interface EditableCell : UITableViewCell <UITextFieldDelegate> {
    IBOutlet UILabel *fieldType;
    IBOutlet UITextField *fieldText;
}

-(void)updateCell;
-(void)startEditing;
-(void)stopEditing;

@property NSString *type;
@property NSString *text;
@property UserSettings *superView;
@property int fieldBeingEditted;

@end
