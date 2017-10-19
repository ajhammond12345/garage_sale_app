//
//  Utility.h
//  Garage Sale
//
//  Created by Alexander Hammond on 10/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject

+(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;

+(UIImage *)loadImageWithFileName:(NSString *)fileName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;

+(void)throwAlertWithTitle:(NSString *)title message:(NSString *)message sender:(id)sender;


@end
