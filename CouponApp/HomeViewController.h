//
//  HomeViewController.h
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AMPActivityIndicator.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
@interface HomeViewController : UIViewController<UIScrollViewDelegate>
{
    UIView *Parentview;
    //NSMutableArray *CouponArr;
    NSMutableArray *favoriteArr;
    UIView *animateView;
    NSMutableArray *ViewsArr;
}
@property NSInteger category;
@property NSInteger startCouponId;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
- (IBAction)changePage;
@property (weak, nonatomic) IBOutlet UIImageView *BackRedBagView;
@property (weak, nonatomic) IBOutlet UIScrollView *HomeScrollView;
@property (weak, nonatomic) IBOutlet UIButton *PreviousButton;
@property (weak, nonatomic) IBOutlet UIButton *NextButton;
@property(nonatomic,strong)AMPActivityIndicator* progressView;
//@property (strong, atomic)     NSMutableArray *CouponArr;
@property NSInteger couponCounts;
@property (weak, nonatomic) IBOutlet UITableView *HomeTableView;

@property (weak, nonatomic) IBOutlet UIButton *assortedButton;
@property (weak, nonatomic) IBOutlet UIButton *babyButton;
@property (weak, nonatomic) IBOutlet UIButton *boyButton;
@property (weak, nonatomic) IBOutlet UIButton *girlButton;
@property (weak, nonatomic) IBOutlet UIButton *powerCardButton;

-(IBAction)FavoritesBtnClicked:(id)sender;
-(IBAction)PoliceBtnClicked:(id)sender;
-(IBAction)StoreLocatorBtnClicked:(id)sender;
-(IBAction)ShopOnlineBtnClicked:(id)sender;
-(IBAction)RefreshButtonClicked:(id)sender;

-(IBAction)nextButClicked:(id)sender;
-(IBAction)PreviousButClicked:(id)sender;
@end
