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

@property NSString *name;
@property NSString *condition;
@property NSString *itemDescription;
@property NSInteger *priceInCents;
@property UIImage *image;
@property NSInteger *itemID;
@property NSMutableArray *comments;
@property bool liked;
@property NSDictionary *localDictionary;
@property NSNumber *itemPurchaseState;



//some simpler get statements (default set statements adequate)
-(NSString *)getName;

-(NSString *)getCondition;

-(NSString *)getItemDescription;

-(NSInteger *)getPriceInCents;
-(void)setThePriceInCents:(int)price;
-(NSString *)getPriceString;

-(UIImage *)getImage;

-(NSInteger *)getItemID;
-(void)setTheItemID:(int)ID;

-(bool)getLiked;

-(void)changeLiked;

-(void)addComment:(NSString *)comment;
-(void)changeComment:(NSString *)oldComment toComment:(NSString *)newComment;
-(void)removeComment:(NSString *)comment;

-(Item *)createItemFromJson;
-(void)uploadComment:(NSString *)comment;
-(NSString *)commentWithIndex:(int)index;

-(void)setItemDictionary;







@end
