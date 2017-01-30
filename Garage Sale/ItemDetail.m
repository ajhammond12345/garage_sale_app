//
//  ItemDetail.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/22/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "ItemDetail.h"

@interface ItemDetail () <UITextViewDelegate, PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ItemDetail

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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _itemOnDisplay.itemID]];
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
              
              [self performSegueWithIdentifier:@"toPurchaseThankYou"  sender:self];
          });
      }] resume];

}



-(IBAction)comments:(id)sender {
    [self performSegueWithIdentifier:@"toComments" sender:self];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"toComments"]) {
        Comments *destinationViewController = segue.destinationViewController;
        destinationViewController.item = _itemOnDisplay;
        
    }
}

-(void)updateView {
    purchased.hidden = YES;
    displayName.text = _itemOnDisplay.name;
    int index = (int) _itemOnDisplay.condition;
    NSArray *conditionOptionsDetail = [[NSUserDefaults standardUserDefaults] objectForKey:@"conditions"];
    displayCondition.text = conditionOptionsDetail[index];
    displayPrice.text = [_itemOnDisplay getPriceString];
    displayDescription.text = _itemOnDisplay.itemDescription;
    if (_itemOnDisplay.liked) {
        [displayLikeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Solid.png"] forState:UIControlStateNormal];
    }
    else {
        [displayLikeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Transparent.png"] forState:UIControlStateNormal];
    }
    if (_itemOnDisplay.image != nil) {
        displayImage.image = _itemOnDisplay.image;
    }
    else {
        displayImage.image = [UIImage imageNamed:@"missing.png"];
    }
    if ([_itemOnDisplay.itemPurchaseState intValue] == 1) {
        purchased.hidden = NO;
    }
    else {
        purchased.hidden = YES;
    }
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

-(IBAction)buyWithoutApplePay:(id)sender {
    NSLog(@"%@", _itemOnDisplay.localDictionary);
    [_itemOnDisplay setItemDictionary];
    NSLog(@"local Dictionary\n%@", _itemOnDisplay.localDictionary);
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithObject:[_itemOnDisplay.localDictionary objectForKey:@"item_purchase_state"] forKey:@"item_purchase_state"];
    NSLog(@"TmpDic%@", tmpDic);
    NSInteger *check = (NSInteger *)[[tmpDic objectForKey:@"item_purchase_state"] integerValue];
    NSLog(@"Check: %zd",check);
    if (check == 0){
        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat: @"%i", 1], @"item_purchase_state", nil];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tmpDic options:NSJSONWritingPrettyPrinted error:&error];
        
        //creates url for the request
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _itemOnDisplay.itemID]];
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
                  
                  [self performSegueWithIdentifier:@"toPurchaseThankYou"  sender:self];
              });
          }] resume];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load Error" message:@"Cannot load item for purchase" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)like:(id)sender {
    [_itemOnDisplay changeLiked];
    if (_itemOnDisplay.liked) {
        [displayLikeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Solid.png"] forState:UIControlStateNormal];
    }
    else {
        [displayLikeButton setImage:[UIImage imageNamed:@"Instagram-Heart-Transparent.png"] forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateView];
    displayDescription.delegate = self;
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]]) {
        buyButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
    }
    else {
        buyButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleBlack];
    }
    
    //insert apple pay image code
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
