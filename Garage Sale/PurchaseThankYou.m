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

//TODO share button

@implementation PurchaseThankYou

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
