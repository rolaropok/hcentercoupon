//
//  ThumbViewController.m
//  ToysRUsIL
//
//  Created by Fredrick Jansen on 14/02/15.
//  Copyright (c) 2015 Fredrick Jansen. All rights reserved.
//

#import "ThumbViewController.h"
#import "HomeCustomCell.h"
#import "CouponInfo.h"
#import "DataBase.h"
#import "WebSiteViewController.h"
#import "NetworkIndicator.h"
#import "AMPActivityIndicator.h"
#import "UIImageView+WebCache.h"
#import "HomeViewController.h"
#import "CouponManager.h"

@interface ThumbViewController ()<NSURLConnectionDelegate,UIScrollViewDelegate>
{
    NSURLConnection *couponConnection,*functionConnection,*refreshConnection;

    int pageIndex,totalPages;
    BOOL scrollDirectionDetermined;
    BOOL isSwaped;
    int offsetx;
    int refreshTag;
    long int status;
    NSInteger pageNo;
    NSString* workingURL;
    NSInteger selectedCategory;
    NSInteger selectedCoupon;
    CouponManager *couponManager;
    UIPanGestureRecognizer *panGesture;
    int cat1StartIndex,cat2StartIndex,cat3StartIndex,cat4StartIndex,cat5StartIndex;
}
@property (nonatomic,retain) NSMutableData *webData,*webData1,*webData2;

@end

@implementation ThumbViewController
@synthesize CouponArr;

@synthesize webData,webData1,webData2;
@synthesize HomeTableView;
@synthesize progressView;
@synthesize HomeScrollView;
@synthesize PreviousButton,NextButton;
@synthesize BackRedBagView;
@synthesize pageControl;

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
    
    selectedCategory = 1;
    CouponArr = [self getParsedArray];
    
    scrollDirectionDetermined = NO;
    isSwaped = NO;
    pageNo=1;
    pageNo = CouponArr.count;
    [self addSubViewsInScrolleView];
    [self registerNotification];
    [self setSelected:1];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Notification

-(void)registerNotification
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(selectCategory:)
               name:@"selectCategory" object:nil];
}

-(void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void) selectCategory:(NSNotification *)notification
{
    NSInteger cat = [((NSString*)[notification.userInfo valueForKey:@"category"]) integerValue];
    
    switch (cat) {
        case 1:
            [self clickAssortedCategory:nil];
            break;
        case 2:
            [self clickBabyCategory:nil];
            break;
        case 3:
            [self clickBoyCategory:nil];
            break;
        case 4:
            [self clickGirlCategory:nil];
            break;
        case 5:
            [self clickPowerCardCategory:nil];
            break;
        default:
            break;
    }
    
}


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
    
   
    if(connection == refreshConnection)
    {
        [webData2 setLength:0];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection == refreshConnection)
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
        //  NSLog(@"error %@ ",err);
        //NSLog(@"Refresh - %@" , [arr description]);
        
        if (arr.count>0) {
            
            if ([[arr objectAtIndex:0]objectForKey:@"status"]) {
                [self hideLoader];
                [NetworkIndicator stopLoading];
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
    }
}

- (void) backgroundService
{
    
    
}


-(NSMutableArray*) getParsedArray
{
    NSMutableArray *couponArray = [[NSMutableArray alloc] init];
    
    [couponArray addObjectsFromArray:couponManager.cat1];
    int nilCount = (6 - couponManager.cat1Size %6) %6;
    
    CouponInfo *nilCoupon = [[CouponInfo alloc] init];
    nilCoupon.C_ID = nil;
    for (int i=0; i< nilCount; i++) {
        [couponArray addObject:nilCoupon];
    }
    cat1StartIndex = 0;
    
    [couponArray addObjectsFromArray:couponManager.cat2];
    nilCount = (6 - couponManager.cat2Size %6) %6;
    for (int i=0; i< nilCount; i++) {
        [couponArray addObject:nilCoupon];

    }
    cat2StartIndex = ceil((float)couponManager.cat1Size / 6);
    
    [couponArray addObjectsFromArray:couponManager.cat3];
    nilCount = (6 - couponManager.cat3Size %6) %6;
    for (int i=0; i< nilCount; i++) {
        [couponArray addObject:nilCoupon];
    }
    cat3StartIndex = cat2StartIndex + ceil((float)couponManager.cat2Size / 6);
    
    [couponArray addObjectsFromArray:couponManager.cat4];
    nilCount = (6 - couponManager.cat4Size %6) %6;
    for (int i=0; i< nilCount; i++) {
        [couponArray addObject:nilCoupon];

    }
    cat4StartIndex = cat3StartIndex + ceil((float)couponManager.cat3Size / 6);

    [couponArray addObjectsFromArray:couponManager.cat5];
    nilCount = (6 - couponManager.cat5Size %6) %6;
    for (int i=0; i< nilCount; i++) {
        [couponArray addObject:nilCoupon];
    }
    cat5StartIndex = cat4StartIndex + ceil((float)couponManager.cat4Size / 6);

    totalPages = [couponArray count] / 6;
    return couponArray;
}

#pragma mark - add views in scrollview
-(void)addSubViewsInScrolleView
{
    //pageIndex=0;
    //NSLog(@"CouponArr Size:%d",CouponArr.count);
    
    for (UIView *v in self.HomeScrollView.subviews) {
        [v removeFromSuperview];
    }
    
    NSInteger couponcounts = [CouponArr count];

    int pages = ceil((float)couponcounts / 6);
    int page = 0;
    
    while (page < pages) {
        // if (CouponArr.count>0) {
        
        CouponInfo *coupIfo;
        UIView* CView=[[UIView alloc]initWithFrame:CGRectMake((page)*320, 0, 320, 421)];
        //[CView setBackgroundColor:[UIColor whiteColor]];
        [self.HomeScrollView addSubview:CView];
        
        int width,height,offsetX,offsetY,margin;
        if ([AppDelegate sharedInstance].DeviceHight>480)
        {
            width = 120, height =120;
            margin = 5;
            offsetX = (320 - width*2 - 5) / 2 ,offsetY = (self.HomeScrollView.frame.size.height - height*3 - 2*margin) / 2;
            
        }
        else
        {
            width = 110, height =100;
            margin = 5;
            offsetX = (320 - width*2 - 5) / 2 ,offsetY = (self.HomeScrollView.frame.size.height - height*3 - 2*margin) / 2;
        }
        
        for (int i =0; i<6; i++) {
            int index =page * 6 +i;
            
            coupIfo=[CouponArr objectAtIndex:index];
            
            if( coupIfo.C_ID != nil)
            {
            
                UIImageView* thumbImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(offsetX + (margin+width) * (i % 2),offsetY + (margin + height) * (i / 2),width,height)];
                [thumbImageView1 setTag:index];
                
                if (index < 6) {
                    [thumbImageView1 setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
                }
                
                
                [thumbImageView1 setUserInteractionEnabled:YES];
                UITapGestureRecognizer *thumbnailTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnThumbnail:)];
                [thumbImageView1 addGestureRecognizer:thumbnailTapGesture];
                [CView addSubview:thumbImageView1];
            }
            else
                break;
        }
        UIButton *homePevious=[UIButton buttonWithType:UIButtonTypeCustom];
        homePevious.frame=CGRectMake(0, 185, 25, 27);
        [homePevious setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
        [CView addSubview:homePevious];
        homePevious.tag=page;
        [homePevious addTarget:self action:@selector(PreviousButClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *HomeNext=[UIButton buttonWithType:UIButtonTypeCustom];
        HomeNext.frame=CGRectMake(295, 185, 25, 27);
        [HomeNext setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
        [CView addSubview:HomeNext];
        [HomeNext addTarget:self action:@selector(nextButClicked:) forControlEvents:UIControlEventTouchUpInside];
        HomeNext.tag=page;
        
        if (page == 0) {
                homePevious.alpha=0;
                HomeNext.alpha=1;
        } else if(page == pages-1)
        {
            homePevious.alpha=1;
            HomeNext.alpha=0;
        }else
        {
            homePevious.alpha=1;
            HomeNext.alpha=1;
        }
        
        //NSLog(@"6");
        if ([AppDelegate sharedInstance].DeviceHight==480)
        {
            CView.frame=CGRectMake((page-1)*320, 0, 320, 340);
            homePevious.frame=CGRectMake(0, 135, 25, 27);
            HomeNext.frame=CGRectMake(295, 135, 25, 27);
        }
        page++;
    }
    
    self.HomeScrollView.contentSize=CGSizeMake(320* pages,390);
    if ([AppDelegate sharedInstance].DeviceHight==480)
    {
        self.HomeScrollView.contentSize=CGSizeMake(320*pages, 330);
    }
    
    [self moveTo:0 Animate:NO];
    
    //self.HomeScrollView.scrollEnabled=YES;
}


-(BOOL) nextCategory
{
    switch (selectedCategory) {
        case 1:
            [self clickBabyCategory:nil];
            break;
        case 2:
            [self clickBoyCategory:nil];
            break;
        case 3:
            [self clickGirlCategory:nil];
            break;
        case 4:
            [self clickPowerCardCategory:nil];
            break;
        case 5:
            return NO;
        default:
            break;
    }
    return YES;
}


-(BOOL) beforeCategory
{
    switch (selectedCategory) {
        case 1:
            return NO;
        case 2:
            [self clickAssortedCategory:nil];
            break;
        case 3:
            [self clickBabyCategory:nil];
            
            
            break;
        case 4:
            [self clickBoyCategory:nil];
            break;
        case 5:
            [self clickGirlCategory:nil];
            break;
    }
    return YES;
}



- (IBAction)clickAssortedCategory:(id)sender {
    
    if (selectedCategory == 1)
        return;
    [self setSelected:1];
    [self moveTo:cat1StartIndex Animate:YES];
    
}

- (IBAction)clickBabyCategory:(id)sender {
    if (selectedCategory == 2)
        return;
    [self setSelected:2];
    [self moveTo:cat2StartIndex Animate:YES];
}

- (IBAction)clickBoyCategory:(id)sender {
    if (selectedCategory == 3)
        return;
    [self setSelected:3];
    [self moveTo:cat3StartIndex Animate:YES];
}

- (IBAction)clickGirlCategory:(id)sender {
    if (selectedCategory == 4)
        return;
    [self setSelected:4];
    [self moveTo:cat4StartIndex Animate:YES];
}

- (IBAction)clickPowerCardCategory:(id)sender {
    if (selectedCategory == 5)
        return;

    [self setSelected:5];
    [self moveTo:cat5StartIndex Animate:YES];
}

-(void) setSelected:(NSInteger) cat
{
    selectedCategory = cat;
    
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


-(void) moveTo:(int) page Animate:(BOOL) animate
{
    pageIndex = page;
    
    
    if (page < cat2StartIndex) {
        [self setSelected:1];
    }else if (page < cat3StartIndex) {
        [self setSelected:2];
    }else if (page < cat4StartIndex) {
        [self setSelected:3];
    }else if (page < cat5StartIndex) {
        [self setSelected:4];
    }else{
        [self setSelected:5];
    }

    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * page;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:animate];
    
    if (page != 0) {
        [self renderThumbImagesForPage:MIN(page,totalPages-1)];
    }
    [self renderThumbImagesForPage:MIN(page+1,totalPages-1)];
}

-(int) getRealIndex:(int) tag
{

    switch (selectedCategory) {
        case 1:
            return tag - 6*cat1StartIndex;
        case 2:
            return tag - 6*cat2StartIndex;
        case 3:
            return tag - 6*cat3StartIndex;
        case 4:
            return tag - 6*cat4StartIndex;
        case 5:
            return tag - 6*cat5StartIndex;
        default:
            return 0;
    }
}

-(void) tapOnThumbnail:(UITapGestureRecognizer*)sender
{
    UIImageView *thumb = (UIImageView*)sender.view;
    selectedCoupon = [self getRealIndex:thumb.tag];
    NSLog(@"%ld Category's %ld Coupon",(long)selectedCategory,(long)selectedCoupon);
    [self performSegueWithIdentifier:@"Coupons" sender:nil];
    
}

-(IBAction)nextButClicked:(id)sender
{
    int pages = ceil((float)CouponArr.count / 6);
    if (pageIndex< pages-1) {
        pageIndex++;
        [self moveTo:pageIndex Animate:YES];

    }
}

-(IBAction)PreviousButClicked:(id)sender
{

    if (pageIndex>0) {
        pageIndex--;
        [self moveTo:pageIndex Animate:YES];

    }
}

-(void) refreshHomeScrollView:(int) pos
{
    CGRect frame;
    frame.origin.x = self.HomeScrollView.frame.size.width * pos;
    frame.origin.y = 0;
    frame.size = self.HomeScrollView.frame.size;
    [self.HomeScrollView scrollRectToVisible:frame animated:YES];
}

-(void)LeftGestureForView:(id)sender
{
    
    UISwipeGestureRecognizer *Swipe=(UISwipeGestureRecognizer*)sender;
    CGRect frame;
    if (Swipe.direction==UISwipeGestureRecognizerDirectionLeft) {
        if (pageIndex<CouponArr.count) {
            
            PreviousButton.alpha=1;
            if (CouponArr.count==1) {
                self.NextButton.alpha=0;
                self.PreviousButton.alpha=0;
            }
            
            frame.origin.x = self.HomeScrollView.frame.size.width * (pageIndex+1);
            frame.origin.y = 0;
            frame.size = self.HomeScrollView.frame.size;
            [self.HomeScrollView scrollRectToVisible:frame animated:YES];
            pageIndex++;
            if (pageIndex==CouponArr.count-1) {
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
            
            NextButton.alpha=1;
            if (CouponArr.count==1) {
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

-(void) renderThumbImagesForPage:(int) page
{
    UIView *view = [[HomeScrollView subviews] objectAtIndex:page];
    
    for (int i = 0; i<6; i++) {
        int tag = page * 6 + i;
        if ([[view viewWithTag:tag] isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView*)[view viewWithTag:tag];
            CouponInfo *coupIfo = [CouponArr objectAtIndex:tag];
            
            if (imageView != nil && imageView.image == nil) {
                [imageView setImageWithURL:[NSURL URLWithString:coupIfo.C_ThumbImage] placeholderImage:[self mergeThumbImageWith:[UIImage imageNamed:@"loading.gif"]]];
            }else
                break;
        }
    }
}

#pragma mark - refresh  Button method



-(IBAction)RefreshButtonClicked:(id)sender
{
    if([NetworkIndicator getCounter] < 1)
        [self RefreshCoupons];
}

#pragma mark - scrollview delegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"offset: (%f,%f)",scrollView.contentOffset.x,scrollView.contentOffset.y);
    
    

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = self.HomeScrollView.frame.size.width;
    int page = floor((self.HomeScrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    NSLog(@"Page : %d / %d , PN:%ld",page,totalPages,(long)pageNo);
    pageIndex = page;

    if (page < cat2StartIndex) {
        [self setSelected:1];
    }else if (page < cat3StartIndex) {
        [self setSelected:2];
    }else if (page < cat4StartIndex) {
        [self setSelected:3];
    }else if (page < cat5StartIndex) {
        [self setSelected:4];
    }else{
        [self setSelected:5];
    }
    [self renderThumbImagesForPage:MIN(page,totalPages-1)];
    [self renderThumbImagesForPage:MIN(page+1,totalPages-1)];
}

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
    
    if ([segue.identifier isEqualToString:@"Coupons"]) {
        
        HomeViewController *home =(HomeViewController*) segue.destinationViewController;
        home.category = selectedCategory;
        home.startCouponId = selectedCoupon;
    }
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
-(void)SwapCoupnCallWebservice
{
    isSwaped = YES;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Coupon_Url;
    
    //[self showLoader];
    
    [NetworkIndicator startLoading];
    
    NSLog(@"calling SwapCouponService");
    
    //https://toysruscoupon.nethost.co.il/webservices/index.php?action=getCoupan&coupan=Yes&device_id=dviceid123458&page=1items=2
    
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
        
        
        NSLog(@"Total Page Number = %ld",(long)pageNo);
        
        NSString *page=[NSString stringWithFormat:@"%ld",(long)pageNo];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[page dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *items=@"2";
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"items\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[items dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        couponConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        //NSLog(@"SwapCoupanCall- RequestBody%@",[body description]);
        if(couponConnection)
        {
            webData = [[NSMutableData alloc]init];
        }
        else
        {
            
            
        }
        
    }
    
    
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
