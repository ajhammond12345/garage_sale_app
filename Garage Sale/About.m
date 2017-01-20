//
//  About.m
//  Garage Sale
//
//  Created by Alexander Hammond on 1/16/17.
//  Copyright © 2017 TripleA. All rights reserved.
//

#import "About.h"

@interface About ()

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
    float barWidth = (amountRaisedInCents/goalInCents) * totalBar.frame.size.width;
    progressBar.frame = CGRectMake(progressBar.frame.origin.x, progressBar.frame.origin.y, barWidth, progressBar.frame.size.height);
    progressBar.hidden = FALSE;
}

-(void)setAmountRaisedText {
    int centsRaised = amountRaisedInCents % 100;
    int dollarsRaised = (amountRaisedInCents - centsRaised)/100;
    amountRaisedText.text = [NSString stringWithFormat:@"$%i.%i", dollarsRaised, centsRaised];
    amountRaisedText.hidden = FALSE;
}

-(void)setDaysRemaining {
    daysUntilNLC.text = [NSString stringWithFormat:@"%i", daysRemaining];
    daysUntilNLC.hidden = FALSE;
}



//Methods that load data update stored fields
-(void)loadAmountRaised {
    amountRaisedInCents = 5000;
    //insert code to load amountRaised
}

-(void)loadDaysRemaining {
    //creates NSDate for today
    NSDate *today = [NSDate date];
    //Creates Date Components for start of NLC (end of fundraiser)
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    //29th
    [dateComponents setDay:29];
    //June
    [dateComponents setMonth:6];
    //2017
    [dateComponents setYear:2017];
    //creates new date from the components
    NSDate *dateNLC = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    //next couple declarations from Apple's reccomendation on how to compare dates
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSUInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:today  toDate:dateNLC options:0];
    
    NSInteger days = [components day];
    
    //casts Integer (which stores a long) to int
    daysRemaining = (int)days;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hides the text and progress bar until they are loaded (they are revealed within the update methods through the set methods)
    goalInCents = 100000;
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
