//
//  HomeCustomCell.m
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "HomeCustomCell.h"

@implementation HomeCustomCell

@synthesize LikeBtn,LikeLabel,CouponNo;
@synthesize CouponDescTextView,CouponIdLabel,CouponImageView;
@synthesize ShareBtn,SendBtn;
@synthesize AddToFavoritesBtn;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
    
    
    
}

@end
