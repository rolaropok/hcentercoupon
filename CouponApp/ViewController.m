//
//  ViewController.m
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "CouponInfo.h"
#import "AMPActivityIndicator.h"
#import "ThumbViewController.h"
#import "UIImageView+WebCache.h"

#import "CouponManager.h"

@interface ViewController ()
{
    
    NSURLConnection *thumbConnection, *loadingConnection;
    NSMutableData *webData,*webData2;
    UIView *Parentview;
    AMPActivityIndicator* progressView;
    NSTimeInterval startTime,endTime;
    CouponManager *couponManager;
}
@end

@implementation ViewController

@synthesize startButton;
@synthesize bannerImage;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;
    
    couponManager = [CouponManager sharedManager];
    
    [bannerImage setImageWithURL:[couponManager getBannerUrl ] placeholderImage:nil options:SDWebImageCacheMemoryOnly | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
    }];
    
    
    //call function that loads initial 6 coupons.
    [startButton setHidden:YES];
    [self loadCoupons];
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark  get cached coupons.

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void) loadCouponThumbs
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    
    
    [self showLoader];
    
    //https://toysruscoupon.nethost.co.il/webservices/index.php?action=getCoupan&coupan=Yes&device_id=dviceid123458&page=1items=2
    
    //return;
    startTime =[[NSDate date] timeIntervalSince1970];
    NSLog(@"Start Time: 0 ");
    
    BOOL CheckUrl=[self isValidURL:[NSURL URLWithString:Main_Count_Url]];
    
    NSString  *urlstring = Main_Thumb_Url;
    if (CheckUrl==YES)
    {
        
        endTime =[[NSDate date] timeIntervalSince1970];
        //NSLog(@"Check URL Duration:%f",endTime - startTime);
        startTime = endTime;
        
        
        //NSLog(@" URL TYPE 1");
        NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *first_name = @"Yes";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *category = @"0";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:category] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        endTime =[[NSDate date] timeIntervalSince1970];
        //NSLog(@"Init Body Duration:%f",endTime - startTime);
        startTime = endTime;
        
        thumbConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        if(thumbConnection)
        {
            webData = [[NSMutableData alloc]init];
        }
        
        endTime =[[NSDate date] timeIntervalSince1970];
        //NSLog(@"Connection Made Duration:%f",endTime - startTime);
        startTime = endTime;
    }
    else{
        [self showAlert];
    }
}

-(void)loadCoupons
{
    
    //    items = 5;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Coupon_Url;
    
    [self showLoader];
    
    NSLog(@"calling RefreshCoupons");
    
    //https://toysruscoupon.nethost.co.il/webservices/index.php?action=getCoupan&coupan=Yes&device_id=dviceid123458&page=1&items=2
    
    NSString* couponCountURL = [Main_Count_Url stringByAppendingString:@"&category=0"];
    
    BOOL CheckUrl=[self isValidURL:[NSURL URLWithString:couponCountURL]];
    
    if (CheckUrl==YES) {
        NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *first_name = @"Yes";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
        NSString *deviceId=[[[[num description]
                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                             stringByReplacingOccurrencesOfString: @">" withString: @""]
                            stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        if (deviceId==nil) {
            deviceId=@"ae32877r840kg08967";
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:deviceId] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"%d",0]] dataUsingEncoding:NSUTF8StringEncoding]];
        //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        //NSLog(@"Total Page Number = %d",0);
        
        NSString *page=[NSString stringWithFormat:@"%d",0];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[page dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *itemcount = [NSString stringWithFormat:@"%ld",(long)couponManager.totalCoupons];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"items\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[itemcount dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        loadingConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        NSLog(@"Refresh- URL%@",[request URL]);
        if(loadingConnection)
        {
            webData2 = [[NSMutableData alloc]init];
        }
        
    }
}

-(void) showAlert
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"can not Connect to Server" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)isValidURL:(NSURL*)url
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    
    if(err==nil && [res statusCode]==200)
    {
        
        
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        
        if ([[url absoluteString] rangeOfString:@"category=0"].location != NSNotFound) {
            NSString *count1 = (NSString*)[[arr objectAtIndex:0] objectForKey:@"count"];
            couponManager.totalCoupons = count1.integerValue;
        }
        else
        {
            
            
            NSString *count1 = (NSString*)[[arr objectAtIndex:0] objectForKey:@"count"];
            NSString *count2 = (NSString*)[[arr objectAtIndex:1] objectForKey:@"count"];
            NSString *count3 = (NSString*)[[arr objectAtIndex:2] objectForKey:@"count"];
            NSString *count4 = (NSString*)[[arr objectAtIndex:3] objectForKey:@"count"];
            NSString *count5 = (NSString*)[[arr objectAtIndex:4] objectForKey:@"count"];
            //NSLog(@"count=%@",count);
            couponManager.cat1Size = count1.integerValue;
            couponManager.cat2Size = count2.integerValue;
            couponManager.cat3Size = count3.integerValue;
            couponManager.cat4Size = count4.integerValue;
            couponManager.cat5Size = count5.integerValue;
            
        }
        
        return true;
    }
    else
        return  false;
    
}


#pragma mark - Start btn method

-(IBAction)StartBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"Home" sender:self];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    //  NSLog(@"response code %ld",(long)[response statusCode]);
    
    if (connection==thumbConnection) {
        [webData setLength:0];
    }else if (connection==loadingConnection) {
        [webData2 setLength:0];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection==thumbConnection) {
        
        endTime =[[NSDate date] timeIntervalSince1970];
        //NSLog(@"Did Receive Data Duration:%f",endTime - startTime);
        startTime = endTime;
        //NSLog(@"WebData:%@",[data description]);
        
        [webData appendData:data];
    }else if (connection==loadingConnection) {
        
        endTime =[[NSDate date] timeIntervalSince1970];
        //NSLog(@"Did Receive Data Duration:%f",endTime - startTime);
        startTime = endTime;
        //NSLog(@"WebData:%@",[data description]);
        
        [webData2 appendData:data];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self showAlert];
    [self hideLoader];
    //  isReloading = NO ;
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    endTime =[[NSDate date] timeIntervalSince1970];
    startTime = endTime;
    
    
    // isReloading = NO ;
    NSError *err;
    //    if (connection==thumbConnection) {
    //            NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:&err];
    //                if (arr.count>0) {
    //
    //            if ([[arr objectAtIndex:0]objectForKey:@"status"]) {
    //                [self hideLoader];
    //
    //            }else{
    //
    //                for (int i=0; i<arr.count; i++) {
    //
    //                    NSDictionary *dic=[arr objectAtIndex:i];
    //                    endTime =[[NSDate date] timeIntervalSince1970];
    //                    //NSLog(@"Before Load Image %d Duration:%f",i,endTime - startTime);
    //                    startTime = endTime;
    //                    CouponThumbInfo * thumb = [[CouponThumbInfo alloc] init];
    //                    thumb.ID=[dic objectForKey:@"id"];
    //                    thumb.C_Category=[dic objectForKey:@"c_category"];
    //                    thumb.C_ThumbImage=[dic objectForKey:@"c_thumb_image"];
    //                }
    //                [self hideLoader];
    //                            }
    //
    //        }else{
    //            [self hideLoader];
    //        }
    //    }
    
    if(connection == loadingConnection)
    {
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData2 options:kNilOptions error:&err];
        if (arr.count>0) {
            
            if ([[arr objectAtIndex:0]objectForKey:@"status"]) {
                [self hideLoader];
            }else{
                [couponManager parseCoupons:arr];
                [self hideLoader];
            }
        }else{
            [self hideLoader];
        }
    }
    [self enableStartButton];
}


-(UIImage*) mergeImageWith:(UIImage*)couponImg
{
    UIImage *bgImg = [UIImage imageNamed:@"imgbg.png"];
    
    if (couponImg == nil) {
        return  bgImg;
    }
    //couponImg = [UIImage imageNamed:@"4027.jpg"];
    UIGraphicsBeginImageContext(bgImg.size);
    [bgImg drawInRect:CGRectMake(0, 0, bgImg.size.width, bgImg.size.height)];
    [couponImg drawInRect:CGRectMake((bgImg.size.width - couponImg.size.width)/2, (bgImg.size.height - couponImg.size.height)/2, couponImg.size.width, couponImg.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


-(void)enableStartButton
{
    [startButton setHidden:NO];
}

#pragma mark - custom Activityindicator method view
-(void)showLoader{
    
    Parentview=[[UIView alloc]initWithFrame:CGRectMake(90,400, 150,50)];
    Parentview.backgroundColor=[UIColor clearColor];
    Parentview.layer.cornerRadius=2;
    Parentview.layer.borderWidth=1;
    Parentview.layer.borderColor=[UIColor clearColor].CGColor;
    Parentview.layer.masksToBounds=YES;
    
    progressView  = [[AMPActivityIndicator alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
    progressView.backgroundColor =[UIColor clearColor];
    progressView.opaque = YES;
    [progressView setBarColor:[UIColor whiteColor ]];
    [progressView setBarHeight:7.0f];
    [progressView setBarWidth:2.0f];
    [progressView setAperture:10.0f];
    [progressView setCenter:CGPointMake(30, 25)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(60,15,70,20);
    headerLabel.text= @"Loading...";
    headerLabel.textAlignment=NSTextAlignmentCenter;
    headerLabel.textColor=[UIColor whiteColor];
    [Parentview addSubview:progressView];
    [Parentview addSubview:headerLabel];
    //[indicatorView addSubview:headerLabel];
    [self.view addSubview:Parentview];
    [progressView startAnimating];
    
    
}
-(void)hideLoader{
    [Parentview removeFromSuperview];
}

@end
