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
    NSString *tmp = [inputComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([tmp isEqual: @""] || [tmp isEqual: @"Type comment here"]) {
        inputComment.text = [NSString stringWithFormat:@"Type comment here"];
    }
    else {
        _userComment = tmp;
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
    NSString *commentsOnThisItem = @"";
    for (int i = 0; i < _item.comments.count; i++) {
        commentsOnThisItem = [NSString stringWithFormat:@"%@\n\n%@", commentsOnThisItem, [_item commentWithIndex:i]];
    }
    NSLog(@"%@\n%@", commentsOnThisItem, _item.comments);
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
    [_item downloadComments];
    [self showComments];
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
