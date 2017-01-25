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
    int tmpCentsOnes = tmpPriceInCents %10;
    int tmpCentsTens = (tmpPriceInCents - tmpCentsOnes)%100;
    NSString *priceCents = [NSString stringWithFormat:@"%i%i", tmpCentsTens, tmpCentsOnes];
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
    
    NSMutableArray *likedArrayMutable = [[NSMutableArray alloc] init];
    for (int i = 0; i < likedArray.count; i++) {
        [likedArrayMutable addObject: [likedArray objectAtIndex:i]];
    }
    if (_liked == false) {
        _liked = true;
        [self setItemDictionary];
        [likedArrayMutable addObject:_localDictionary];
    
    }
    else {
        _liked = false;
        for (int i = 0; i < likedArrayMutable.count; i++) {
            NSDictionary *tmpDic = [likedArray objectAtIndex:i];
        
            NSInteger *tmpInteger = (NSInteger*)[[tmpDic valueForKey:@"id"] integerValue];
            
            if (tmpInteger == _itemID) {
                [likedArrayMutable removeObjectAtIndex:i];
            }
        }
    }
    
    NSArray *newLikedArray = [likedArrayMutable copy];
    [defaults setObject:newLikedArray forKey:@"LikedItems"];
    [defaults synchronize];
}

-(void)setItemDictionary {
    NSData *imageData = UIImagePNGRepresentation(_image);
    if (imageData == nil)
        imageData = [imageData init];
    NSNumber *likedData = [NSNumber numberWithBool:_liked];
    NSArray *commentsCopy = [_comments copy];
    if (commentsCopy == nil) {
        commentsCopy = [[NSArray alloc] init];
    }
    if (likedData == nil) {
        likedData = [NSNumber numberWithBool:true];
    }
    _localDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
    _name, @"item_name",
    _condition, @"item_condition",
    _itemDescription, @"item_description",
    [NSString stringWithFormat:@"%zd", _priceInCents], @"item_price_in_cents",
    likedData, @"liked",
    [NSString stringWithFormat:@"%zd", _itemID], @"id",
    imageData, @"item_image",
    commentsCopy, @"item_comments",
    _itemPurchaseState, @"item_purchase_state",
    
                        nil];
         
}



-(void)setItemWithDictionary:(NSDictionary *) dictionary{
    
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
