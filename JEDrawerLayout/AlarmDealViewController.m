//
//  AlarmDealViewController.m
//  weiju-property-ios
//
//  Created by Diana on 4/12/16.
//  Copyright © 2016 evideo. All rights reserved.
//

#import "AlarmDealViewController.h"

typedef NS_ENUM(int, ICDealMethodType)
{
    ICDealMethodTypeUnknown = -1,
    ICDealMethodTypeMistakenUse = 0,
    ICDealMethodTypeMachinePlayingUp = 1,
    ICDealMethodTypeAttendence = 2,
    ICDealMethodTypeByPhone = 3,
    ICDealMethodTypeOthers = 4
};

@interface AlarmDealViewController ()<UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, weak) IBOutlet UITextView* dealNoteView;

@end

@implementation AlarmDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onDealButtonPressed:(id)sender
{
    [self.view endEditing:YES];
//    _alarmModel.dealNote = _dealNoteView.text;
//    _alarmModel.dealType = ICDealTypeDeal;
//    [__serviceCenter alarmDeal:_alarmModel completion:^(NSError *error) {
//        [self.popoverSlideViewController hideMenuViewController:^{
            if (_dismissBlock) {
                _dismissBlock();
            }
//        }];
//    }];
    
}


- (IBAction)onDealMethodButtonPressed:(UIButton *)sender
{
    NSString *dealMethod = nil;
    
    switch (sender.tag) {
        case ICDealMethodTypeMistakenUse:
            dealMethod = (@"deal_mistaken_use");
            break;
        case ICDealMethodTypeMachinePlayingUp:
            dealMethod = (@"deal_machine_playing_up");
            break;
        case ICDealMethodTypeAttendence:
            dealMethod = (@"deal_attendence");
            break;
        case ICDealMethodTypeByPhone:
            dealMethod = (@"deal_by_phone");
            break;
        case ICDealMethodTypeOthers:
            [_dealNoteView becomeFirstResponder];
            break;
        default:
            break;
    }
    
    _dealNoteView.text = dealMethod;
    
}

#pragma mark Keyboard Show And Hide

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect frame = self.view.frame;
    if (frame.origin.y >= 0.0) {
        frame.origin.y -= [self keyboardHeight:notification];
        self.view.frame = frame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect frame = self.view.frame;
    if (frame.origin.y < 0.0) {
        frame.origin.y += [self keyboardHeight:notification];
        self.view.frame = frame;
    }
}

- (float)keyboardHeight:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    float keyboardHeight = keyboardSize.height;
    return keyboardHeight;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"..................touchesBegan");;
    [self.view endEditing:YES];
}

@end
