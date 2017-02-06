//
//  Item.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/19/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Item.h"

@implementation Item


-(void)uploadComment:(NSString *)comment {
    [_comments addObject:comment];
    NSError *error;
    
    //creates mutable copy of the dictionary to remove extra keys
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:comment forKey:@"comment_text"];
    [tmpDic setObject:[NSString stringWithFormat:@"%zd", _itemID] forKey:@"item_id"];
    
    //converts the dictionary to json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    //logs the data to check if it is created successfully
    //NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    //creates url for the request
    NSURL *url = [NSURL URLWithString:@"https://murmuring-everglades-79720.herokuapp.com/comments.json"];
    
    //creates a URL request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //specifics for the request (it is a post request with json content)
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody: jsonData];
    
    //
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        });
    }] resume];
    //add the comment to the server
}

//quick helper method to return specific comments
-(NSString *)commentWithIndex:(int)index {
    return [_comments objectAtIndex:index];
}

//some short getter methods
-(NSString *)getName {
    return _name;
}


-(NSInteger *)getCondition {
    return _condition;
}


-(NSString *)getItemDescription {
    return _itemDescription;
}


-(NSInteger *)getPriceInCents {
    return _priceInCents;
}

-(UIImage *)getImage {
    return _image;
}

-(NSInteger *)getItemID {
    return _itemID;
}

-(bool)getLiked {
    return _liked;
}


//this method converts the item's price into a formatted string to display
-(NSString *)getPriceString {
    int tmpPriceInCents = (int)_priceInCents;
    //NSLog(@"Price in cents: %zd\nPriceInCents %i", _priceInCents, tmpPriceInCents);
    int tmpCentsOnes = tmpPriceInCents %10;
    int tmpCentsTens = ((tmpPriceInCents - tmpCentsOnes)%100)/10;
    NSString *priceCents = [NSString stringWithFormat:@"%i%i", tmpCentsTens, tmpCentsOnes];
    NSString *priceDollars = [NSString stringWithFormat:@"%i", (tmpPriceInCents/100)];
    
    NSString *priceString =[NSString stringWithFormat:@"$%@.%@", priceDollars, priceCents];
    return priceString;
}

//helper to set the price for item with int instead of NSInteger
-(void)setThePriceInCents:(int)price {
    long tmpPrice = price;
    _priceInCents = (NSInteger *)tmpPrice;
}

//sets the id for the item with an int
-(void)setTheItemID:(int)ID {
    long tmpID = ID;
    _itemID = (NSInteger *)tmpID;
}

//changes the liked status of the item
-(void)changeLiked {
    //loads array of liked items
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *likedArray = [defaults objectForKey:@"LikedItems"];
    
    //creates a copy to edit (all objects loaded from defaults are immutable so mutableCopy command does not work)
    NSMutableArray *likedArrayMutable = [[NSMutableArray alloc] init];
    //copies all of the items from the liked array into the mutable array
    for (int i = 0; i < likedArray.count; i++) {
        [likedArrayMutable addObject: [likedArray objectAtIndex:i]];
    }
    
    //if the item was not liked, sets liked to true and adds the item to the array
    if (_liked == false) {
        _liked = true;
        [self setItemDictionary];
        [likedArrayMutable addObject:_localDictionary];
    
    }
    //if the item was liked, sets to false and removes it from the array
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
    //creates a non-mutable copy of the updated array (cannot save mutable arrays to user defaults)
    NSArray *newLikedArray = [likedArrayMutable copy];
    //saves the updated array
    [defaults setObject:newLikedArray forKey:@"LikedItems"];
    [defaults synchronize];
}

//updates the internal dictionary of the item (helps when editing items from other classes)
-(void)setItemDictionary {
    NSData *imageData = UIImageJPEGRepresentation(_image, .6);
    NSNumber *likedData = [NSNumber numberWithBool:_liked];
    NSArray *commentsCopy = [_comments copy];
    NSNumber *purchaseState = _itemPurchaseState;
    //NSLog(@"Purchase State: %@", purchaseState);
    if (imageData == nil)
        imageData = [[NSData alloc] init];
    if (commentsCopy == nil) {
        commentsCopy = [[NSArray alloc] init];
    }
    if (likedData == nil) {
        likedData = [NSNumber numberWithBool:true];
    }
    if (purchaseState == nil) {
        purchaseState = [[NSNumber alloc] initWithInt:-1];
    }
    //NSLog(@"These Can't Be NULL: %@, %@, %@", imageData, commentsCopy, likedData);
    _localDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
    _name, @"item_name",
    [NSString stringWithFormat:@"%zd", _condition], @"item_condition",
    _itemDescription, @"item_description",
    [NSString stringWithFormat:@"%zd", _priceInCents], @"item_price_in_cents",
    likedData, @"liked",
    [NSString stringWithFormat:@"%zd", _itemID], @"id",
    imageData, @"item_image",
    commentsCopy, @"item_comments",
    purchaseState, @"item_purchase_state",
    
                        nil];
}


//included in case need, should not be needed
-(void)changeComment:(NSString *)oldComment toComment:(NSString *)newComment {
    for (int i = 0; i < _comments.count; i++) {
        if ([[_comments objectAtIndex:i] isEqualToString:oldComment]) {
            [_comments replaceObjectAtIndex:i withObject:newComment];
        }
    }
}



@end
