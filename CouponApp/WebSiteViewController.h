//
//  WebSiteViewController.h
//  CouponApp
//
//  Created by parkhya on 8/26/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebSiteViewController : UIViewController<UIWebViewDelegate>
-(IBAction)CrossBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *CouponWebView;
@end
