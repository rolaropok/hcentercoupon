//
//  AppDelegate.h
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSURLConnection *Connection,*Connection1;
    
}
@property (nonatomic,retain) NSMutableData *webData,*webData1;

@property (strong, nonatomic) UIWindow *window;

@property int DeviceHight;
+(AppDelegate*)sharedInstance;
@end
