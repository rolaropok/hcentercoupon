//
//  FavoritesViewController.m
//  CouponApp
//
//  Created by parkhya on 8/27/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "FavoritesViewController.h"
#import "HomeCustomCell.h"
#import "HomeViewController.h"
#import "NetworkIndicator.h"
#import "DataBase.h"
#import "ThumbViewController.h"
@interface FavoritesViewController ()
{
    NSURLConnection *functionConnection;
    NSInteger likeTag;
    NSInteger pageIndex;
    
    BOOL scrollDirectionDetermined;
    UIButton *newBut;
}
@property (nonatomic,retain) NSMutableData *webData,*webData1;
@end

@implementation FavoritesViewController
@synthesize FavoritesTableView;
@synthesize webData1,webData;
@synthesize progressView;
@synthesize faviriotBgImageView;
@synthesize FavoritScrollView;
@synthesize FavNextButton;
@synthesize FavPreviousButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)isValidURL:(NSURL*)url
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *res = nil;
    NSError *err = nil;
    [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
    return err==nil && [res statusCode]==200;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    scrollDirectionDetermined=NO;
    favoriteArr=[[NSMutableArray alloc]init];
    favoriteArr=[[DataBase getSharedInstance]receiveAllData];
    
    likeArr=[[NSMutableArray alloc]init];
    
    if (favoriteArr.count>0) {
        [self FavAddSubViewsInScrolleView];
    }else{
        self.FavNextButton.alpha=0;
        self.FavPreviousButton.alpha=0;
    }
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Favorite cell btn methods

-(void)FavoritshareBtnClicked:(id)sender
{
    UIButton *but=(UIButton*)sender;
    
    CouponInfo *info=[favoriteArr objectAtIndex:but.tag];
    
    
    
    SLComposeViewController *controller = [SLComposeViewController
                                           composeViewControllerForServiceType:SLServiceTypeFacebook];
    SLComposeViewControllerCompletionHandler myBlock =
    ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled)
        {
            NSLog(@"Cancelled");
        }
        else
        {
            NSLog(@"Done");
        }
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    controller.completionHandler =myBlock;
    
    NSString *GLink=[NSString stringWithFormat:@"\n https://play.google.com/store/apps/details?id=com.ps.coupon "];
    NSString *ALink=[NSString stringWithFormat:@"\n https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=915787141&mt=8 "];
    
    NSString *AllStr=[NSString stringWithFormat:@" להורדה למכשירי   Androidלחצו כאן: %@ \n \n להורדה למכשירי iPhone לחצו כאן: %@ ",GLink,ALink];
    
    NSString *textLink1=@"רוצים גם אתם ליהנות מהקופונים השווים בישראל?\n";
    NSString *text2=@"הורידו את אפליקציית טויס אר אס! \n ";
    
    
    
    //Adding the Text to the facebook post value from iOS
    [controller setInitialText:[NSString stringWithFormat:@"%@ %@ %@ ",textLink1,text2,AllStr]];
    //Adding the URL to the facebook post value from iOS
    
    //[controller addURL:[NSURL URLWithString:info.C_Image]];
    
    [controller addImage:[self loadImage:info.C_sImageUrl]];
    
    //Adding the Text to the facebook post value from iOS
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)favouritSendBtnClicked:(id)sender
{
    UIButton *but=(UIButton*)sender;
    
    CouponInfo *info=[favoriteArr objectAtIndex:but.tag];
    
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    UIImage *AnImage=[self loadImage:info.C_sImageUrl];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        //        displayLinkSupported = TRUE;
    {
        
        NSString *GLink=[NSString stringWithFormat:@"\n https://play.google.com/store/apps/details?id=com.ps.coupon "];
        NSString *ALink=[NSString stringWithFormat:@"\n https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=915787141&mt=8 "];
        
        NSString *AllStr=[NSString stringWithFormat:@" להורדה למכשירי   Androidלחצו כאן: %@ \n \n להורדה למכשירי iPhone לחצו כאן: %@ ",GLink,ALink];
        
        NSString *textLink1=@"רוצים גם אתם ליהנות מהקופונים השווים בישראל?\n";
        NSString *text2=@"הורידו את אפליקציית טויס אר אס! \n ";
        
        
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:textLink1,text2,AllStr,AnImage, nil] applicationActivities:nil];
        
        NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeMessage];
        activityVC.excludedActivityTypes = excludeActivities;
        
        [self presentViewController:activityVC animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"share information" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
    
}

-(void)favouritLikeBtnClicked:(id)sender
{
    [NetworkIndicator startLoading];
    
    UIButton *but=(UIButton*)sender;
    likeTag=but.tag;
    CouponInfo *info=[favoriteArr objectAtIndex:but.tag];
    // NSString *urlstr=LIKE_URL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Like_Url;
    
    // [self showLoader];
    
    BOOL CheckUrl=YES;//[self isValidURL:[NSURL URLWithString:urlstring]];
    
    if (CheckUrl==YES) {
        NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *first_name = @"Yes";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"like\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *CouponId = info.C_ID;
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:CouponId] dataUsingEncoding:NSUTF8StringEncoding]];
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
        
        [request setHTTPBody:body];
        functionConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        if(functionConnection)
        {
            webData1 = [[NSMutableData alloc]init];
        }
        else
        {
            
            
        }
    }else{
        urlstring=LIKE_URL;
        NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *first_name = @"Yes";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"like\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *CouponId = info.C_ID;
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:CouponId] dataUsingEncoding:NSUTF8StringEncoding]];
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
        
        [request setHTTPBody:body];
        functionConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        if(functionConnection)
        {
            webData1 = [[NSMutableData alloc]init];
        }
        else
        {
            
            
        }
    }
}

-(void)favouritRemoveFromFavoritBtnClicked:(id)sender
{
    [self showLoader];
    //
    UIButton *But=(UIButton*)sender;
    newBut=(UIButton*)sender;
    //
    CouponInfo *info=[favoriteArr objectAtIndex:But.tag];
    //
    pageIndex=But.tag;
    
    //dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self removeImage:info];
    
    // });
    
}

#pragma mark -remove image from document directory

- (void)removeImage:(CouponInfo *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //  Append the filename and get the full image path
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName.C_Image];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        // UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        // [removeSuccessFulAlert show];
        
        BOOL delete=[[DataBase getSharedInstance]deleteDataFromFavoritesList:fileName];
        
        if (delete==YES) {
            favoriteArr=[[NSMutableArray alloc]init];
            favoriteArr=[[DataBase getSharedInstance]receiveAllData];
            [self.FavoritScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self FavAddSubViewsInScrolleView];
        }
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    [self hideLoader];
    
    // [self FavnextButClicked:newBut];
}

-(void)AfterDeleteCall
{
    pageIndex=0;
    //for (int i=0; i<favoriteArr.count; i++) {
    if (favoriteArr.count>0) {
    }else{
        // [CView removeFromSuperview];
    }
    
    if (favoriteArr.count<=1) {
        FavNextButton.alpha=0;
        FavPreviousButton.alpha=0;
    }
    
}



#pragma mark - retrive Image method

- (UIImage *)loadImage:(NSString *)filePath  {
    return [UIImage imageWithContentsOfFile:filePath];
}


#pragma mark - botum tab's methods

-(IBAction)FavoritesPolicyBtnClicked:(id)sender;
{
    [self performSegueWithIdentifier:@"FavoritesPolicy" sender:self];
}
-(IBAction)FavoritesStoreLocatorBtnClicked:(id)sender;
{
    [self performSegueWithIdentifier:@"FavoritesMapView" sender:self];
}
-(IBAction)FavoritesShopOnlineBtnClicked:(id)sender;
{
    [self performSegueWithIdentifier:@"FavoritesWebView" sender:self];
}



#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if(connection==functionConnection)
    {
        [webData1 setLength:0];
        
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection==functionConnection)
    {
        [webData1 appendData:data];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"can not Connect to Server" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    [self hideLoader];
    //  isReloading = NO ;
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (connection==functionConnection) {
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData1 options:kNilOptions error:nil];
        
        [NetworkIndicator stopLoading];
        
        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic=[arr objectAtIndex:0];
            if ([[dic objectForKey:@"status"] isEqualToString:@"success"] ) {
                NSLog(@"# Fav-Do Like Succeed");
                [likeArr addObject:[dic objectForKey:@"coupan_id"]];
                [self FavNextpage];
                
            }else if ([[dic objectForKey:@"status"] isEqualToString:@"failure"])
            {
                NSLog(@"# Fav-Do Like Failed");
                
            }
        }
    }
}


#pragma mark - custom Activityindicator method view

-(void)showLoader{
    Parentview=[[UIView alloc]initWithFrame:CGRectMake(90,250, 150,60)];
    Parentview.backgroundColor=[UIColor darkGrayColor];
    Parentview.layer.cornerRadius=2;
    Parentview.layer.borderWidth=1;
    Parentview.layer.borderColor=[UIColor colorWithWhite:0.8 alpha:1].CGColor;
    Parentview.layer.masksToBounds=YES;
    //        indicatorView=[[UIView alloc]initWithFrame:CGRectMake(60, 250, 200, 100)];
    //    indicatorView.backgroundColor=[UIColor whiteColor];
    //    indicatorView.layer.cornerRadius=8;
    //    indicatorView.layer.masksToBounds=YES;
    //    [Parentview addSubview:indicatorView];
    
    progressView  = [[AMPActivityIndicator alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
    progressView.backgroundColor =[UIColor clearColor];
    progressView.opaque = YES;
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarHeight:7.0f];
    [progressView setBarWidth:2.0f];
    [progressView setAperture:10.0f];
    [progressView setCenter:CGPointMake(30, 25)];
    
    
    //  [Parentview addSubview:progressView];
    // [self.view addSubview:parantView];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(50,15,90,30);
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
    //    [self.view addSubview:faviriotBgImageView];
    //    [self.view addSubview:FavoritesTableView];
}

#pragma mark - custom Activityindicator 2 method view

-(void)showLoader2{
    animateView=[[UIView alloc]initWithFrame:CGRectMake(35,250, 250,60)];
    animateView.backgroundColor=[UIColor darkGrayColor];
    animateView.layer.cornerRadius=2;
    animateView.layer.borderWidth=1;
    animateView.layer.borderColor=[UIColor colorWithWhite:0.8 alpha:1].CGColor;
    animateView.layer.masksToBounds=YES;
    //        indicatorView=[[UIView alloc]initWithFrame:CGRectMake(60, 250, 200, 100)];
    //    indicatorView.backgroundColor=[UIColor whiteColor];
    //    indicatorView.layer.cornerRadius=8;
    //    indicatorView.layer.masksToBounds=YES;
    //    [Parentview addSubview:indicatorView];
    progressView  = [[AMPActivityIndicator alloc] initWithFrame:CGRectMake(0,0, 0, 0)];
    progressView.backgroundColor =[UIColor clearColor];
    progressView.opaque = YES;
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarColor:[UIColor grayColor]];
    [progressView setBarHeight:7.0f];
    [progressView setBarWidth:2.0f];
    [progressView setAperture:10.0f];
    [progressView setCenter:CGPointMake(30, 25)];
    
    
    //  [Parentview addSubview:progressView];
    // [self.view addSubview:parantView];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(60,15,90,30);
    headerLabel.text= @"Wait...";
    headerLabel.textAlignment=NSTextAlignmentCenter;
    headerLabel.textColor=[UIColor whiteColor];
    [animateView addSubview:progressView];
    [animateView addSubview:headerLabel];
    //[indicatorView addSubview:headerLabel];
    [self.view addSubview:animateView];
    [progressView startAnimating];
}
-(void)hideLoader2{
    //[progressView removeFromSuperview];
    [animateView removeFromSuperview];
    // [self.view addSubview:FavoritesTableView];
}

#pragma mark - add views in scrollview
-(void)FavAddSubViewsInScrolleView
{
    pageIndex=0;
    int lak=0;
    
    
    for (int i=0; i<favoriteArr.count; i++) {
        
        CouponInfo *coupIfo=[favoriteArr objectAtIndex:i];
        
        
        UIView* CView=[[UIView alloc]initWithFrame:CGRectMake(i*320, 0, 320, 421)];
        [self.FavoritScrollView addSubview:CView];
        
        
        
        UIImageView* CouponImageView=[[UIImageView alloc]initWithFrame:CGRectMake(30,40,260,255)];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //  Append the filename and get the full image path
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:coupIfo.C_Image];
        
        CouponImageView.image=[self loadImage:savedImagePath];
        
        [CView addSubview:CouponImageView];
        
        UIButton *homePevious=[UIButton buttonWithType:UIButtonTypeCustom];
        homePevious.frame=CGRectMake(0, 145, 25, 27);
        [homePevious setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [CView addSubview:homePevious];
        homePevious.tag=i;
        [homePevious addTarget:self action:@selector(FavPreviousButClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *HomeNext=[UIButton buttonWithType:UIButtonTypeCustom];
        HomeNext.frame=CGRectMake(295, 145, 25, 27);
        [HomeNext setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        [CView addSubview:HomeNext];
        [HomeNext addTarget:self action:@selector(FavnextButClicked:) forControlEvents:UIControlEventTouchUpInside];
        HomeNext.tag=i;
        
        if (favoriteArr.count==1) {
            homePevious.alpha=0;
            HomeNext.alpha=0;
        }else if (i==0){
            homePevious.alpha=0;
        }else if (i==favoriteArr.count-1){
            HomeNext.alpha=0;
        }
        
        
        UILabel *LikeLab=[[UILabel alloc]initWithFrame:CGRectMake(242, 6, 79, 21)];
        LikeLab.text=[NSString stringWithFormat:@"%@ likes",coupIfo.Total_Like];
        LikeLab.font=[UIFont systemFontOfSize:16];
        LikeLab.textColor=[UIColor whiteColor];
        [CView addSubview:LikeLab];
        
        if (likeArr.count>0) {
            for (int j=0; j<likeArr.count; j++) {
                if ([[likeArr objectAtIndex:j] isEqualToString:coupIfo.C_ID]) {
                    int liked=[coupIfo.Total_Like intValue];
                    liked=liked+1;
                    LikeLab.text= [NSString stringWithFormat:@"%d likes",liked];
                }
            }
            lak=1;
        }
        
        UIImageView *ThumbImage=[[UIImageView alloc]initWithFrame:CGRectMake(220, 6, 20, 20)];
        ThumbImage.image=[UIImage imageNamed:@"likeicon.png"];
        [CView addSubview:ThumbImage];
        
        
        
        UILabel*  CouponNoLab=[[UILabel alloc]initWithFrame:CGRectMake(0,311,140,21)];
        CouponNoLab.text=coupIfo.CouponNumber;
        CouponNoLab.textColor=[UIColor whiteColor];
        CouponNoLab.font=[UIFont systemFontOfSize:14];
        CouponNoLab.shadowColor=[UIColor whiteColor];
        [CView addSubview:CouponNoLab];
        
        UILabel*  CouponNo=[[UILabel alloc]initWithFrame:CGRectMake(30,6,70,21)];
        CouponNo.text=[NSString stringWithFormat:@"%d/%d",i+1,favoriteArr.count];
        CouponNo.textColor=[UIColor whiteColor];
        CouponNo.font=[UIFont systemFontOfSize:18];
        CouponNo.shadowColor=[UIColor whiteColor];
        [CView addSubview:CouponNo];
        
        
        UITextView* descText=[[UITextView alloc]initWithFrame:CGRectMake(120, 305, 200, 80)];
        descText.text=coupIfo.C_Text;
        descText.textColor=[UIColor whiteColor];
        descText.backgroundColor=[UIColor clearColor];
        descText.font=[UIFont systemFontOfSize:12];
        descText.textAlignment=NSTextAlignmentRight;
        descText.editable=NO;
        descText.userInteractionEnabled=NO;
        [CView addSubview:descText];
        
        
        UIButton* shareButton=[UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame=CGRectMake(5,390,75,35) ;
        [shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        [CView addSubview:shareButton];
        shareButton.tag=i;
        [shareButton addTarget:self action:@selector(FavoritshareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton*  sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame=CGRectMake(82,390,75,35) ;
        [sendButton setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
        [CView addSubview:sendButton];
        [sendButton addTarget:self action:@selector(favouritSendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        sendButton.tag=i;
        
        UIButton*  LikeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        LikeButton.frame=CGRectMake(159,390,75,35) ;
        [LikeButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [CView addSubview:LikeButton];
        [LikeButton addTarget:self action:@selector(favouritLikeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        LikeButton.tag=i;
        
        UIButton*  AddToFavButton=[UIButton buttonWithType:UIButtonTypeCustom];
        AddToFavButton.frame=CGRectMake(236,390,75,35) ;
        [AddToFavButton setImage:[UIImage imageNamed:@"removefav.png"] forState:UIControlStateNormal];
        [CView addSubview:AddToFavButton];
        [AddToFavButton addTarget:self action:@selector(favouritRemoveFromFavoritBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        AddToFavButton.tag=i;
        
        
        if ([AppDelegate sharedInstance].DeviceHight==480)
        {
            
            CView.frame=CGRectMake(i*320, 0, 320, 365);
            
            LikeLab.frame=CGRectMake(231, 2, 80, 20);
            ThumbImage.frame=CGRectMake(209, 2, 20, 20);
            CouponNo.frame = CGRectMake(30, 2, 70, 20);
            
            
            CouponImageView.frame=CGRectMake(40, 25, 240, 240);
            
            CouponNoLab.frame=CGRectMake(4,270,140,21);
            descText.frame=CGRectMake(120, 265, 200, 64);
            
            
            shareButton.frame=CGRectMake(5,330,75,35) ;
            sendButton.frame=CGRectMake(82,330,75,35) ;
            LikeButton.frame=CGRectMake(159,330,75,35) ;
            AddToFavButton.frame=CGRectMake(236,330,75,35) ;
            
            homePevious.frame=CGRectMake(10, 115, 25, 27);
            HomeNext.frame=CGRectMake(285, 115, 25, 27);
        }
        
    }
    
    self.FavoritScrollView.contentSize=CGSizeMake(320*favoriteArr.count, 421);
    if ([AppDelegate sharedInstance].DeviceHight==480)
    {
        self.FavoritScrollView.contentSize=CGSizeMake(320*favoriteArr.count, 364);
    }
    
    self.FavoritScrollView.scrollEnabled=YES;
    [self hideLoader];
    
}




-(IBAction)FavnextButClicked:(id)sender
{
    CGRect frame;
    if (pageIndex<favoriteArr.count) {
        
        
        frame.origin.x = self.FavoritScrollView.frame.size.width * (pageIndex+1);
        frame.origin.y = 0;
        frame.size = self.FavoritScrollView.frame.size;
        [self.FavoritScrollView scrollRectToVisible:frame animated:YES];
        
        
        
        
        pageIndex++;
        
    }
    
}

-(IBAction)FavPreviousButClicked:(id)sender
{
    CGRect frame;
    if (pageIndex>0) {
        
        frame.origin.x = self.FavoritScrollView.frame.size.width * (pageIndex-1);
        frame.origin.y = 0;
        frame.size = self.FavoritScrollView.frame.size;
        [self.FavoritScrollView scrollRectToVisible:frame animated:YES];
        
        pageIndex--;
        
    }
}



-(void)FavNextpage
{
    
    
    
    
    UILabel *LikeLab = [[self.FavoritScrollView subviews][likeTag] subviews][3];
    CouponInfo * cinfo = [favoriteArr objectAtIndex:likeTag];
    int likes =[cinfo.Total_Like intValue]+1;
    NSLog(@"likeTag = %ld Like=%@",(long)likeTag,LikeLab.text);
    LikeLab.text =[NSString stringWithFormat:@"%d likes",likes];
    
    
    CGRect frame;
    frame.origin.x = self.FavoritScrollView.frame.size.width * likeTag;
    frame.origin.y = 0;
    frame.size = self.FavoritScrollView.frame.size;
    [self.FavoritScrollView scrollRectToVisible:frame animated:YES];
    
    
    
    
}


-(void)LeftGestureForView:(id)sender
{
    UISwipeGestureRecognizer *Swipe=(UISwipeGestureRecognizer*)sender;
    
    if (Swipe.direction==UISwipeGestureRecognizerDirectionLeft) {
        CGRect frame;
        
        
        
        if (pageIndex<favoriteArr.count) {
            
            FavPreviousButton.alpha=1;
            frame.origin.x = self.FavoritScrollView.frame.size.width * (pageIndex+1);
            frame.origin.y = 0;
            frame.size = self.FavoritScrollView.frame.size;
            [self.FavoritScrollView scrollRectToVisible:frame animated:YES];
            
            
            
            
            pageIndex++;
            if (pageIndex==favoriteArr.count-1) {
                FavNextButton.alpha=0;
            }
            if (favoriteArr.count==1) {
                FavNextButton.alpha=0;
                FavPreviousButton.alpha=0;
            }
        }
    }
}

-(void)RightGestureForView:(id)sender
{
    UISwipeGestureRecognizer *Swipe=(UISwipeGestureRecognizer*)sender;
    if (Swipe.direction==UISwipeGestureRecognizerDirectionRight) {
        CGRect frame;
        if (pageIndex>0) {
            FavNextButton.alpha=1;
            
            
            frame.origin.x = self.FavoritScrollView.frame.size.width * (pageIndex-1);
            frame.origin.y = 0;
            frame.size = self.FavoritScrollView.frame.size;
            [self.FavoritScrollView scrollRectToVisible:frame animated:YES];
            
            pageIndex--;
            if (pageIndex==0) {
                FavPreviousButton.alpha=0;
            }
            
            if (favoriteArr.count==1) {
                FavNextButton.alpha=0;
                FavPreviousButton.alpha=0;
            }
            
        }
    }
}

-(IBAction)CrossBtnClicked:(id)sender
{
    
    UIViewController * dest1,*dest2;
    for (UIViewController* viewController in self.navigationController.viewControllers)
    {
        
        if ([viewController isKindOfClass:[HomeViewController class]] )
            dest1 = viewController;
        else if([viewController isKindOfClass:[ThumbViewController class]] )
            dest2 = viewController;
        
    }
    
    if (dest1 != nil)
        [self.navigationController popToViewController:dest1 animated:YES];
    else
        [self.navigationController popToViewController:dest2 animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - scrollview delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /*
     if (!scrollDirectionDetermined) {
     CGFloat pageWidth = self.FavoritScrollView.frame.size.width;
     int page = floor((self.FavoritScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
     pageIndex = page;
     }*/
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)tableView {
    CGFloat pageWidth = self.FavoritScrollView.frame.size.width;
    int page = floor((self.FavoritScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    int totalPages = floor(self.FavoritScrollView.contentSize.width / pageWidth);
    NSLog(@"Page : %d / %d",page,totalPages);
    pageIndex = page;
    
}
//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollDirectionDetermined = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollDirectionDetermined = NO;
}



@end
