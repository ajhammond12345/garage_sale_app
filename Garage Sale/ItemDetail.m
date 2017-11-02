//
//  ItemDetail.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/22/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "ItemDetail.h"
#import "PurchaseThankYou.h"

//TODO heart update item in saved list when liked

@interface ItemDetail () <UITextViewDelegate, PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ItemDetail

-(IBAction)share:(id)sender {
    NSString *text = [NSString stringWithFormat:@"I found this cool %@ on FUNDonation! Check it out on the app and help the fundraiser.", _itemOnDisplay.name];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/fundonation/id1200352853"];
    UIImage *image = _itemOnDisplay.image; //[UIImage imageNamed:@"itunesartwork_2x_720.png"];
    NSArray *itemsToShare = @[text, url, image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeOpenInIBooks, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)buyWithApplePay:(id)sender {
    NSLog(@"%@", _itemOnDisplay.localDictionary);
    [_itemOnDisplay setItemDictionary];
    NSLog(@"local Dictionary\n%@", _itemOnDisplay.localDictionary);
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:[_itemOnDisplay.localDictionary objectForKey:@"item_purchase_state"] forKey:@"item_purchase_state"];
    NSLog(@"TmpDic%@", tmpDic);
    NSInteger *check = (NSInteger *)[[tmpDic objectForKey:@"item_purchase_state"] integerValue];
    NSLog(@"Check: %zd",check);
    if (check == 0) {
        
        //sets up the apple pay request
        PKPaymentRequest *request = [PKPaymentRequest new];
        request.merchantIdentifier = @"merchant.hammond.alexander.fbla.app";
        request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkDiscover];
        request.merchantCapabilities = PKMerchantCapability3DS;
        request.countryCode = @"US";
        request.currencyCode = @"USD";
        //first step to convert to format needed for payment
        NSUInteger *tmp = (NSUInteger *)_itemOnDisplay.priceInCents;
        //converts to format needed for payment
        unsigned long long priceInCents = (unsigned long long)tmp;
        NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithMantissa:priceInCents exponent:-2 isNegative:false];
        PKPaymentSummaryItem *final_price = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:totalAmount];
        request.paymentSummaryItems = [[NSArray alloc] initWithObjects:final_price, nil];
        
        //presents the apple pay view controller
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if (check == (NSInteger *)1){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Purchase" message:@"Someone has already purchased this item" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load Error" message:@"Cannot load item for purchase" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                      didAuthorizePayment:(PKPayment *)payment
                               completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    //would insert code to pass this on to a payment company if this were real
    
    //instead will load to the server that the item was purchased
    
    //this only reached if item has not been purchased, so assigning the
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat: @"%i", 1], @"item_purchase_state", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
    
    //creates url for the request
    //production url
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _itemOnDisplay.itemID]];
    //testing url
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3001/items/%zd.json", _itemOnDisplay.itemID]];
    //NSLog(@"%@", url);
    
    //creates a URL request
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    //specifics for the request (it is a post request with json content)
    [uploadRequest setHTTPMethod:@"PATCH"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody: jsonData];
    
    //
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
              NSLog(@"requestReply: %@", requestReply);
              [controller dismissViewControllerAnimated:YES completion:NULL];
              [self performSegueWithIdentifier:@"toPurchaseThankYou"  sender:self];
          });
      }] resume];
    
}

//loads the comments page when the comments button is pressed
-(IBAction)comments:(id)sender {
    [self performSegueWithIdentifier:@"toComments" sender:self];
}

-(IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"toItems" sender:self];
}

//ensures that the description text view (required to show multiple lines in a scrollable format) will not react to user interaction
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

//runs before segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //if going to the comments page it sets the current item to the item for the comments page to use when displaying comments
    if ([segue.identifier isEqualToString: @"toComments"]) {
        Comments *destinationViewController = segue.destinationViewController;
        destinationViewController.item = _itemOnDisplay;
        
    }
    
    //if going to the thank you page it sends the current item forward so that it can be sent back by that page when it segues back to this view
    if ([segue.identifier isEqualToString:@"toPurchaseThankYou"]) {
        PurchaseThankYou *dest = segue.destinationViewController;
        dest.itemStorage = _itemOnDisplay;
    }
    
    if ([segue.identifier isEqualToString:@"toItems"]) {
        Items *dest = segue.destinationViewController;
        dest.items = _items;
    }
}

//updates all parts of the UI for the page (easy method to call when data loads or changes (i.e. liked or purchased)
-(void)updateView {
    //hides the purchased button to ensure it won't incorrectly show up
    purchased.hidden = YES;
    
    //sets the name text
    displayName.text = _itemOnDisplay.name;
    
    //gets the int that represents condition (indicative of its position in the conditions array)
    int index = (int) _itemOnDisplay.condition;
    
    //loads the conditions array
    NSArray *conditionOptionsDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    
    //sets the condition text based on index value
    displayCondition.text = conditionOptionsDetail[index];
    
    //displays the price (uses helper method from the Item class to convert the int in cents to a string in $)
    displayPrice.text = [_itemOnDisplay getPriceString];
    
    //displays the description text
    displayDescription.text = _itemOnDisplay.itemDescription;
    
    //if item liked, sets the heart to solid
    if (_itemOnDisplay.liked) {
        [displayLikeButton setImage:[UIImage imageNamed:@"tall_like_full.png"] forState:UIControlStateNormal];
    }
    else {
        [displayLikeButton setImage:[UIImage imageNamed:@"tall_like_empty.png"] forState:UIControlStateNormal];
    }
    
    //if the item has an image (server errors may cause it to be missing an image) it displays it
    if (_itemOnDisplay.image != nil) {
        displayImage.image = _itemOnDisplay.image;
    }
    else {
        //if missing the image it shows a default image that shows the image is missing
        displayImage.image = [UIImage imageNamed:@"missing.png"];
    }
    
    //if item purchased, it shows the purchased image, if not it hides it
    if ([_itemOnDisplay.itemPurchaseState intValue] == 1) {
        purchased.hidden = NO;
    }
    else {
        purchased.hidden = YES;
    }
}

-(IBAction)buyWithoutApplePay:(id)sender {

    //NSLog(@"%@", _itemOnDisplay.localDictionary);
    
    //has the item update its internal dictionary before checking purchase state
    [_itemOnDisplay setItemDictionary];
    //NSLog(@"local Dictionary\n%@", _itemOnDisplay.localDictionary);
    
    //loads the purchase state from the object (loads as a dictionary for later use converting to json)
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:[_itemOnDisplay.localDictionary objectForKey:@"item_purchase_state"] forKey:@"item_purchase_state"];
    
    //NSLog(@"TmpDic%@", tmpDic);
    
    //loads an integer from the previously loaded dictionary to be used for evaluation
    NSInteger *check = (NSInteger *)[[tmpDic objectForKey:@"item_purchase_state"] integerValue];
    //NSLog(@"Check: %zd",check);
    
    //evaluates the purchased value - if item has been purchased it proceeds to 'buy' the item (changing its status in the server)
    if (check == 0){
        //creates an alert controller for them to confirm the purchase
        UIAlertController *purchaseConfirmation = [UIAlertController alertControllerWithTitle:@"Purchase" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
        //action to confirm purchase
        UIAlertAction *purchase = [UIAlertAction actionWithTitle:@"Buy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            //all of the code to do the purchase if the Buy button is pressed
            
            //recreates the dic with the new purchase state
            NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat: @"%i", 1], @"item_purchase_state", nil];
            
            //creates error handler
            NSError *error;
            
            //creates a json request from the dictionary
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
            
            //creates url for the request
            //production url
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _itemOnDisplay.itemID]];
            //testing url
            //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3001/items/%zd.json", _itemOnDisplay.itemID]];
            //NSLog(@"%@", url);
            
            //creates a request from the URL with a 60 second timeout
            NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            
            //specifics for the request (it is a PATCH (update) request with json content)
            [uploadRequest setHTTPMethod:@"PATCH"];
            [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
            [uploadRequest setHTTPBody: jsonData];
            
            //creates the url session for the url request
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            //runs the session with handler code to see if the upload was successful
            [[session dataTaskWithRequest:uploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
              {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                      NSLog(@"requestReply: %@", requestReply);
                      _itemOnDisplay.itemPurchaseState = [NSNumber numberWithInt:1];
                      [self performSegueWithIdentifier:@"toPurchaseThankYou"  sender:self];
                  });
              }] resume];
        //this ends the code for the action for the Buy button
        }];
        
        //creates a cancel button for the confirmation alert
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        }];
        
        //adds the buy and cancel buttons and presents the confirmation
        [purchaseConfirmation addAction:purchase];
        [purchaseConfirmation addAction:cancel];
        [self presentViewController:purchaseConfirmation animated:YES completion:nil];
    }
    else if (check == (NSInteger *)1){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Purchase" message:@"Someone has already purchased this item" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load Error" message:@"Cannot load item for purchase" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//action for like button - calls the internal method to change the liked status of the object then update the UI by changing the button image to reflect the new state
-(IBAction)like:(id)sender {
    [_itemOnDisplay changeLiked];
    [_items replaceObjectAtIndex:_itemOnDisplayRow withObject:_itemOnDisplay];
    if (_itemOnDisplay.liked) {
        [displayLikeButton setImage:[UIImage imageNamed:@"tall_like_full.png"] forState:UIControlStateNormal];
    }
    else {
        [displayLikeButton setImage:[UIImage imageNamed:@"tall_like_empty.png"] forState:UIControlStateNormal];
    }
}

//setup for when the view loads
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //updates the view (all UI elements)
    [self updateView];
    
    //sets the delegate for the text view (allows above delegate method to ensure users can't interact with it)
    displayDescription.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
