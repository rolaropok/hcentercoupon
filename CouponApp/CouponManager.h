//
//  CouponManager.h
//  ToysRUsIL
//
//  Created by soft on 20/02/15.
//  Copyright (c) 2015 soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponManager : NSObject

@property (atomic, retain) NSMutableArray *cat1,*cat2,*cat3,*cat4,*cat5;
@property (atomic) NSInteger cat1Size,cat2Size,cat3Size,cat4Size,cat5Size;
@property (atomic) NSInteger totalCoupons;
@property (nonatomic, strong) NSURL* bannerUrl;

+(id)sharedManager;
- (void) parseCoupons:(NSArray*) arr;
- (void) clearCoupons;
- (NSURL*) getBannerUrl;
@end
