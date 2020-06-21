//
//  HomeViewController.m
//  CouponApp
//
//  Created by parkhya on 8/25/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCustomCell.h"
#import "CouponInfo.h"
#import "DataBase.h"
#import "WebSiteViewController.h"
#import "NetworkIndicator.h"
#import "AMPActivityIndicator.h"
#import "UIImageView+WebCache.h"
#import "CouponManager.h"

@interface HomeViewController ()<NSURLConnectionDelegate,UIScrollViewDelegate>
{
    NSURLConnection *functionConnection,*refreshConnection;
    NSMutableArray *likeArr;
    NSInteger likeTag;
    NSInteger pageIndex;
    BOOL scrollDirectionDetermined;
    BOOL isSwaped;
    int offsetx ;
    int imageShownIndex;
    long int status;
    int pageNo;
    NSString* workingURL;
    CouponManager *couponManager;
    UIPanGestureRecognizer *panGesture;

}
@property (nonatomic,retain) NSMutableData *webData1,*webData2;
@end

@implementation HomeViewController
//@synthesize CouponArr;
@synthesize category,startCouponId;
@synthesize webData1,webData2;
@synthesize HomeTableView;
@synthesize progressView;
@synthesize HomeScrollView;
@synthesize PreviousButton,NextButton;
@synthesize BackRedBagView;
@synthesize pageControl;
@synthesize couponCounts;

@synthesize assortedButton,babyButton,boyButton,girlButton,powerCardButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    couponManager = [CouponManager sharedManager];
    
    scrollDirectionDetermined = NO;
    isSwaped = NO;
    
    likeArr=[[NSMutableArray alloc]init];
    
    if (category == 1) {
        couponCounts = couponManager.cat1Size;
    }else if (category == 2) {
        couponCounts = couponManager.cat2Size;
    }else if (category == 3) {
        couponCounts = couponManager.cat3Size;
    }else if (category == 4) {
        couponCounts = couponManager.cat4Size;
    }else if (category == 5) {
        couponCounts = couponManager.cat5Size;
    }
    
    //[self RefreshCoupons:MAX(startCouponId,10)];
    [self addSubViewsInScrolleView];
    
//    HomeScrollView.scrollEnabled = FALSE;
//    UISwipeGestureRecognizer *recognizer =
//    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    recognizer.delaysTouchesBegan = TRUE;
//    [HomeScrollView addGestureRecognizer:recognizer];
//    
//    
//    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//    [HomeScrollView addGestureRecognizer:recognizer];
//    [HomeScrollView delaysContentTouches];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setSelected:category];
}
- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    pageIndex = startCouponId;
    [self moveTo:startCouponId];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#pragma mark - table view delegates methods
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 333;
//}


#pragma mark - home tab btns methods

-(IBAction)FavoritesBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"Favorites" sender:self];
}

-(IBAction)StoreLocatorBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"MapVIew" sender:self];
}

-(IBAction)ShopOnlineBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"ShopOnline" sender:self];
}

-(IBAction)PoliceBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"Policy" sender:self];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    //  NSLog(@"response code %ld",(long)[response statusCode]);
    
    if(connection==functionConnection)
    {
        [webData1 setLength:0];
        
    }
    else if(connection == refreshConnection)
    {
        [webData2 setLength:0];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if(connection==functionConnection)
    {
        [webData1 appendData:data];
    }
    else if(connection == refreshConnection)
    {
        [webData2 appendData:data];
    }
    
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"can not Connect to Server" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    [self hideLoader];
    [NetworkIndicator stopLoading];
    //  isReloading = NO ;
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // isReloading = NO ;
    NSError *err;
    
    if (connection==refreshConnection) {
        
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData2 options:kNilOptions error:&err];
        if (arr.count>0) {
            
            if ([[arr objectAtIndex:0]objectForKey:@"status"]) {
                [self hideLoader];
                
            }else{
                
                [couponManager clearCoupons];
                [couponManager parseCoupons:arr];
                
                [self addSubViewsInScrolleView];
                [self hideLoader];
                [NetworkIndicator stopLoading];
            }
        }else{
            
            [self hideLoader];
            [NetworkIndicator stopLoading];
        }
        
        //[self moveTo:0];
    }
    
    if (connection==functionConnection) {
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData1 options:kNilOptions error:nil];
        
        [NetworkIndicator stopLoading];
        NSLog(@"# Like Button Clicked");
        
        for (int i=0; i<arr.count; i++) {
            NSDictionary *dic=[arr objectAtIndex:0];
            if ([[dic objectForKey:@"status"] isEqualToString:@"success"] ) {
                NSLog(@"# Do Like Succeed");
                [likeArr addObject:[dic objectForKey:@"coupan_id"]];
                [self nextpage];
            }else if ([[dic objectForKey:@"status"] isEqualToString:@"failure"])
            {
                NSLog(@"# Do Like Failed");
            }
        }
    }
}

#pragma mark - add views in scrollview
-(void)addSubViewsInScrolleView
{
    //pageIndex=0;
    for (UIView *v in self.HomeScrollView.subviews) {
        [v removeFromSuperview];
    }
    
    NSMutableArray *CouponArr = [self getCurrentCoupons];
    
    for (int i=0; i<CouponArr.count; i++) {
        // if (CouponArr.count>0) {
        CouponInfo *coupIfo=[CouponArr objectAtIndex:i];
        UIView* CView=[[UIView alloc]initWithFrame:CGRectMake(i*320, 0, 320, 391)];
        [CView setTag:i];
        [self.HomeScrollView addSubview:CView];
        
        UIImageView* CouponImageView=[[UIImageView alloc]initWithFrame:CGRectMake(45,40,230,225)];
        CouponImageView.tag = 100+i;
        
        [CouponImageView setImageWithURL:[NSURL URLWithString:coupIfo.C_Image] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            coupIfo.CouponImage = [self mergeThumbImageWith:image];
        }];
        
        [CView addSubview:CouponImageView];
        
        UIButton *homePevious=[UIButton buttonWithType:UIButtonTypeCustom];
        homePevious.frame=CGRectMake(0, 130, 25, 27);
        [homePevious setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [CView addSubview:homePevious];
        homePevious.tag=i;
        [homePevious addTarget:self action:@selector(PreviousButClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *HomeNext=[UIButton buttonWithType:UIButtonTypeCustom];
        HomeNext.frame=CGRectMake(295, 130, 25, 27);
        [HomeNext setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        [CView addSubview:HomeNext];
        [HomeNext addTarget:self action:@selector(nextButClicked:) forControlEvents:UIControlEventTouchUpInside];
        HomeNext.tag=i;
        
        if (CouponArr.count==1) {
            homePevious.alpha=0;
            HomeNext.alpha=0;
        }else if (i==0){
            homePevious.alpha=0;
        }else if (i==self.couponCounts-1){
            HomeNext.alpha=0;
        }
        
                UILabel *LikeLab=[[UILabel alloc]initWithFrame:CGRectMake(222, 6, 99, 21)];
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
                    
                }else
                    LikeLab.text=[NSString stringWithFormat:@"%@ likes",coupIfo.Total_Like];
        
        
              UIImageView *ThumbImage=[[UIImageView alloc]initWithFrame:CGRectMake(200, 6, 20, 20)];
                ThumbImage.image=[UIImage imageNamed:@"likeicon.png"];
                [CView addSubview:ThumbImage];
        
        
        UILabel*  CouponNoLab=[[UILabel alloc]initWithFrame:CGRectMake(4,281,140,21)];
        CouponNoLab.text=coupIfo.CouponNumber;
        CouponNoLab.textColor=[UIColor whiteColor];
        CouponNoLab.font=[UIFont systemFontOfSize:14];
        CouponNoLab.shadowColor=[UIColor whiteColor];
        [CView addSubview:CouponNoLab];
        
        UILabel*  CouponNo=[[UILabel alloc]initWithFrame:CGRectMake(30,6,70,21)];
        CouponNo.text=[NSString stringWithFormat:@"%d/%ld",i+1,(long)self.couponCounts];
        CouponNo.textColor=[UIColor whiteColor];
        CouponNo.font=[UIFont systemFontOfSize:18];
        CouponNo.shadowColor=[UIColor whiteColor];
        [CView addSubview:CouponNo];
        
        
        UITextView* descText=[[UITextView alloc]initWithFrame:CGRectMake(120, 275, 200, 80)];
        
        descText.text=coupIfo.C_Text;
        descText.textColor=[UIColor whiteColor];
        descText.backgroundColor=[UIColor clearColor];
        descText.font=[UIFont systemFontOfSize:12];
        descText.textAlignment=NSTextAlignmentRight;
        descText.editable=NO;
        descText.userInteractionEnabled=NO;
        [CView addSubview:descText];
        //NSLog(@"5");
        
        int subButtonWidth = 75;
        
        
        UIButton* shareButton=[UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame=CGRectMake(5,360,subButtonWidth,35) ;
        [shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        [CView addSubview:shareButton];
        shareButton.tag=i;
        [shareButton addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton*  sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame=CGRectMake(82,360,subButtonWidth,35) ;
        [sendButton setImage:[UIImage imageNamed:@"send.png"] forState:UIControlStateNormal];
        [CView addSubview:sendButton];
        [sendButton addTarget:self action:@selector(SendBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        sendButton.tag=i;
        
        UIButton*  LikeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        LikeButton.frame=CGRectMake(159,360,subButtonWidth,35) ;
        [LikeButton setImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
        [CView addSubview:LikeButton];
        [LikeButton addTarget:self action:@selector(LikeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        LikeButton.tag=i;
        
        UIButton*  AddToFavButton=[UIButton buttonWithType:UIButtonTypeCustom];
        AddToFavButton.frame=CGRectMake(236,360,subButtonWidth,35) ;
        [AddToFavButton setImage:[UIImage imageNamed:@"addtofav.png"] forState:UIControlStateNormal];
        [CView addSubview:AddToFavButton];
        [AddToFavButton addTarget:self action:@selector(addToFavoritBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        AddToFavButton.tag=i;
        
        
        
        //NSLog(@"6");
        if ([AppDelegate sharedInstance].DeviceHight==480)
        {
            CView.frame=CGRectMake(i*320, 0, 320, 340);
            
                        LikeLab.frame=CGRectMake(231, 0, 80, 20);
                        ThumbImage.frame=CGRectMake(209, 0, 20, 20);
            
            CouponImageView.frame=CGRectMake(60, 30, 200, 190);
            CouponNoLab.frame=CGRectMake(4,230,140,21);
            descText.frame=CGRectMake(120, 225, 200, 64);
 

            shareButton.frame=CGRectMake(5,295,subButtonWidth,35) ;
            sendButton.frame=CGRectMake(82,295,subButtonWidth,35) ;
            LikeButton.frame=CGRectMake(159,295,subButtonWidth,35) ;
            AddToFavButton.frame=CGRectMake(236,295,subButtonWidth,35) ;
            
            
            homePevious.frame=CGRectMake(0, 100, 25, 27);
            HomeNext.frame=CGRectMake(295, 100, 25, 27);
        }
    }
    
    if (CouponArr.count==1) {
        PreviousButton.alpha=0;
        NextButton.alpha=0;
    }
    imageShownIndex = 4;
    self.HomeScrollView.contentSize=CGSizeMake(320*CouponArr.count, 391);
    
    if ([AppDelegate sharedInstance].DeviceHight==480)
    {
        self.HomeScrollView.contentSize=CGSizeMake(320*CouponArr.count, 330);
    }
    self.HomeScrollView.scrollEnabled=YES;
    
    [self moveTo:startCouponId];
    
}

- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self PreviousButClicked:nil];
    }
    else
    {
        [self nextButClicked:nil];
    }
}




-(IBAction)nextButClicked:(id)sender
{
    NSInteger size= [self getCurrentCoupons].count;
    
    CGRect frame;
    if (pageIndex<size-1) {
        frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex+1);
        frame.origin.y = 0;
        frame.size = self.HomeScrollView.frame.size;
        [self.HomeScrollView scrollRectToVisible:frame animated:YES];
        
        pageIndex++;
        startCouponId = pageIndex;
        
        if((pageIndex+3 >= imageShownIndex))
            [self SwapCoupnCallWebservice];
        
    }
    startCouponId = pageIndex;
}

-(IBAction)PreviousButClicked:(id)sender
{
    
    CGRect frame;
    if (pageIndex>0) {
        frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex-1);
        frame.origin.y = 0;
        frame.size = self.HomeScrollView.frame.size;
        [self.HomeScrollView scrollRectToVisible:frame animated:YES];
        pageIndex--;
        
        if (pageIndex==0) {
            // PreviousButton.alpha=0;
        }
        
    }
    startCouponId = pageIndex;
}


-(NSMutableArray*) getCurrentCoupons
{
    
    switch (category) {
        case 1:
            return couponManager.cat1;
        case 2:
            return couponManager.cat2;
        case 3:
            return couponManager.cat3;
        case 4:
            return couponManager.cat4;
        case 5:
            return couponManager.cat5;
            
        default:
            return couponManager.cat1;
    }
}
-(void) moveTo:(NSInteger) page
{
    
    pageIndex = page;
    CGRect frame;
    int width = self.HomeScrollView.frame.size.width;
    
    frame.origin.x = width * page;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:NO];
}

- (IBAction)clickAssortedCategory:(id)sender {
    
    //    if (category == 1)
    //        return;
    //    category = 1;
    //    couponCounts = couponManager.cat1Size;
    //    [self addSubViewsInScrolleView];
    //    [self moveTo:0];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[@"1"] forKeys:@[@"category"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCategory" object:nil userInfo:userInfo];    [self backButtonClicked:nil];
    
    
}

- (IBAction)clickBabyCategory:(id)sender {
    //    if (category == 2)
    //        return;
    //    category = 2;
    //    couponCounts = couponManager.cat2Size;
    //
    //    [self addSubViewsInScrolleView];
    //    [self moveTo:0];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[@"2"] forKeys:@[@"category"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCategory" object:nil userInfo:userInfo];
    
    [self backButtonClicked:nil];
    
    
}

- (IBAction)clickBoyCategory:(id)sender {
    //    if (category == 3 )
    //        return;
    //    category = 3;
    //    couponCounts = couponManager.cat3Size;
    //    [self addSubViewsInScrolleView];
    //    [self moveTo:0];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[@"3"] forKeys:@[@"category"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCategory" object:nil userInfo:userInfo];
    [self backButtonClicked:nil];
}

- (IBAction)clickGirlCategory:(id)sender {
    //    if (category == 4 )
    //        return;
    //    category = 4;
    //    couponCounts = couponManager.cat4Size;
    //    [self addSubViewsInScrolleView];
    //    [self moveTo:0];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[@"4"] forKeys:@[@"category"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCategory" object:nil userInfo:userInfo];    [self backButtonClicked:nil];
    
}

- (IBAction)clickPowerCardCategory:(id)sender {
    //    if (category == 5 )
    //        return;
    //    category = 5;
    //    couponCounts = couponManager.cat5Size;
    //
    //    [self addSubViewsInScrolleView];
    //    [self moveTo:0];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[@"5"] forKeys:@[@"category"]];    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectCategory" object:nil userInfo:userInfo];
    [self backButtonClicked:nil];
    
}

-(void) setSelected:(NSInteger) cat
{
    [assortedButton setSelected:NO];
    [boyButton setSelected:NO];
    [babyButton setSelected:NO];
    [girlButton setSelected:NO];
    [powerCardButton setSelected:NO];
    
    if (cat == 1)
        [assortedButton setSelected:YES];
    else if (cat == 2)
        [babyButton setSelected:YES];
    else if (cat == 3)
        [boyButton setSelected:YES];
    else if (cat == 4)
        [girlButton setSelected:YES];
    else if (cat == 5)
        [powerCardButton setSelected:YES];
}

-(void) refreshHomeScrollView:(NSInteger) pos
{
    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * pos;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:YES];
}

-(void)nextpage
{
    NSMutableArray *CouponArr = [self getCurrentCoupons];
    
    UILabel *LikeLab = [[self.HomeScrollView subviews][likeTag] subviews][3];
    CouponInfo * cinfo = [CouponArr objectAtIndex:likeTag];
    int likes =[cinfo.Total_Like intValue]+1;
    NSLog(@"likeTag = %ld Like=%@",(long)likeTag,LikeLab.text);
    LikeLab.text =[NSString stringWithFormat:@"%d likes",likes];
    
    [self refreshHomeScrollView:likeTag];
    
    
}

-(void)LeftGestureForView:(id)sender
{
    NSInteger size = [self getCurrentCoupons].count;
    UISwipeGestureRecognizer *Swipe=(UISwipeGestureRecognizer*)sender;
    CGRect frame;
    if (Swipe.direction==UISwipeGestureRecognizerDirectionLeft) {
        if (pageIndex<size) {
            
            PreviousButton.alpha=1;
            if (size==1) {
                self.NextButton.alpha=0;
                self.PreviousButton.alpha=0;
            }
            
            frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex+1);
            frame.origin.y = 0;
            frame.size = self.HomeScrollView.frame.size;
            [self.HomeScrollView scrollRectToVisible:frame animated:YES];
            pageIndex++;
            startCouponId = pageIndex;
            if (pageIndex==size-1) {
                NextButton.alpha=0;
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
            
            NSInteger size = [self getCurrentCoupons].count;
            NextButton.alpha=1;
            if (size==1) {
                self.NextButton.alpha=0;
                self.PreviousButton.alpha=0;
            }
            frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex-1);
            frame.origin.y = 0;
            frame.size = self.HomeScrollView.frame.size;
            [self.HomeScrollView scrollRectToVisible:frame animated:YES];
            pageIndex--;
            
            if (pageIndex==0) {
                PreviousButton.alpha=0;
            }
            
        }
    }
}

#pragma mark - reload cell method

-(void)reloadSingleCell
{
    [self hideLoader2];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:likeTag inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [HomeTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Homecell btn methods

-(void)shareBtnClicked:(id)sender
{
    UIButton *but=(UIButton*)sender;
    
    NSMutableArray *CouponArr = [self getCurrentCoupons];
    CouponInfo *info=[CouponArr objectAtIndex:but.tag];
    
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
    //Adding the Text to the facebook post value from iOS
    
    NSString *GLink=[NSString stringWithFormat:@"\n https://play.google.com/store/apps/details?id=com.ps.coupon "];
    NSString *ALink=[NSString stringWithFormat:@"\n https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=915787141&mt=8 "];
    
    NSString *AllStr=[NSString stringWithFormat:@" להורדה למכשירי   Androidלחצו כאן: %@ \n \n להורדה למכשירי iPhone לחצו כאן: %@ ",GLink,ALink];
    
    NSString *textLink1=@"רוצים גם אתם ליהנות מהקופונים השווים בישראל?\n";
    NSString *text2=@"הורידו את אפליקציית טויס אר אס! \n\n";
    
    [controller setInitialText:[NSString stringWithFormat:@"%@ %@ %@",textLink1,text2,AllStr]];
    
    //Adding the URL to the facebook post value from iOS
    // [controller addURL:[NSURL URLWithString:info.C_Image]];
    
    if (info.C_ShareImage == nil) {
        NSURL *Shareurl=[NSURL URLWithString:[info.C_sImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *Sharerequest   = [NSURLRequest requestWithURL: Shareurl];
        NSHTTPURLResponse *res = nil;
        NSError *err = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:Sharerequest returningResponse:&res error:&err];
        
        if(err==nil && [res statusCode]==200)
        {
            info.C_ShareImage = [UIImage imageWithData:data];
        }
    }
    [controller addImage:info.C_ShareImage];
    //Adding the Text to the facebook post value from iOS
    [self presentViewController:controller animated:YES completion:^{
       //[self hideLoader];
    }];

}

-(void)SendBtnClicked:(id)sender
{
    UIButton *but=(UIButton*)sender;
    NSMutableArray *CouponArr = [self getCurrentCoupons];
    CouponInfo *info=[CouponArr objectAtIndex:but.tag];
    
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if (info.C_ShareImage == nil) {
        NSURL *Shareurl=[NSURL URLWithString:[info.C_sImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *Sharerequest   = [NSURLRequest requestWithURL: Shareurl];
        NSHTTPURLResponse *res = nil;
        NSError *err = nil;
        
        [self showLoader];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:Sharerequest returningResponse:&res error:&err];
        
        if(err==nil && [res statusCode]==200)
        {
            info.C_ShareImage = [UIImage imageWithData:data];
        }
        
        [self hideLoader];
        
    }

    UIImage *AnImage=info.C_ShareImage;
    
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        //        displayLinkSupported = TRUE;
    {
        /*רוצים גם אתם ליהנות מהקופונים השווים בישראל?
         
         הורידו את אפליקציית טויס אר אס!
         
         
         
         להורדה למכשירי   Androidלחצו כאן:
         
         https://play.google.com/store/apps/details?id=com.ps.coupon
         
         להורדה למכשירי iPhone לחצו כאן:
         
         https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=915787141&mt=8*/
        NSString *GLink=[NSString stringWithFormat:@"\n https://play.google.com/store/apps/details?id=com.ps.coupon "];
        NSString *ALink=[NSString stringWithFormat:@"\n https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=915787141&mt=8 "];
        
        NSString *AllStr=[NSString stringWithFormat:@" להורדה למכשירי   Androidלחצו כאן: %@ \n \n להורדה למכשירי iPhone לחצו כאן: %@ ",GLink,ALink];
        
        NSString *textLink1=@"רוצים גם אתם ליהנות מהקופונים השווים בישראל?\n";
        NSString *text2=@"הורידו את אפליקציית טויס אר אס!\n ";
        
        NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeMessage];
        
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:textLink1,text2,AllStr,AnImage, nil] applicationActivities:nil];
        
        activityVC.excludedActivityTypes = excludeActivities;
        
        [self presentViewController:activityVC animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"share information" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)LikeBtnClicked:(id)sender
{
    //[self showLoader2];
    
    [NetworkIndicator startLoading];
    UIButton *but=(UIButton*)sender;
    NSMutableArray *CouponArr = [self getCurrentCoupons];
    
    CouponInfo *info=[CouponArr objectAtIndex:but.tag];
    likeTag=but.tag;
    
    // NSString *urlstr=LIKE_URL;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Like_Url;
    
    //[self showLoader];
    
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
        
        
        //NSLog(@"Like - body: %@",[body description]);
        functionConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        if(functionConnection)
        {
            webData1 = [[NSMutableData alloc]init];
        }
        else
        {
            
            
        }
    }else{
        
        urlstring = LIKE_URL;
        
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

-(void)addToFavoritBtnClicked:(id)sender
{
    // [self showLoader2];
    
    UIButton *But=(UIButton*)sender;
    NSMutableArray *CouponArr = [self getCurrentCoupons];
    
    CouponInfo *info=[CouponArr objectAtIndex:But.tag];
    UIImage *imageData=info.CouponImage;
    
    if (imageData) {
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveImage:imageData WithCupInfo:info];
        });
    }
    
}

#pragma mark - saveImage method

- (void)saveImage:(UIImage *)image  WithCupInfo:(CouponInfo*)CoupInfo {
    //  Make file name first
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoader];
    });
    CouponInfo *Info=[[CouponInfo alloc]init];
    
    Info.C_ID=CoupInfo.C_ID;
    Info.C_Date=CoupInfo.C_Date;
    // Info.C_Image=CoupInfo.ID;
    Info.C_Name=CoupInfo.C_Name;
    Info.C_Text=CoupInfo.C_Text;
    Info.To_Date=CoupInfo.To_Date;
    Info.Total_Like=CoupInfo.Total_Like;
    
    if (likeArr.count>0) {
        for (int i=0; i<likeArr.count; i++) {
            if ([[likeArr objectAtIndex:i] isEqualToString:CoupInfo.C_ID]) {
                int liked=[CoupInfo.Total_Like intValue];
                liked=liked+1;
                Info.Total_Like= [NSString stringWithFormat:@"%d",liked];
            }
        }
    }
    
    
    Info.CouponNumber=CoupInfo.CouponNumber;
    BOOL check=[[DataBase getSharedInstance]CheckCouponId:CoupInfo.C_ID];
    if (check==NO) {
        NSString *filename = [CoupInfo.C_ID stringByAppendingString:@".png"]; // or .jpg
        
        //  Get the path of the app documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        //  Append the filename and get the full image path
        NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        //  Now convert the image to PNG/JPEG and write it to the image path
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:savedImagePath atomically:NO];
        
        //  Here you save the savedImagePath to your DB
        Info.C_Image=filename;
        NSString *ShareFileName=[CoupInfo.C_ID stringByAppendingString:@"Share.png"];
        NSString *ShareSavedImagePath=[documentsDirectory stringByAppendingPathComponent:ShareFileName];
        NSData *ShareImageData=UIImagePNGRepresentation(CoupInfo.C_ShareImage);
        
        [ShareImageData writeToFile:ShareSavedImagePath atomically:NO];
        Info.C_sImageUrl=ShareSavedImagePath;
        
        
        [[DataBase getSharedInstance]AddToFavoriteListData:Info];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoader];
    });
    
}

#pragma mark - retrive Image method

- (UIImage *)loadImage:(NSString *)filePath  {
    return [UIImage imageWithContentsOfFile:filePath];
}

#pragma mark - custom Activityindicator method view
-(void)showLoader{
    Parentview=[[UIView alloc]initWithFrame:CGRectMake(90,200, 150,50)];
    Parentview.backgroundColor=[UIColor grayColor];
    Parentview.layer.cornerRadius=2;
    Parentview.layer.borderWidth=1;
    Parentview.layer.borderColor=[UIColor lightGrayColor].CGColor;
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
    [self.view addSubview:Parentview];
    [progressView startAnimating];
}
-(void)hideLoader{
    [Parentview removeFromSuperview];
}

#pragma mark - custom Activityindicator 2 method view

-(void)showLoader2{
    animateView=[[UIView alloc]initWithFrame:CGRectMake(35,250, 250,60)];
    animateView.backgroundColor=[UIColor darkGrayColor];
    animateView.layer.cornerRadius=2;
    animateView.layer.borderWidth=1;
    animateView.layer.borderColor=[UIColor colorWithWhite:0.8 alpha:1].CGColor;
    animateView.layer.masksToBounds=YES;
    
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
    //   animateView.frame=CGRectMake(0, 0, 0, 0);
    //   animateView.hidden=YES;
    [animateView removeFromSuperview];
    
    //    [self.view addSubview:BackRedBagView];
    //    [self.view addSubview:self.HomeScrollView];
}

#pragma mark - refresh  Button method

-(IBAction)RefreshButtonClicked:(id)sender
{
    if([NetworkIndicator getCounter] < 1)
        [self RefreshCoupons];
}

#pragma mark - scrollview delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // CGFloat pageWidth = self.HomeScrollView.frame.size.width;
    // int page = floor((self.HomeScrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    //[self loadImageForPage:page];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)tableView {
    
    CGFloat pageWidth = self.HomeScrollView.frame.size.width;
    
    int page = floor((self.HomeScrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    int totalPages = floor(self.HomeScrollView.contentSize.width / pageWidth);
    
    NSLog(@"Page : %d / %d , PN:%d",page,totalPages,pageNo);
    pageIndex = page;
    startCouponId = pageIndex;
    
    //    if((pageIndex+3 >= imageShownIndex))
    //      [self SwapCoupnCallWebservice];
}
//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollDirectionDetermined = NO;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    scrollDirectionDetermined = NO;
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (IBAction)changePage {
    // Update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:YES];
    
    // Keep track of when scrolls happen in response to the page control
    // value changing. If we don't do this, a noticeable "flashing" occurs
    // as the the scroll delegate will temporarily switch back the page
    // number.
    scrollDirectionDetermined = YES;
}

- (void) loadImageForPage:(NSInteger)page
{
    
    UIView *view = [[self.HomeScrollView subviews] objectAtIndex:page];
    UIImageView *couponImageView =(UIImageView*)[view viewWithTag:page + 100];
    
    CouponInfo *couponInfo=(CouponInfo*)[[self getCurrentCoupons] objectAtIndex:page];
    [couponImageView setImageWithURL:[NSURL URLWithString:couponInfo.C_Image] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        couponInfo.CouponImage = [self mergeThumbImageWith:image];
    }];
    
    
}

-(void)SwapCoupnCallWebservice
{
    
    
    for (NSInteger i = pageIndex; i<MIN(couponCounts, pageIndex+5); i++) {
        
        UIView *view = [[self.HomeScrollView subviews] objectAtIndex:i];
        UIImageView *couponImageView =(UIImageView*)[view viewWithTag:i + 100];
        
        
        
        CouponInfo *couponInfo=(CouponInfo*)[[self getCurrentCoupons] objectAtIndex:i];
        [couponImageView setImageWithURL:[NSURL URLWithString:couponInfo.C_Image] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            couponInfo.CouponImage = [self mergeThumbImageWith:image];
        }];
        imageShownIndex++;
    }
    
    
    //    isSwaped = YES;
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //    //  http://198.12.150.189/~simssoe/index.php
    //    NSString  *urlstring = Main_Coupon_Url;
    //
    //    [NetworkIndicator startLoading];
    //
    //    NSLog(@"calling SwapCouponService");
    //
    //    //https://toysruscoupon.nethost.co.il/webservices/index.php?action=getCoupan&coupan=Yes&device_id=dviceid123458&page=1items=2
    //
    //    BOOL CheckUrl=YES;// [self isValidURL:[NSURL URLWithString:urlstring]];
    //
    //    if (CheckUrl==YES) {
    //        NSMutableData *body = [[NSMutableData alloc]init ];
    //        NSString *boundary = @"---------------------------14737809831466499882746641449";
    //        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    //        [request setURL:[NSURL URLWithString:urlstring]];
    //        [request setHTTPMethod:@"POST"];
    //
    //        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    //
    //        NSString *first_name = @"Yes";
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"coupan\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithString:first_name] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //        NSData *num = [[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceToken"];
    //        NSString *deviceId=[[[[num description]
    //                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
    //                             stringByReplacingOccurrencesOfString: @">" withString: @""]
    //                            stringByReplacingOccurrencesOfString: @" " withString: @""];
    //
    //        if (deviceId==nil) {
    //            deviceId=@"ae32877r840kg08967";
    //        }
    //
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithString:deviceId] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //        NSLog(@"Total Page Number = %d",pageNo);
    //
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"category\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"%d",category]] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //
    //
    //        NSString *page=[NSString stringWithFormat:@"%d",pageNo];
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[page dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //        NSString *items=@"5";
    //        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"items\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[items dataUsingEncoding:NSUTF8StringEncoding]];
    //        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //
    //        [request setHTTPBody:body];
    //        couponConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    //
    //        //NSLog(@"SwapCoupanCall- RequestBody%@",[body description]);
    //        if(couponConnection)
    //        {
    //            webData = [[NSMutableData alloc]init];
    //        }
    //    }
}

-(UIImage*) mergeThumbImageWith:(UIImage*)couponImg
{
    UIImage *bgImg;
    if (couponImg.size.width < 300) {
        bgImg = [UIImage imageNamed:@"imgthumbbg.png"];
    }
    else
        bgImg = [UIImage imageNamed:@"imgbg.png"];
    
    if (couponImg == nil) {
        return  bgImg;
    }
    
    UIGraphicsBeginImageContext(bgImg.size);
    [bgImg drawInRect:CGRectMake(0, 0, bgImg.size.width, bgImg.size.height)];
    [couponImg drawInRect:CGRectMake((bgImg.size.width - couponImg.size.width)/2, (bgImg.size.height - couponImg.size.height)/2, couponImg.size.width, couponImg.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}


-(void)RefreshCoupons
{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  http://198.12.150.189/~simssoe/index.php
    
    NSString  *urlstring = Main_Coupon_Url;
    
    [self showLoader];
    
    pageNo = 0;
    [NetworkIndicator startLoading];
    
    NSLog(@"calling RefreshCoupons");
    
    BOOL CheckUrl=YES;// [self isValidURL:[NSURL URLWithString:urlstring]];
    
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
        
        
        refreshConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        //NSLog(@"SwapCoupanCall- RequestBody%@",[body description]);
        if(refreshConnection)
        {
            webData2 = [[NSMutableData alloc]init];
        }
    }
}

@end
