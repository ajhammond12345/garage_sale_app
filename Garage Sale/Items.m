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

//when an item clicked in the table view it passes on the item info and shows the item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCustomCell *tmpCell = [itemsView cellForRowAtIndexPath:indexPath];
    _itemToSend = tmpCell.item;
    [self performSegueWithIdentifier:@"showItem" sender:indexPath];
}

//goes to the filters page
-(IBAction)filters:(id)sender {
    [self performSegueWithIdentifier:@"toFilters" sender:self];
}

//passes on information based on which segue is performed
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showItem"]) {
        ItemDetail *destViewController = segue.destinationViewController;
        destViewController.itemOnDisplay = _itemToSend;
        destViewController.items = _items;
        [destViewController updateView];
    }
    if ([segue.identifier isEqualToString:@"toFilters"]) {
        Filters *destination = segue.destinationViewController;
        destination.filtersInPlace = _filters;
    }
}

//delegate method used to load table view
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
    cell.cellPath = indexPath;
    
    //updates the views in the cell
    [cell updateCell];
    
    return cell;
}

//provides the number of rows that will be in table view (just a count of the array)
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self loadLikedItems];
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

//run when the segmented control switched - switches between liked and all (and when all decides between filtered and all)
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







//loads all of the items
-(void)loadAllItems {
    
    //-- Make URL request with server to load all of the items
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


//loads all of the items when the data task is complete
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    NSError *error;
    _result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"Result (Length: %zd) = %@",_result.count, _result);
    //this interprets the data received a creates a bunch of items from it
    NSMutableArray *tmpItemArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _result.count; i++) {
        NSDictionary *tmpDic = [_result objectAtIndex:i];
        //NSLog(@"Dictionary %@", tmpDic);
        Item *loadItem = [self itemFromDictionaryExternal:tmpDic];
        //[self loadItemImage:loadItem];
        [tmpItemArray addObject:loadItem];
    }
    /*for (int i = 0; i <tmpItemArray.count; i++) {
        
    }*/
    
    //updates the liked items list to load which of the new items the user has liked
    [self loadLikedItems];
     
    //sets the 'liked' value of the loaded items
    for (int i = 0; i < tmpItemArray.count; i++) {
        for (int j = 0; j < _likedItems.count; j++) {
            if ([[tmpItemArray objectAtIndex:i] getItemID] == [[_likedItems objectAtIndex:j] getItemID]) {
                [[tmpItemArray objectAtIndex:i] setLiked:true];
            }
        }
    }
    //if data receieved it saves the interpreted data to the local array
    if (tmpItemArray != nil) {
        _items = tmpItemArray;
    }
    
    else {
        //if no data received it provides this alert
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection\n" message:@"Could not load items" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [itemsView reloadData];
    [session invalidateAndCancel];

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

//checks to see if item has been purchased - this runs in the background separately from downloading all of the data - used for updating whether or not to show the purchased image on items loaded locally (liked items)
-(void)checkPurchased:(Item *)item {
    //creates bacground queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       //initiates a urlsession to check the purchase stat
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", item.itemID]];
        //NSLog(@"%@", url);

        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (![[[data class] description] isEqualToString:@"__NSCFConstantString"]) {
                
                //interprets the received data to check the purchase state
                NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                NSNumber *tmpNum = [tmpDic objectForKey:@"item_purchase_state"];
                //if purchased it updates the saved object for the key LikedItems (where the liked list is stored) to update the purchase state of the item
                if ([tmpNum intValue] == 1) {
                    //creates instance of defaults to access locally saved objects
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
            }
        }];
        [dataTask resume];
    });

}

//reloads all of the items (for the reload button specifically)
-(IBAction)reload:(id)sender {
    [self loadLikedItems];
    [self loadAllItems];
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

-(void)loadFilteredItems {
    NSMutableArray *tmpItemArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _filteredResults.count; i++) {
        NSDictionary *tmpDic = [_filteredResults objectAtIndex:i];
        //NSLog(@"Dictionary %@", tmpDic);
        Item *tmpItem = [self itemFromDictionaryExternal:tmpDic];
        //[self loadItemImage:tmpItem];
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
    [itemsView reloadData];
}

//loads the images for an item (assumes item has saved url)
/*-(void)loadItemImage:(Item *)item {
    //creates an asynchronous queue so that loading the item will not interfer with the main queue (main queue remains open for ui updates)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Item Url:\n%@", item.url);
        item.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:item.url]]];
        item.imageLoadAttempted = true;
        //runs commands in the main queue once the loading is finished
        dispatch_sync(dispatch_get_main_queue(), ^{
            //reloads the tableView now that images have been saved
            [itemsView reloadData];
        });
    });
    
}*/

//reloads items saved to the phone (only difference is that loading images is done locally not from a URL
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
    tmpItem.userID = (NSInteger*)[[dictionary objectForKey:@"user_id"] integerValue];
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

//Loads items from the dictionary passed by the server (uses URL for image grab)
-(Item *)itemFromDictionaryExternal:(NSDictionary *) dictionary {
    Item *tmpItem = [[Item alloc] init];
    tmpItem.name = [dictionary objectForKey:@"item_name"];
    tmpItem.condition = (NSInteger *)[[dictionary objectForKey:@"item_condition"] integerValue];
    tmpItem.itemDescription = [dictionary objectForKey:@"item_description"];
    NSDictionary *jsonImageFilepath = [dictionary objectForKey:@"item_image"];
    
    NSString *imageFilepath = [jsonImageFilepath objectForKey:@"url"];
    tmpItem.url = [NSString stringWithFormat:@"%@", imageFilepath];
    NSLog(@"%@", tmpItem.url);
    
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
     
     
    tmpItem.priceInCents = (NSInteger*)[[dictionary objectForKey:@"item_price_in_cents"] integerValue];
    
    tmpItem.liked = [[dictionary objectForKey:@"liked"] boolValue];
    tmpItem.userID = (NSInteger*)[[dictionary objectForKey:@"user_id"] integerValue];
    NSInteger *tmpID = (NSInteger*)[[dictionary objectForKey:@"id"] integerValue];
    //NSLog(@"%@", [dictionary objectForKey:@"id"]);
    //NSLog(@"%zd", tmpID);
    tmpItem.itemID = tmpID;
    //NSLog(@"%zd", tmpItem.itemID);
    tmpItem.itemPurchaseState = (NSNumber *)[dictionary objectForKey:@"item_purchase_state"];
    return tmpItem;
}

//setup code for the view - initiates loading the items arrays and sets the delegates for the necessary views to the view controller
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    itemsView.delegate = self;
    itemsView.dataSource = self;
    [itemListType addTarget:self
                         action:@selector(viewSwitched)
               forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
    if (_items == nil) {
        _items = [[NSMutableArray alloc] init];
        [self loadAllItems];
    }
    if (_filteredItems == nil) {
        [self loadFilteredItems];
    }
    _likedItems = [[NSArray alloc] init];
    [self loadLikedItems];
    //show all items not liked items
    _showAll = true;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
