//
//  HomeCustomCell.h
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LikeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *CouponImageView;
@property (weak, nonatomic) IBOutlet UILabel *CouponIdLabel;
@property (weak, nonatomic) IBOutlet UITextView *CouponDescTextView;
@property (weak, nonatomic) IBOutlet UIButton *ShareBtn;

@property (weak, nonatomic) IBOutlet UIButton *SendBtn;
@property (weak, nonatomic) IBOutlet UIButton *LikeBtn;
@property (weak, nonatomic) IBOutlet UIButton *AddToFavoritesBtn;
@property (weak, nonatomic) IBOutlet UILabel *C_NameLab;
@property (weak, nonatomic) IBOutlet UILabel *CouponNo;

@end
