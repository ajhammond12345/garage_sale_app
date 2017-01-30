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
    //hides purchased during loading sequence
    _purchased.hidden = YES;
    NSArray *conditionOptionsCustom = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    _name.text = _item.name;
    int tmpInt = (int)_item.condition;
    _condition.text = conditionOptionsCustom[tmpInt];
    _price.text = [_item getPriceString];
    if ([_item.itemPurchaseState intValue] == 1) {
        _purchased.hidden = NO;
    }
    else {
        _purchased.hidden = YES;
    }
    
    if (_item.liked) {
        [_likeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Solid@3x.png"] forState:UIControlStateNormal];
    }
    else {
        [_likeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Transparent.png"] forState:UIControlStateNormal];
    }
    if ([_image isAnimating]) {
        [_image stopAnimating];
    }
    if (_item.image != nil) {
        _image.image = _item.image;
    }
    else {
        if (_item.imageLoadAttempted == true) {
            _image.image = [UIImage imageNamed:@"missing.png"];
        }
        else {
            UIImage *image1 = [UIImage imageNamed:@"large1.png"];
            UIImage *image2 = [UIImage imageNamed:@"large2.png"];
            UIImage *image3 = [UIImage imageNamed:@"large3.png"];
            UIImage *image4 = [UIImage imageNamed:@"large4.png"];
            _image.animationImages = @[image1, image2, image3, image4];
            _image.animationDuration = 1;
            _image.animationRepeatCount = 0;
            [_image startAnimating];
            _image.image = [UIImage imageNamed:@"default.png"];
        }
    }
    
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
