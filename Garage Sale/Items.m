//
//  Items.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Items.h"
#import "ItemDetail.h"

@interface Items () <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>

@end

@implementation Items 


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCustomCell *tmpCell = [itemsView cellForRowAtIndexPath:indexPath];
    itemToSend = tmpCell.item;
    [self performSegueWithIdentifier:@"showItem" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (1==1) {
        
        
    }
    if ([segue.identifier isEqualToString:@"showItem"]) {
        ItemDetail *destViewController = segue.destinationViewController;
        destViewController.itemOnDisplay = itemToSend;
        [destViewController updateView];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemCustomCell *cell = (ItemCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (!showAll) {
        //loads item from array of liked items if set to not show all
        cell.item = [_likedItems objectAtIndex:indexPath.row];
    }
    else {
        //loads item from array of all items if set to show all
        cell.item = [_items objectAtIndex:indexPath.row];
    }
    cell.parentTable = itemsView;
    
    //updates the views in the cell
    [cell updateCell];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!showAll) {
        return _likedItems.count;
    }
    else {
        return _items.count;
    }
}


-(void)viewSwitched {
    if (showAll) {
        showAll = false;
        [self loadLikedItems];
        [itemsView reloadData];
    }
    else {
        showAll = true;
        [self loadAllItems];
        //loadAllItems already calles reloadData
    }
}








-(void)loadAllItems {
    //creates some test Items
    //test code for itemView
    Item *testItem0 = [[Item alloc] init];
    [testItem0 setName:@"TestName"];
    [testItem0 setLiked:false];
    [testItem0 setItemDescription:@"This is a test item"];
    [testItem0 setThePriceInCents:12345];
    testItem0.image = [UIImage imageNamed:@"TestImage.png"];
    [testItem0 setTheItemID:1];
    [testItem0 setCondition:@"Crappy"];
    testItem0.comments = [[NSArray arrayWithObjects:@"Comment number one", @"Test comment for testing purposes", @"A really long comment meant for testing purposes, hopefully it will work", nil] mutableCopy];
    
    
    Item *testItem1 = [[Item alloc] init];
    [testItem1 setName:@"NameTest1"];
    [testItem1 setLiked:false];
    [testItem1 setItemDescription:@"This is the second test item"];
    [testItem1 setThePriceInCents:54321];
    [testItem1 setImage:[UIImage imageNamed:@"TestImage.png"]];
    [testItem1 setCondition:@"Usable"];
    [testItem1 setTheItemID:2];
    [testItem1 changeLiked];
    
    
    
    Item *testItem2 = [[Item alloc] init];
    [testItem2 setName:@"Test2"];
    [testItem2 setLiked:false];
    [testItem2 setItemDescription:@"This is the second test item"];
    [testItem2 setThePriceInCents:54321];
    [testItem2 setImage:[UIImage imageNamed:@"TestImage1.png"]];
    [testItem2 setCondition:@"Acceptable"];
    [testItem2 setTheItemID:4];
    [testItem2 changeLiked];
    
    
    
    
    _items = [NSMutableArray arrayWithObjects:testItem0, testItem1, testItem2, nil];
    
    //-- Make URL request with server
    NSString *jsonUrlString = [NSString stringWithFormat:@"http://localhost:3001/items/3.json"];
    NSURL *url = [NSURL URLWithString:jsonUrlString];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    NSError *error;
    _result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"Result = %@",_result);
    Item *testItem = [[Item alloc] init];
    testItem.name = [_result objectForKey:@"item_name"];
    testItem.condition = [_result objectForKey:@"item_condition"];
    testItem.itemDescription = [_result objectForKey:@"item_description"];
    testItem.priceInCents = (NSInteger *)[[_result objectForKey:@"item_price_in_cents"] integerValue];
    testItem.itemID = (NSInteger *)[[_result objectForKey:@"id"] integerValue];
    NSLog(@"Price: %zd, ID: %zd", testItem.priceInCents, testItem.itemID);
    
    
    [_items addObject:testItem];
    [itemsView reloadData];
    [session invalidateAndCancel];

}






-(Item *)ItemFromJSON:(NSDictionary *)jsonDictionary {
    Item *tmpItem = [[Item alloc] init];
    
    
    
    return tmpItem;
}

-(void)loadLikedItems {
    //creates and loads the likedItems array
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _likedItems = [defaults arrayForKey:@"LikedItems"];
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _items = [[NSMutableArray alloc] init];
    _likedItems = [[NSArray alloc] init];
    
    [self loadAllItems];
    [self loadLikedItems];
    //show all items not liked items
    showAll = true;
    itemsView.delegate = self;
    itemsView.dataSource = self;
    [itemListType addTarget:self
                         action:@selector(viewSwitched)
               forControlEvents:UIControlEventValueChanged];
    
    
    
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
