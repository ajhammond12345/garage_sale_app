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


-(void)downloadComments {
    //sets whatever it gets from server (with its ID) to comments array
    
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/items/%zd.json", _item.itemID];
    //NSLog(@"URL Request: %@", jsonUrlString);
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
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    //NSLog(@"Result (Length: %zd) = %@",_result.count, _result);
    NSArray *fullComments =  [result objectForKey:@"comments"];
   // NSLog(@"All comments:\n%@", fullComments);
    _item.comments = [[NSMutableArray alloc] init];
    for (int i = 0; i < fullComments.count; i++) {
        NSDictionary *tmpDic = [fullComments objectAtIndex:i];
        //NSLog(@"Dictionary: %@", tmpDic);
        NSString *tmpString = [tmpDic objectForKey:@"comment_text"];
        //NSLog(@"Comment Text: %@", tmpString);
        [_item addComment:tmpString];
        //NSLog(@"Comment Text in comments: %@", _item.comments);
    }
    //NSLog(@"Item Comments: %@", _item.comments);
    [self showComments];
    [session invalidateAndCancel];
    
}

-(IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"returnFromComments" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"returnFromComments"]) {
        ItemDetail *destinationViewController = segue.destinationViewController;
        destinationViewController.itemOnDisplay = _item;
    }
}

-(IBAction)postComment:(id)sender {
    NSString *tmp = inputComment.text;
    if ([tmp isEqual: @""] || [tmp isEqual: @"Type comment here"]) {
        inputComment.text = [NSString stringWithFormat:@"Type comment here"];
        //show error for "please type comment"
    }
    else {
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSLog(@"%@", username);
        _userComment = [NSString stringWithFormat:@"%@:%@", username, tmp];
    }
    
    if (_userComment != nil) {
        [_item uploadComment:_userComment];
        [self showComments];
        inputComment.text = @"Type comment here";
        if ([inputComment isFirstResponder]) {
            [inputComment resignFirstResponder];
        }
        [self.view endEditing:YES];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Comment" message:@"Please input a comment to post." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)showComments {
    //NSLog(@"Item has comments: %@", _item.comments);
    NSString *commentsOnThisItem = @"";
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
        commentsOnThisItem = [NSString stringWithFormat:@"%@%@:\n\t%@\n\n", commentsOnThisItem, username, text];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
