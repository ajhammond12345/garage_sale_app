//
//  Utility.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+(void)throwAlertWithTitle:(NSString *)title message:(NSString *)message sender:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        
                                    }];
    [alert addAction:defaultAction];
    [sender presentViewController:alert animated:YES completion:nil];
}

@end
