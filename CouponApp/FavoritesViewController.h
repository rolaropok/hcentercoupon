//
//  FavoritesViewController.h
//  CouponApp
//
//  Created by parkhya on 8/27/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMPActivityIndicator.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
@interface FavoritesViewController : UIViewController<UIScrollViewDelegate>
{
 NSMutableArray *favoriteArr;
    UIView *Parentview;
     NSMutableArray *likeArr;
     UIView *animateView;
}
@property (weak, nonatomic) IBOutlet UIScrollView *FavoritScrollView;
@property (weak, nonatomic) IBOutlet UITableView *FavoritesTableView;
@property (weak, nonatomic) IBOutlet UIImageView *faviriotBgImageView;
@property (weak, nonatomic) IBOutlet UIButton *FavPreviousButton;

@property(nonatomic,strong)AMPActivityIndicator* progressView;
@property (weak, nonatomic) IBOutlet UIButton *FavNextButton;

-(IBAction)FavoritesPolicyBtnClicked:(id)sender;
-(IBAction)FavoritesStoreLocatorBtnClicked:(id)sender;
-(IBAction)FavoritesShopOnlineBtnClicked:(id)sender;

-(IBAction)FavnextButClicked:(id)sender;
-(IBAction)FavPreviousButClicked:(id)sender;
@end
