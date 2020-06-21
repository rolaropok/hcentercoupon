//
//  PolicyViewController.h
//  CouponApp
//
//  Created by parkhya on 8/26/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PolicyViewController : UIViewController

@property(nonatomic,retain)NSString *PolicyText;

-(IBAction)PolicyFavoritesBtnClicked:(id)sender;
//-(IBAction)PolicyPolicyBtnClicked:(id)sender;
-(IBAction)PolicyStoreLocatorBtnClicked:(id)sender;
-(IBAction)PolicyShopOnlineBtnClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *PolicyTextView;

-(IBAction)CrossBtnClicked:(id)sender;
@end
