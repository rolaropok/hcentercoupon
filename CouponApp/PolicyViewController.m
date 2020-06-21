//
//  PolicyViewController.m
//  CouponApp
//
//  Created by parkhya on 8/26/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "PolicyViewController.h"
#import "HomeViewController.h"
#import "AMPActivityIndicator.h"
#import "ThumbViewController.h"

@interface PolicyViewController ()<NSURLConnectionDelegate>
{
    NSURLConnection *Connection;
      UIView *Parentview;
}
@property(nonatomic,strong)AMPActivityIndicator* progressView;
@property (nonatomic,retain) NSMutableData *webData;
@end

@implementation PolicyViewController
@synthesize webData;
@synthesize PolicyText;
@synthesize PolicyTextView;
@synthesize progressView;
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
    
    NSString *text=[[NSUserDefaults standardUserDefaults]objectForKey:@"Policy"];
    if (![text isEqualToString:@""]) {
        PolicyTextView.text=text;
    }
    [self showLoader];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = MAin_Get_Policy;
    
  //  [self showLoader];
   // NSMutableData *body = [[NSMutableData alloc]init ];
    
    BOOL CheckUrl=[self isValidURL:[NSURL URLWithString:urlstring]];
    
    if (CheckUrl==YES) {
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        
        Connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        
        if(Connection)
        {
            webData = [[NSMutableData alloc]init];
        }
        else
        {
            
            
        }

    }else{
        
        urlstring=GET_POLICY;
    
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
    
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    

        Connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
    
        if(Connection)
        {
            webData = [[NSMutableData alloc]init];
        }
        else
        {
        
        
        }
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - bottom tabs methods

-(IBAction)PolicyFavoritesBtnClicked:(id)sender;
{//PolicyFavorites
  [self performSegueWithIdentifier:@"PolicyFavorites" sender:self];
}
-(IBAction)PolicyStoreLocatorBtnClicked:(id)sender;
{
    [self performSegueWithIdentifier:@"PolicyMapView" sender:self];
}
-(IBAction)PolicyShopOnlineBtnClicked:(id)sender;
{
    [self performSegueWithIdentifier:@"ShopOnlineFromPolicy" sender:self];
}

#pragma mark - cross btn method

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
   // [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection==Connection) {
        [webData setLength:0];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection==Connection) {
        [webData appendData:data];
    }
    }
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"can not Connect to Server" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
   // [self hideLoader];
    //  isReloading = NO ;
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // isReloading = NO ;
    NSError *err;
    if (connection==Connection) {
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:&err];
        NSLog(@"error %@ ",err);
        
        for (int i=0; i<arr.count; i++) {
            
            NSDictionary *dic=[arr objectAtIndex:i];
            PolicyText=[[dic objectForKey:@"policy"]objectForKey:@"p_name"];
            
            [[NSUserDefaults standardUserDefaults]setObject:PolicyText forKey:@"Policy"];
            
            self.PolicyTextView.text=PolicyText;
        }
    }
    [self hideLoader];
}

           
#pragma mark - custom Activityindicator method view

-(void)showLoader{
    Parentview=[[UIView alloc]initWithFrame:CGRectMake(90,250, 150,60)];
    Parentview.backgroundColor=[UIColor darkGrayColor];
    Parentview.layer.cornerRadius=2;
    Parentview.layer.borderWidth=1;
    Parentview.layer.borderColor=[UIColor colorWithWhite:0.8 alpha:1].CGColor;
    Parentview.layer.masksToBounds=YES;

    
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
    headerLabel.frame = CGRectMake(50,15,90,30);
    headerLabel.text= @"Wait...";
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
