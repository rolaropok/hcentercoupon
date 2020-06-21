//
//  MapPoint.h
//  ToysRUsIL
//
//  Created by parkhya on 8/30/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject<MKAnnotation>
{
    
    NSString *_name;
    NSString *_address;
    CLLocationCoordinate2D _coordinate;
    
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
