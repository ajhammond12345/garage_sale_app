//
//  Items.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Items.h"

@interface Items ()

@end

@implementation Items

-(IBAction)showAllItems {
    //load the list of items from the server
    [self loadAllItems];
}


-(void)showItem {
    
}

-(IBAction)showLikedItems {
    //access likedItems array - saved to device
    
}


-(IBAction)uploadComment {
    
}


-(IBAction)likeItem {
    //adds item to likedItems array
    
    //saves the likedItems array to the device
}


-(void)loadAllItems {
    //contact server with json request
    //accept input stream
    //format input into Items
    //
}


-(void)loadComments {
    
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
