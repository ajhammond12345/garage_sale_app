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

//updates the data then the view
-(void)updateDaysRemaining {
    [self loadDaysRemaining];
    [self setDaysRemaining];
}


//sets the width of the progress bar based on the amount raised and goal
-(void)setProgressBarWidth {
        int barWidth = (_amountRaisedInCents * totalBar.frame.size.width)/_goalInCents;
        NSLog(@"Bar Width: %i", barWidth);
    if (barWidth > totalBar.frame.size.width) {
        progressBarWidth.constant = totalBar.frame.size.width;
    }
    else {
        progressBarWidth.constant = barWidth;
    }
        progressBar.hidden = NO;
    
}

//sets percent raised (class variable to reduce processing time and code repetition)
-(void)setPercentRaised {
    int percentRaisedInt = (100*_amountRaisedInCents)/_goalInCents;
    percentRaised.text = [NSString stringWithFormat:@"%i%%", percentRaisedInt];
}


//updates the UI with the amount raised
-(void)setAmountRaisedText {
    int centsRaised = _amountRaisedInCents % 100;
    int centsRaisedTens = centsRaised / 10;
    int centsRaisedOnes = centsRaised % 10;
    int dollarsRaised = (_amountRaisedInCents - centsRaised)/100;
    amountRaisedText.text = [NSString stringWithFormat:@"$%i.%i%i", dollarsRaised, centsRaisedTens, centsRaisedOnes];
    amountRaisedText.hidden = FALSE;
}

//udates the UI with the days remaining
-(void)setDaysRemaining {
    daysUntilNLC.text = [NSString stringWithFormat:@"%i Days Until", _daysRemaining];
    daysUntilNLC.hidden = FALSE;
}



//loads the amount that has been raised from the server, if failure to connect it leaves it as 0
-(void)loadAmountRaised {
    //sets to default of 0
    _amountRaisedInCents = 0;
    //creates url session to load amount raised
    //production url
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://murmuring-everglades-79720.herokuapp.com/total.json"];
    //testing url
    //NSString *jsonUrlString = [NSString stringWithFormat:@"http://localhost:3001/total.json"];
    NSURL *url = [NSURL URLWithString:jsonUrlString];
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
}

//if data comes back from url session (only session in here is to load amount raised) then it updates the amount raised (the view and the data)
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

//calculates the number of days remaining and updates the variable _daysRemaining
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

//startup code - here is where goal is set and the updates for the UI are called
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



@end
