//
//  PurchaseThankYou.m
//  Garage Sale
//
//  Created by Alexander Hammond on 2/1/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "PurchaseThankYou.h"

@interface PurchaseThankYou ()

@end


@implementation PurchaseThankYou

-(IBAction)share:(id)sender {
    NSString *text = [NSString stringWithFormat:@"I just bought this cool %@ on FUNDonation! Check it out on the app and help the fundraiser.", _itemStorage.name];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/fundonation/id1200352853"];
    UIImage *image = _itemStorage.image; //[UIImage imageNamed:@"itunesartwork_2x_720.png"];
    NSArray *itemsToShare = @[text, url, image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint];
    
    [self presentViewController:controller animated:YES completion:nil];
}

//programatically called segue so that the prepare for segue method will be called
-(IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"returnToItemPage" sender:self];
}

//sends the stored item back to the ItemDetail view to use to update its UI
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemDetail *dest = segue.destinationViewController;
    dest.itemOnDisplay = _itemStorage;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
