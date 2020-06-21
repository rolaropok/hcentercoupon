//
//  ActivityIndicator.h
//  Life
//
//  Created by Vita on 7/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

@interface NetworkIndicator : NSObject

+ (void) startLoading;
+ (void) stopLoading;
+ (int) getCounter;
@end
