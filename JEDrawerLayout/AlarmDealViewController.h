//
//  AlarmDealViewController.h
//  weiju-property-ios
//
//  Created by Diana on 4/12/16.
//  Copyright © 2016 evideo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmDealViewController : UIViewController

//@property(nonatomic, strong) ICAlarmModelEx* alarmModel;
@property(copy) void(^dismissBlock)();


@end
