//
//  CouponInfo.h
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponInfo : NSObject



@property NSString *C_Date;
@property NSString *C_Image;
@property NSInteger C_Category;
@property NSString *C_ThumbImage;
@property  NSString *C_Name;
@property NSString *C_Text;
@property NSString *ID;
@property NSString *To_Date;
@property NSString *Total_Like;
@property NSString *CouponNumber;
@property UIImage *CouponImage;
@property NSString *isLoaded;

@property UIImage *C_ShareImage;
@property NSString *C_sImageUrl;

@property NSString *S_ID;
@property NSString *S_Address;
@property NSString *S_City;
@property NSString *S_Image;
@property NSString *S_Lat;
@property NSString *S_Long;
@property NSString *S_Name;
@property NSString *S_Text;
@property UIImage *StoreImage;

@property NSString *C_Lat;
@property NSString *C_Long;
@property NSString *C_ID;
@property NSString *City_Name;

@end
