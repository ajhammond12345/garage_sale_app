//
//  About.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "About.h"

@interface About () <NSURLSessionDelegate>

@end

@implementation About

/* Overall Methods
 updateAmountRaised
 */

-(void)updateAmountRaised {
    //loads the most recent value for the amount raise
    [self loadAmountRaised];
    //updates the progress bar
    [self setProgressBarWidth];
    //updates the text
    [self setAmountRaisedText];
    [self setPercentRaised];
}

-(void)updateDaysRemaining {
    [self loadDaysRemaining];
    [self setDaysRemaining];
}




/*Methods that control the page
    setProgressBarWidth
    setAmountRaisedText
    setDaysUntil
 */
-(void)setProgressBarWidth {
        int barWidth = (_amountRaisedInCents * totalBar.frame.size.width)/_goalInCents;
        NSLog(@"Bar Width: %i", barWidth);

        progressBarWidth.constant = barWidth;
        progressBar.hidden = NO;
    
}
-(void)setPercentRaised {
    int percentRaisedInt = (100*_amountRaisedInCents)/_goalInCents;
    percentRaised.text = [NSString stringWithFormat:@"%i%%", percentRaisedInt];
}

-(void)setAmountRaisedText {
    int centsRaised = _amountRaisedInCents % 100;
    int centsRaisedTens = centsRaised / 10;
    int centsRaisedOnes = centsRaised % 10;
    int dollarsRaised = (_amountRaisedInCents - centsRaised)/100;
    amountRaisedText.text = [NSString stringWithFormat:@"$%i.%i%i", dollarsRaised, centsRaisedTens, centsRaisedOnes];
    amountRaisedText.hidden = FALSE;
}

-(void)setDaysRemaining {
    daysUntilNLC.text = [NSString stringWithFormat:@"%i Days Until", _daysRemaining];
    daysUntilNLC.hidden = FALSE;
}



//Methods that load data update stored fields
-(void)loadAmountRaised {
    _amountRaisedInCents = 0;
    //insert code to load amountRaised
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/total.json"];
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
    NSString *totalRaised = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    _amountRaisedInCents = [totalRaised intValue];
    [self setProgressBarWidth];
    //updates the text
    [self setAmountRaisedText];
    [self setPercentRaised];
    [session invalidateAndCancel];
    
}

-(void)loadDaysRemaining {
    //creates NSDate for today
    NSDate *today = [NSDate date];
    //Creates Date Components for start of NLC (end of fundraiser)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *dateNLC = [dateFormatter dateFromString:@"2017-06-29"];
    
    //next couple declarations from Apple's reccomendation on how to compare dates
    NSCalendar *tempCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [tempCalendar components:NSCalendarUnitDay fromDate:today  toDate:dateNLC options:0];
    
    NSInteger days = [components day];
    
    
    //casts Integer (which stores a long) to int
    _daysRemaining = (int)days;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hides the text and progress bar until they are loaded (they are revealed within the update methods through the set methods)
    //             10000.00
    //             10000 00
    //             1000000
    _goalInCents = 1000000;
    _amountRaisedInCents = 0;
    amountRaisedText.hidden = TRUE;
    daysUntilNLC.hidden = TRUE;
    progressBar.hidden = TRUE;
    [self updateAmountRaised];
    [self updateDaysRemaining];
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
