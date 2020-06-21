//
//  ViewController.h
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMPActivityIndicator.h"

@interface ViewController : UIViewController<NSURLConnectionDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIButton* startButton;
-(IBAction)StartBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;


@end
