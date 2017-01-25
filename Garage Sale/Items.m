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
    /*Item *testItem0 = [[Item alloc] init];
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
    
    
    
    Item *testItem2 = [[Item alloc] init];
    [testItem2 setName:@"Test2"];
    [testItem2 setLiked:false];
    [testItem2 setItemDescription:@"This is the second test item"];
    [testItem2 setThePriceInCents:54321];
    [testItem2 setImage:[UIImage imageNamed:@"TestImage1.png"]];
    [testItem2 setCondition:@"Acceptable"];
    [testItem2 setTheItemID:4];
    
    
    
    
    _items = [NSMutableArray arrayWithObjects:testItem0, testItem1, testItem2, nil];
    */
    //-- Make URL request with server
    NSString *jsonUrlString = [NSString stringWithFormat:@"http://localhost:3001/items.json"];
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
    //NSLog(@"Result (Length: %zd) = %@",_result.count, _result);
    NSMutableArray *tmpItemArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _result.count; i++) {
        NSDictionary *tmpDic = [_result objectAtIndex:i];
        //NSLog(@"Dictionary %@", tmpDic);
        
        [tmpItemArray addObject:[self itemFromDictionaryExternal:tmpDic]];
    }
    
    [self loadLikedItems];
     
    //sets the 'liked' value of the loaded items
    for (int i = 0; i < tmpItemArray.count; i++) {
        for (int j = 0; j < _likedItems.count; j++) {
            if ([[tmpItemArray objectAtIndex:i] getItemID] == [[_likedItems objectAtIndex:j] getItemID]) {
                [[tmpItemArray objectAtIndex:i] setLiked:true];
            }
        }
    }
    
    _items = tmpItemArray;
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
    NSArray *likedArray = [defaults objectForKey:@"LikedItems"];
    NSMutableArray *tmpLikedItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < likedArray.count; i++) {
        NSDictionary *tmpDic = [likedArray objectAtIndex:i];
        [tmpLikedItems addObject:[self itemFromDictionaryInternal:tmpDic]];
    }
    _likedItems = [tmpLikedItems copy];
}

-(Item *)itemFromDictionaryInternal:(NSDictionary *) dictionary {
    Item *tmpItem = [[Item alloc] init];
    tmpItem.name = [dictionary objectForKey:@"item_name"];
    tmpItem.condition = [dictionary objectForKey:@"item_condition"];
    tmpItem.itemDescription = [dictionary objectForKey:@"item_description"];
    NSData *imageData = [dictionary objectForKey:@"item_image"];
    if (imageData != nil) {
        tmpItem.image = [UIImage imageWithData:imageData];
    }
    tmpItem.priceInCents = (NSInteger*)[[dictionary objectForKey:@"item_price_in_cents"] integerValue];
    //NSLog(@"%@", [dictionary objectForKey:@"item_description"]);
    tmpItem.liked = [[dictionary objectForKey:@"liked"] boolValue];
    NSInteger *tmpID = (NSInteger*)[[dictionary objectForKey:@"id"] integerValue];
    //NSLog(@"%@", [dictionary objectForKey:@"id"]);
    //NSLog(@"%zd", tmpID);
    tmpItem.itemID = tmpID;
    tmpItem.itemPurchaseState = (NSNumber *)[dictionary objectForKey:@"item_purchase_state"];
    NSArray *tmpComments = [dictionary objectForKey:@"item_comments"];
    [tmpItem.comments removeAllObjects];
    for (int i = 0; i < tmpComments.count; i++) {
        [tmpItem.comments addObject:[tmpComments objectAtIndex:i]];
    }
    return tmpItem;
}

//differnt method for handling different image data transfer
-(Item *)itemFromDictionaryExternal:(NSDictionary *) dictionary {
    Item *tmpItem = [[Item alloc] init];
    tmpItem.name = [dictionary objectForKey:@"item_name"];
    tmpItem.condition = [dictionary objectForKey:@"item_condition"];
    tmpItem.itemDescription = [dictionary objectForKey:@"item_description"];
    NSDictionary *jsonImageFilepath = [dictionary objectForKey:@"item_image"];
    
    NSString *imageFilepath = [jsonImageFilepath objectForKey:@"url"];
    NSString *imageURLString = [NSString stringWithFormat:@"http://localhost:3001%@", imageFilepath];
    //NSURL *imageURL = [NSURL fileURLWithPath:imageURLString];
    _tmpImage = [[UIImage alloc] init];
    //NSLog(@"\"%@\"", imageURLString);
    
    /*
    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
        downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            
            UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            NSLog(@"%@",[NSData dataWithContentsOfURL:location]);
            _tmpImage = downloadedImage;
            tmpItem.image = _tmpImage;
    }];
     */
    tmpItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
    //[downloadPhotoTask resume];
     
     
    
    //[self setItemImageFromServerWithURL:imageURL item:tmpItem];
    tmpItem.priceInCents = (NSInteger*)[[dictionary objectForKey:@"item_price_in_cents"] integerValue];
    
    tmpItem.liked = [[dictionary objectForKey:@"liked"] boolValue];
    NSInteger *tmpID = (NSInteger*)[[dictionary objectForKey:@"id"] integerValue];
    //NSLog(@"%@", [dictionary objectForKey:@"id"]);
    //NSLog(@"%zd", tmpID);
    tmpItem.itemID = tmpID;
    //NSLog(@"%zd", tmpItem.itemID);
    tmpItem.itemPurchaseState = (NSNumber *)[dictionary objectForKey:@"item_purchase_state"];
    NSArray *tmpComments = [dictionary objectForKey:@"item_comments"];
    [tmpItem.comments removeAllObjects];
    for (int i = 0; i < tmpComments.count; i++) {
        [tmpItem.comments addObject:[tmpComments objectAtIndex:i]];
    }
    return tmpItem;
}


-(void)setItemImageFromServerWithURL:(NSURL *)imageURL item:(Item *)item {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:imageURL options:NSDataReadingUncached error:&error];
       // NSLog(@"Image data: %@", data);
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            item.image = image;
        });  
    });
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
