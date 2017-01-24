//
//  ItemCustomCell.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/21/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "ItemCustomCell.h"


@implementation ItemCustomCell



-(void)updateCell {
    
    _name.text = _item.name;
    _condition.text = _item.condition;
    _price.text = [_item getPriceString];
    
    if (_item.liked) {
        [_likeButton setImage:[UIImage imageNamed:@"plain_red_hear_shape.png"] forState:UIControlStateNormal];
    }
    else {
        [_likeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Transparent.png"] forState:UIControlStateNormal];
    }
    _image.image = _item.image;
    
}

-(IBAction)likeButtonClicked:(id)sender {
    [_item changeLiked];
    [self updateCell];
    [_parentTable reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
