//
//  Item.h
//  Garage Sale
//
//  Created by Alexander Hammond on 1/19/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Item : NSObject  {
    
}

//defines properties
@property NSString *name;
@property NSInteger *condition;
@property NSString *itemDescription;
@property NSInteger *priceInCents;
@property UIImage *image;
@property NSInteger *itemID;
@property NSMutableArray *comments;
@property bool liked;
@property NSDictionary *localDictionary;
@property NSNumber *itemPurchaseState;
@property NSString *url;
@property bool imageLoadAttempted;



//some simpler get statements (default set statements adequate)
-(NSString *)getName;

-(NSInteger *)getCondition;

-(NSString *)getItemDescription;

-(NSInteger *)getPriceInCents;
-(void)setThePriceInCents:(int)price;
-(NSString *)getPriceString;

-(UIImage *)getImage;

-(NSInteger *)getItemID;
-(void)setTheItemID:(int)ID;

-(bool)getLiked;

-(void)changeLiked;

-(void)changeComment:(NSString *)oldComment toComment:(NSString *)newComment;

-(void)uploadComment:(NSString *)comment;
-(NSString *)commentWithIndex:(int)index;

-(void)setItemDictionary;







@end
