//
//  DonatedItemCustomCell.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/10/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "DonatedItemCustomCell.h"


@implementation DonatedItemCustomCell


//updates all of the UI elements of the cell to ma(nonatomic) tch the item data
-(void)updateCell {
    //hides purchased during loading sequence
    NSArray *conditionOptionsCustom = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    _name.text = _item.name;
    int tmpInt = (int)_item.condition;
    _condition.text = conditionOptionsCustom[tmpInt];
    if ([_item.itemPurchaseState intValue] == 1) {
        _purchaseStatus.text = [NSString stringWithFormat:@"Purchased"];
    }
    else {
        _purchaseStatus.text = [NSString stringWithFormat:@"For Sale"];
    }
    //updates like button appearance based on whether or not the object has been liked
    if ([_image isAnimating]) {
        [_image stopAnimating];
    }
    if (_item.image != nil) {
        _image.image = _item.image;
    }
    else {
        _image.image = [UIImage imageNamed:@"default.png"];
        UIImage *image1 = [UIImage imageNamed:@"large1.png"];
        UIImage *image2 = [UIImage imageNamed:@"large2.png"];
        UIImage *image3 = [UIImage imageNamed:@"large3.png"];
        UIImage *image4 = [UIImage imageNamed:@"large4.png"];
        _image.animationImages = @[image1, image2, image3, image4];
        _image.animationDuration = 1;
        _image.animationRepeatCount = 0;
        [_image startAnimating];
        [self loadItemImage:_item];
    }
}

-(void)loadItemImage:(Item *)item {
    //creates an asynchronous queue so that loading the item will not interfer with the main queue (main queue remains open for ui updates)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Item Url:\n%@", item.url);
        item.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.url]]];
        //runs commands in the main queue once the loading is finished
        dispatch_sync(dispatch_get_main_queue(), ^{
            //reloads the tableView now that images have been saved
            if (item.image == nil) {
                item.image = [UIImage imageNamed:@"missing.png"];
            }
            [_parentTable beginUpdates];
            [_parentTable reloadRowsAtIndexPaths:@[_cellPath] withRowAnimation:UITableViewRowAnimationNone];
            [_parentTable endUpdates];
        });
    });
    
}

//updates the liked status of the item then updates the view

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
