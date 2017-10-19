//
//  EditableCell.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/18/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "EditableCell.h"

@implementation EditableCell


-(void)startEditing {
    [fieldText setUserInteractionEnabled:YES];
    [fieldText becomeFirstResponder];
}

-(void)stopEditing {
    [fieldText setUserInteractionEnabled:NO];
    switch (_fieldBeingEditted) {
        case 2:
            NSLog(@"Row 2");
            _superView.username = fieldText.text;
            break;
        case 3:
            NSLog(@"Row 3");
            _superView.email = fieldText.text;
            break;
        case 4:
            NSLog(@"Row 4");
            _superView.address = fieldText.text;
            break;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [fieldText resignFirstResponder];
    return true;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self stopEditing];
}



-(void)updateCell {
    fieldType.text = _type;
    fieldText.text = _text;
    fieldText.delegate = self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //MAY NEED TO CHANGE
    // Configure the view for the selected state
}

@end
