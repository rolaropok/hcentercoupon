//
//  ActivityIndicator.m
//  Life
//
//  Created by Vita on 7/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkIndicator.h"

@implementation NetworkIndicator

static int counter = 0;

+ (void) startLoading
{
	if (counter == 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	
	counter++;
}

+ (void) stopLoading
{
	counter--;
	
	if (counter <= 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

+ (int) getCounter
{
    return counter;
}

@end