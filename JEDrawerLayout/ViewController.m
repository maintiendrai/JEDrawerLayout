//
//  ViewController.m
//  JEDrawerLayout
//
//  Created by Diana on 4/19/16.
//  Copyright © 2016 goandfight. All rights reserved.
//

#import "ViewController.h"
#import "JEDrawerLayout.h"
#import "AlarmDealViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDrawerButtonPressed:(id)sender {
    JEDrawerLayout *callout = [[JEDrawerLayout alloc] init];
    
    
    AlarmDealViewController* alarmView = [[AlarmDealViewController alloc]initWithNibName:@"AlarmDealViewController" bundle:nil];
    
    [callout.contentView addSubview:alarmView.view];
    alarmView.view.frame = callout.contentView.frame;
    callout.showFromRight = YES;
    [callout show];
}

@end
