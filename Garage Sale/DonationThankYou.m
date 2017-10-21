//
//  DonationThankYou.m
//  Garage Sale
//
//  Created by Alexander Hammond on 10/21/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "DonationThankYou.h"

@interface DonationThankYou ()

@end

@implementation DonationThankYou

-(IBAction)share:(id)sender {
    NSString *text = [NSString stringWithFormat:@"I just donated this %@ on FUNDonation! Check it out on the app and help the fundraiser.", _donatedItemName];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/fundonation/id1200352853"];
    UIImage *image = _donatedItemImage; //[UIImage imageNamed:@"itunesartwork_2x_720.png"];
    NSArray *itemsToShare = @[text, url, image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
