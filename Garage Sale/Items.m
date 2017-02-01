//
//  Items.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Items.h"
#import "ItemDetail.h"
#import "Filters.h"

@interface Items () <UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate>

@end

@implementation Items 


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCustomCell *tmpCell = [itemsView cellForRowAtIndexPath:indexPath];
    _itemToSend = tmpCell.item;
    [self performSegueWithIdentifier:@"showItem" sender:indexPath];
}

-(IBAction)filters:(id)sender {
    [self performSegueWithIdentifier:@"toFilters" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showItem"]) {
        ItemDetail *destViewController = segue.destinationViewController;
        destViewController.itemOnDisplay = _itemToSend;
        [destViewController updateView];
    }
    if ([segue.identifier isEqualToString:@"toFilters"]) {
        Filters *destination = segue.destinationViewController;
        destination.filtersInPlace = _filters;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCustomCell *cell = (ItemCustomCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (!_showAll) {
        //loads item from array of liked items if set to not show all
        cell.item = [_likedItems objectAtIndex:indexPath.row];
    }
    else {
        //loads item from array of all items if set to show all
        if (_showFiltered) {
            cell.item = [_filteredItems objectAtIndex:indexPath.row];
        }
        else {
            cell.item = [_items objectAtIndex:indexPath.row];
        }
    }
    cell.parentTable = itemsView;
    
    //updates the views in the cell
    [cell updateCell];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_showAll) {
        return _likedItems.count;
    }
    else {
        if (_showFiltered) {
            return _filteredItems.count;
        }
        return _items.count;
    }
}


-(void)viewSwitched {
    if (_showAll) {
        _showAll = false;
        [self loadLikedItems];
        [itemsView reloadData];
    }
    else {
        _showAll = true;
        [self loadLikedItems];
        //refreshes the liked list in case a user disliked an item while viewing the liked items list
        NSMutableArray *tmpItemArray = [_items mutableCopy];
        for (int i = 0; i < tmpItemArray.count; i++) {
            //must reevaluate every single item in case it was liked while filtered
            [[tmpItemArray objectAtIndex:i] setLiked:false];
            for (int j = 0; j < _likedItems.count; j++) {
                if ([[tmpItemArray objectAtIndex:i] getItemID] == [[_likedItems objectAtIndex:j] getItemID]) {
                    [[tmpItemArray objectAtIndex:i] setLiked:true];
                }
            }
        }
        _items = tmpItemArray;
        //assign a new memory address to prevent accidental copies
        tmpItemArray = [[NSMutableArray alloc] init];
        tmpItemArray = [_filteredItems mutableCopy];
        for (int i = 0; i < tmpItemArray.count; i++) {
            //must reevaluate every single item in case it was liked while filtered
            [[tmpItemArray objectAtIndex:i] setLiked:false];
            for (int j = 0; j < _likedItems.count; j++) {
                if ([[tmpItemArray objectAtIndex:i] getItemID] == [[_likedItems objectAtIndex:j] getItemID]) {
                    [[tmpItemArray objectAtIndex:i] setLiked:true];
                }
            }
        }
        _filteredItems = tmpItemArray;
        
        //no point in reloading data from the server here
        [itemsView reloadData];
        //[self loadAllItems];
        //loadAllItems already calles reloadData
    }
}








-(void)loadAllItems {
    
    
    
    
    
    //-- Make URL request with server
    if (_items != nil) {
        [itemsView reloadData];
    }
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items.json"];
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
        Item *loadItem = [self itemFromDictionaryExternal:tmpDic];
        [self loadItemImage:loadItem];
        [tmpItemArray addObject:loadItem];
    }
    for (int i = 0; i <tmpItemArray.count; i++) {
        
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
    if (tmpItemArray != nil) {
        _items = tmpItemArray;
    }
    
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection\n" message:@"Could not load items" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
    for (int i = 0; i < _likedItems.count; i++) {
        Item *tmpItem = [_likedItems objectAtIndex:i];
        if ([tmpItem.itemPurchaseState intValue] != 1) {
            [self checkPurchased:[_likedItems objectAtIndex:i]];
        }
    }
}

-(void)checkPurchased:(Item *)item {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // No explicit autorelease pool needed here.
        // The code runs in background, not strangling
        // the main run loop.
       
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", item.itemID]];
        //NSLog(@"%@", url);

        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (![[[data class] description] isEqualToString:@"__NSCFConstantString"]) {
                NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSNumber *tmpNum = [tmpDic objectForKey:@"item_purchase_state"];
                if ([tmpNum intValue] == 1) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSArray *likedArray = [defaults objectForKey:@"LikedItems"];
                    NSMutableArray *tmpLikedItems = [[NSMutableArray alloc] init];
                    NSMutableArray *tmpDicArray = [[NSMutableArray alloc] init];

                    for (int i = 0; i < likedArray.count; i++) {
                        NSDictionary *tmpDic = [likedArray objectAtIndex:i];
                        [tmpLikedItems addObject:[self itemFromDictionaryInternal:tmpDic]];
                        [tmpDicArray addObject:tmpDic];
                    }
                    for (int i = 0; i < tmpLikedItems.count; i++) {
                        Item *tmpItem = [tmpLikedItems objectAtIndex:i];
                        if (tmpItem.itemID == item.itemID) {
                            tmpItem.itemPurchaseState = [NSNumber numberWithInt:1];
                            [tmpItem setItemDictionary];
                            
                            [tmpLikedItems replaceObjectAtIndex:i withObject:tmpItem];
                            
                            [tmpDicArray replaceObjectAtIndex:i withObject:tmpItem.localDictionary];
                        }
                        
                    }
                    [defaults setObject:[tmpDicArray copy] forKey:@"LikedItems"];
                }
                [itemsView reloadData];
            }
        }];
        [dataTask resume];
    });

}

-(void)loadFilteredItems {
    NSMutableArray *tmpItemArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filteredResults.count; i++) {
        NSDictionary *tmpDic = [_filteredResults objectAtIndex:i];
        //NSLog(@"Dictionary %@", tmpDic);
        Item *tmpItem = [self itemFromDictionaryExternal:tmpDic];
        [self loadItemImage:tmpItem];
        [tmpItemArray addObject:tmpItem];
    }
    for (int i = 0; i < tmpItemArray.count; i++) {
        for (int j = 0; j < _likedItems.count; j++) {
            if ([[tmpItemArray objectAtIndex:i] getItemID] == [[_likedItems objectAtIndex:j] getItemID]) {
                [[tmpItemArray objectAtIndex:i] setLiked:true];
            }
        }
    }
    _filteredItems = tmpItemArray;
}

-(void)loadItemImage:(Item *)item {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // No explicit autorelease pool needed here.
        // The code runs in background, not strangling
        // the main run loop.
        NSLog(@"Item Url:\n%@", item.url);
        item.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.url]]];
        item.imageLoadAttempted = true;
        dispatch_sync(dispatch_get_main_queue(), ^{
            // This will be called on the main thread, so that
            // you can update the UI, for example.
            [itemsView reloadData];
        });
    });
    
}

-(Item *)itemFromDictionaryInternal:(NSDictionary *) dictionary {
    Item *tmpItem = [[Item alloc] init];
    tmpItem.name = [dictionary objectForKey:@"item_name"];
    tmpItem.condition = (NSInteger *)[[dictionary objectForKey:@"item_condition"] integerValue];
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
    tmpItem.condition = (NSInteger *)[[dictionary objectForKey:@"item_condition"] integerValue];
    tmpItem.itemDescription = [dictionary objectForKey:@"item_description"];
    NSDictionary *jsonImageFilepath = [dictionary objectForKey:@"item_image"];
    
    NSString *imageFilepath = [jsonImageFilepath objectForKey:@"url"];
    tmpItem.url = [NSString stringWithFormat:@"%@", imageFilepath];
    NSLog(@"%@", tmpItem.url);
    
    
    /*
   
    tmpItem.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]]];
     */
    /*NSString *imageBase64 = [dictionary objectForKey:@"item_image_base_64"];
    NSLog(@"\n\nDownload Data:\n\n%@", imageBase64);
    NSData *imageData = [imageBase64 dataUsingEncoding:NSDataBase64EncodingEndLineWithLineFeed];
    tmpItem.image = [UIImage imageWithData:imageData];
    */
    NSArray *fullComments =  [dictionary objectForKey:@"comments"];
    //NSLog(@"All comments:\n%@", fullComments);
    tmpItem.comments = [[NSMutableArray alloc] init];
    for (int i = 0; i < fullComments.count; i++) {
        NSDictionary *tmpDic = [fullComments objectAtIndex:i];
        //NSLog(@"Dictionary: %@", tmpDic);
        NSString *tmpString = [tmpDic objectForKey:@"comment_text"];
        //NSLog(@"Comment Text: %@", tmpString);
        [tmpItem addComment:tmpString];
        //NSLog(@"Comment Text in comments: %@", tmpItem.comments);
    }
    //NSLog(@"Item Comments: %@", tmpItem.comments);
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
    return tmpItem;
}


/*-(void)setItemImageFromServerWithURL:(NSURL *)imageURL item:(Item *)item {
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
}*/




- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _items = [[NSMutableArray alloc] init];
    _likedItems = [[NSArray alloc] init];
    
    [self loadAllItems];
    [self loadLikedItems];
    [self loadFilteredItems];
    //show all items not liked items
    _showAll = true;
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
