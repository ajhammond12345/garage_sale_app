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
    NSURL *url = [NSURL URLWithString:@"http://localhost:3001/comments.json"];
    
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
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
    }] resume];
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
    //NSLog(@"Price in cents: %zd\nPriceInCents %i", _priceInCents, tmpPriceInCents);
    int tmpCentsOnes = tmpPriceInCents %10;
    int tmpCentsTens = ((tmpPriceInCents - tmpCentsOnes)%100)/10;
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
    NSLog(@"%@", commentsCopy);
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
