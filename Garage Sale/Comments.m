//
//  Comments.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/23/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "Comments.h"

@interface Comments () <UITextViewDelegate>

@end

@implementation Comments

//initiates url session to download comments
-(void)downloadComments {
    //production url
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _item.itemID];
    //test url
    //NSString *jsonUrlString = [NSString stringWithFormat:@"http://localhost:3001/items/%zd.json", _item.itemID];
    //NSLog(@"URL Request: %@", jsonUrlString);
    NSURL *url = [NSURL URLWithString:jsonUrlString];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
}

//runs when data comes in
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    NSError *error;
    //saves the data to a dictionary
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"Result (Length: %zd) = %@",_result.count, _result);
    //creates array from all of the comments in the dictionary
    NSArray *fullComments =  [result objectForKey:@"comments"];
   // NSLog(@"All comments:\n%@", fullComments);
    _item.comments = [[NSMutableArray alloc] init];
    //adds the downloaded comments to the local array
    for (int i = 0; i < fullComments.count; i++) {
        NSDictionary *tmpDic = [fullComments objectAtIndex:i];
        //NSLog(@"Dictionary: %@", tmpDic);
        NSString *tmpString = [tmpDic objectForKey:@"comment_text"];
        //NSLog(@"Comment Text: %@", tmpString);
        [_item addComment:tmpString];
        //NSLog(@"Comment Text in comments: %@", _item.comments);
    }
    //NSLog(@"Item Comments: %@", _item.comments);
    //updates the view
    [self showComments];
    //closes the url seession
    [session invalidateAndCancel];
    
}

//programmatially called segue (so that prepare foe segue can be used
-(IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"returnFromComments" sender:self];
}

//passes on the item info to the ItemDetail view controller
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"returnFromComments"]) {
        ItemDetail *destinationViewController = segue.destinationViewController;
        destinationViewController.itemOnDisplay = _item;
    }
}

//posts the user's comment when they click post
-(IBAction)postComment:(id)sender {
    NSString *tmp = inputComment.text;
    //if comment is empty it does not upload it
    if ([tmp isEqual: @""] || [tmp isEqual: @"Type comment here"]) {
        inputComment.text = [NSString stringWithFormat:@"Type comment here"];
        //show error for "please type comment"
    }
    else {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSLog(@"%@", username);
        _userComment = [NSString stringWithFormat:@"%@:%@", username, tmp];
    }
    //if the comment has been posted it uploads it and resets the input textfield
    if (_userComment != nil) {
        [_item uploadComment:_userComment];
        [self showComments];
        inputComment.text = @"Type comment here";
        if ([inputComment isFirstResponder]) {
            [inputComment resignFirstResponder];
        }
        [self.view endEditing:YES];
    }
    //alert for when no comment has been posted
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Comment" message:@"Please input a comment to post." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)showComments {
    //NSLog(@"Item has comments: %@", _item.comments);
    //creates empty string to append all of the comments on
    NSString *commentsOnThisItem = @"";
    //loops through all of the comments and appends them with the specified format
    for (int i = 0; i < _item.comments.count; i++) {
        NSString *username;
        NSString *text;
        NSString *full = [_item commentWithIndex:i];
        for (int i = 0; i < (full.length-1); i++) {
            if ([@":" isEqualToString:[[full substringFromIndex:i] substringToIndex:1]]) {
                username = [full substringToIndex:i];
                text = [full substringFromIndex:i+1];
                break;
            }
        }
        //does not use appendString b/c that failed in testing
        //adds the comment in the specified format
        commentsOnThisItem = [NSString stringWithFormat:@"%@%@:\n\t%@\n\n", commentsOnThisItem, username, text];
    }
    //if no comments displays No Comments
    if ([commentsOnThisItem isEqualToString:@""]) {
        commentsOnThisItem = [NSString stringWithFormat:@"No Comments"];
    }
    //loading the image on the page
    if (_item.image != nil) {
        showImage.image = _item.image;
    }
    //if images is missing it shows the default image
    else {
        showImage.image = [UIImage imageNamed:@"missing.png"];
    }
    //manages the purchased image
    if ([_item.itemPurchaseState intValue] == 1) {
        purchased.hidden = NO;
    }
    else {
        purchased.hidden = YES;
    }
    //NSLog(@"%@\n%@", commentsOnThisItem, _item.comments);
    otherComments.text = commentsOnThisItem;
}

//if user has input text, saves the text for posting, if they have not, replaces the default text
-(void)textViewDidEndEditing:(UITextView *)textView {
    //creates a copy of the string with whitespace removed to check if visible text has been entered so they will not lose the text box
    NSString *tmp = [inputComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tmp isEqual: @""] || [tmp isEqual: @"Type comment here"]) {
        inputComment.text = [NSString stringWithFormat:@"Type comment here"];
    }
    else {
        _userComment = inputComment.text;
    }
    [textView resignFirstResponder];
}

//removes the placeholder text
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Type comment here"]) {
        textView.text = [NSString stringWithFormat:@""];
    }
}

//makes keyboard disappear when return (done) pressed
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

//makes sure they cant edit the view that displays all of the comments
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:otherComments]) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    inputComment.delegate = self;
    otherComments.delegate = self;
    [self downloadComments];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
