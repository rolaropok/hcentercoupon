//
//  DataBase.h
//  CouponApp
//
//  Created by parkhya on 8/26/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CouponInfo.h"

@interface DataBase : NSObject
{
    NSString *databasepath;
    CouponInfo *CInfo;
}

+(DataBase*)getSharedInstance;

@property BOOL isFirst;

#pragma Favorit List Methods 

- (BOOL) AddToFavoriteListData:(CouponInfo*)CoupInfo;

-(NSMutableArray*)receiveAllData;

-(BOOL)CheckCouponId:(NSString*)CoupId;

-(BOOL)deleteDataFromFavoritesList:(CouponInfo*)coupon;

@end
