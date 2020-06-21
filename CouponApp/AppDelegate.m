//
//  AppDelegate.m
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry/Flurry.h"

@implementation AppDelegate
@synthesize webData,webData1;
@synthesize DeviceHight;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"6CZKXJ4WK7WF7GZTJ9YW"];
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    UIStoryboard *storyboard = [self grabStoryboard];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

+(AppDelegate*)sharedInstance
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (UIStoryboard *)grabStoryboard {
    
    UIStoryboard *storyboard;
    
    // detect the height of our screen
    int height = [UIScreen mainScreen].bounds.size.height;
    DeviceHight=height;
    if (height == 480) {
        storyboard = [UIStoryboard storyboardWithName:@"Storyboard3.5" bundle:nil];
        // NSLog(@"Device has a 3.5inch Display.");
    } else {
        
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // NSLog(@"Device has a 4inch Display.");
    }
    
    return storyboard;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /*
     NSString *msg = [NSString stringWithFormat:@"Successfully Registered to Push Center. DeviceToken:%@",deviceToken];
     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
     [alert show];
     */
    
    
    NSUserDefaults *deviceDefault=[NSUserDefaults standardUserDefaults];
    [deviceDefault setValue:deviceToken forKey:@"DeviceToken"];
    
    NSString *str = [NSString stringWithFormat:@"Device Token=%@",deviceToken];
    NSLog(@"deviceToken=%@", str);
    
    NSData *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
    // NSLog(@"%@",num);
    NSString* deviceid = [[[[num description]
                            stringByReplacingOccurrencesOfString: @"<" withString: @""]
                           stringByReplacingOccurrencesOfString: @">" withString: @""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSString *phoneName = [[UIDevice currentDevice] name];
    
    NSUUID *phoneUniqueIdentifier = [[UIDevice currentDevice] identifierForVendor];
    
    NSString *udid=[phoneUniqueIdentifier UUIDString];
    NSString *newUdid=[udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Put_Gcm;
    
    
    NSMutableData *body = [[NSMutableData alloc]init ];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setURL:[NSURL URLWithString:urlstring]];
    [request setHTTPMethod:@"POST"];
    
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //NSString *first_name = @"Yes";
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:newUdid] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"device_id=%@", newUdid);
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_name\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:phoneName] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"device_name=%@", phoneName);
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_gcm\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:deviceid] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"device_gcm=%@", deviceid);
    
    
    NSString *deviceType=@"ios";
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_type\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:deviceType] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"device_type=%@", deviceType);
    
    [request setHTTPBody:body];
    Connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if(Connection)
    {
        webData = [[NSMutableData alloc]init];
    }
    else
    {
        
        
    }
}


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        NSLog(@"user info %@ ",userInfo);
        
        
        
        NSString *message=[[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:message
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
        
        /*
         int code = error.code ;
         NSString *msg = [NSString stringWithFormat:@"Registering to Push Center Failed. Error Code:%d",code];
         
         
         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
         [alert show];
         */
        
    }
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection==Connection) {
        [webData setLength:0];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection==Connection) {
        
        //NSString *msg = [NSString stringWithFormat:@"Received Data:%@",data];
        
        // NSLog(@"data=%@",[data description]);
        
    }
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    /*
     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"can not Connect to Server" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
     [alert show];
     */
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    NSError *err;
    //    NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:&err];
    //
    /*
     NSString *msg = [NSString stringWithFormat:@"Status = %@",[[arr objectAtIndex:0] objectForKey:@"status"] ];
     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
     [alert show];
     */
}

@end
