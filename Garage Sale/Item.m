//
//  Item.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/19/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Item.h"

@implementation Item

-(Item *)createItemFromJson {
    Item *tmpItem = [[Item alloc] init];
    return tmpItem;
}

-(void)downloadComments {
    //sets whatever it gets from server (with its ID) to comments array
    if (_comments == nil) {
        _comments = [NSMutableArray arrayWithObjects:@"This is a test comment for the item", nil];
    }
}

-(void)uploadComment:(NSString *)comment {
    [_comments addObject:comment];
    //add the comment to the server
}

-(NSString *)commentWithIndex:(int)index {
    return [_comments objectAtIndex:index];
}

-(NSString *)getName {
    return _name;
}


-(NSString *)getCondition {
    return _condition;
}


-(NSString *)getItemDescription {
    return _itemDescription;
}


-(NSInteger *)getPriceInCents {
    return _priceInCents;
}
-(NSString *)getPriceString {
    int tmpPriceInCents = (int)_priceInCents;
    NSString *priceCents = [NSString stringWithFormat:@"%i", (tmpPriceInCents%100)];
    NSString *priceDollars = [NSString stringWithFormat:@"%i", (tmpPriceInCents/100)];
    
    NSString *priceString =[NSString stringWithFormat:@"$%@.%@", priceDollars, priceCents];
    return priceString;
}

-(void)setThePriceInCents:(int)price {
    long tmpPrice = price;
    _priceInCents = (NSInteger *)tmpPrice;
}


-(UIImage *)getImage {
    return _image;
}

-(NSInteger *)getItemID {
    return _itemID;
}
-(void)setTheItemID:(int)ID {
    long tmpID = ID;
    _itemID = (NSInteger *)tmpID;
}

-(void)changeLiked {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *likedArray = [defaults objectForKey:@"LikedItems"];
    if (likedArray == nil) {
        _liked = true;
        likedArray = [likedArray initWithObjects:self, nil];
    }
    else {
        NSMutableArray *likedArrayMutable = [likedArray mutableCopy];
        if (_liked == false) {
            _liked = true;
            [likedArrayMutable addObject:self];
        
        }
        else {
            _liked = false;
            for (int i = 0; i < likedArray.count; i++) {
                if ([[likedArray objectAtIndex:i] getItemID] == self.itemID) {
                [likedArrayMutable removeObjectAtIndex:i];
                }
            }
        }
        likedArray = [likedArrayMutable copy];
    }
    [defaults setObject:likedArray forKey:@"LikedItems"];
    [defaults synchronize];
}

-(bool)getLiked {
    return _liked;
}

-(void)addComment:(NSString *)comment {
    [_comments addObject:comment];
}

//included in case need, should not be needed
-(void)changeComment:(NSString *)oldComment toComment:(NSString *)newComment {
    for (int i = 0; i < _comments.count; i++) {
        if ([[_comments objectAtIndex:i] isEqualToString:oldComment]) {
            [_comments replaceObjectAtIndex:i withObject:newComment];
        }
    }
}
-(void)removeComment:(NSString *)comment {
    for (int i = 0; i < _comments.count; i++) {
        if ([[_comments objectAtIndex:i] isEqualToString:comment]) {
            [_comments removeObjectAtIndex:i];
        }
    }
}

@end
