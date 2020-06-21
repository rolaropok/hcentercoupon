//
//  StoreLocatorViewController.m
//  ToysRUsIL
//
//  Created by parkhya on 8/27/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "StoreLocatorViewController.h"
#import "HomeViewController.h"
#import "CouponInfo.h"
#import "HomeCustomCell.h"
#import "MapPoint.h"
#import "ThumbViewController.h"
@interface StoreLocatorViewController ()
{
 NSURLConnection *Connection,*Connection1;
    int count;
}
@property (nonatomic,retain) NSMutableData *webData,*webData1;
@end

@implementation StoreLocatorViewController
@synthesize MapView;
@synthesize webData,webData1;
@synthesize progressView;
@synthesize StoreCityTab;
@synthesize CityTextField;
@synthesize StoreAddressTextField;
@synthesize WazeAddress;
@synthesize progressView2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        /*https://www.google.com/maps/embed/v1/view
         ?key=API_KEY
         &center=-33.8569,151.2152
         &zoom=18
         &maptype=satellite*/
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
    isCitySelected=NO;
    StoreArr=[[NSMutableArray alloc]init];
    StoreCityArr=[[NSMutableArray alloc]init];
    SelectedCityDic=[[NSMutableArray alloc]init];
//31.0000° N, 35.0000° E
    // Do any additional setup after loading the view.
    float latitude=31.0000;
    float longitude=35.0000;
//
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = latitude ;
    region.center.longitude = longitude;
    region.span.longitudeDelta = 0.27f;
    region.span.latitudeDelta = 0.27f;
    [MapView setRegion:region animated:YES];
    [MapView setDelegate:self];

    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = Main_Get_Store;
    
    [self showLoader];
  
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

    }else{
    
        urlstring=GET_STORE;
        
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
       
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Bottum tabs method

-(IBAction)StoreLocatorFavoritsBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"StroreLocatorFavorites" sender:self];
}

-(IBAction)StoreLocatorPolicyBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"StoreLocatorPolicyView" sender:self];
}

-(IBAction)StoreLocatorShopOnlineBtnClicked:(id)sender
{
    [self performSegueWithIdentifier:@"StoreLocatorWebView" sender:self];
}

#pragma mark - cross btn method

-(IBAction)StoreLocatorCrossBtnClikced:(id)sender
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

#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection==Connection) {
        [webData setLength:0];
    }else if(connection==Connection1)
    {
        [webData1 setLength:0];
        
    }
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection==Connection) {
        [webData appendData:data];
    }
    else if(connection==Connection1)
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
    SelectedCityDic=[[NSMutableArray alloc]init];
    
    // isReloading = NO ;
    
    if (connection==Connection) {
        
        NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData options:kNilOptions error:nil];
        
        if (arr.count>0) {
            for ( int i=0; i<arr.count; i++) {
                NSDictionary *dic=[arr objectAtIndex:i];
                if ([dic objectForKey:@"store"] ) {
                    NSArray *sArr=[dic objectForKey:@"store"];
                    for (int j=0; j<sArr.count; j++) {
                        NSDictionary *SDic=[sArr objectAtIndex:j];
                        CouponInfo *coup=[[CouponInfo alloc]init];
                        
                        coup.S_ID=[SDic objectForKey:@"id"];
                        coup.S_Address=[SDic objectForKey:@"s_address"];
                        coup.S_City=[SDic objectForKey:@"s_city"];
                        
                        NSURL *url=[NSURL URLWithString:[[SDic objectForKey:@"s_image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                              NSURLRequest *request   = [NSURLRequest requestWithURL:url];
                        
                        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            
                            if (connectionError == nil && data != nil)
                            {
                                UIImage *image = [UIImage imageWithData:data];
                                if (image != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        coup.StoreImage=image;
                                    });
                                }
                                else
                                {
                                    // NSLog(@"image is not downloaded");
                                }
                            }
                            else if (connectionError != nil)
                            {
                                //  NSLog(@"Error %@",[connectionError description]);
                            }
                            else
                            {
                                // NSLog(@"No data could be downloaded");
                            }
                        }];
                        
                        coup.S_Lat=[SDic objectForKey:@"s_lat"];
                        coup.S_Long=[SDic objectForKey:@"s_long"];
                        coup.S_Name=[SDic objectForKey:@"s_name"];
                        coup.S_Text=[SDic objectForKey:@"s_text"];
                        
                        [StoreArr addObject:coup];
                        
                    }
                }
                
                if ([dic objectForKey:@"city"]) {
                    NSArray *CArr=[dic objectForKey:@"city"];
                    for ( int j=0; j<CArr.count; j++) {
                        NSDictionary *CDic=[CArr objectAtIndex:j];
                        CouponInfo *Ccoup=[[CouponInfo alloc]init];
                        Ccoup.C_Lat=[CDic objectForKey:@"c_lat"];
                        Ccoup.C_Long=[CDic objectForKey:@"c_long"];
                        Ccoup.City_Name=[CDic objectForKey:@"c_name"];
                        Ccoup.C_ID=[CDic objectForKey:@"id"];
                        [StoreCityArr addObject:Ccoup];
                    }
                }
            }
            [self plotPoisitionOnMap:StoreArr];
        }
        
            [self hideLoader];
        [self.StoreCityTab reloadData];
    }
    
    if (connection==Connection1) {
        NSString *Status;
    NSArray *arr=[NSJSONSerialization JSONObjectWithData:webData1 options:kNilOptions error:nil];
        for (int i=0; i <arr.count; i++) {
            
            NSDictionary *dic=[arr objectAtIndex:i];
            if ([[dic objectForKey:@"status"] isEqualToString:@"failure"]) {
                Status=[dic objectForKey:@"status"] ;
            }else{
            CouponInfo *info=[[CouponInfo alloc]init];
            
            info.S_ID=[dic objectForKey:@"id"];
            info.S_Address=[dic objectForKey:@"s_address"];
            info.S_City=[dic objectForKey:@"s_city"];
        
            NSURL *url=[NSURL URLWithString:[[dic objectForKey:@"s_image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSURLRequest *request   = [NSURLRequest requestWithURL:url];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                
                if (connectionError == nil && data != nil)
                {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            info.StoreImage=image;
                        });
                    }
                    else
                    {
                        // NSLog(@"image is not downloaded");
                    }
                }
                else if (connectionError != nil)
                {
                    //  NSLog(@"Error %@",[connectionError description]);
                }
                else
                {
                    // NSLog(@"No data could be downloaded");
                }
            }];
            
            info.S_Lat=[dic objectForKey:@"s_lat"];
            info.S_Long=[dic objectForKey:@"s_long"];
            info.S_Name=[dic objectForKey:@"s_name"];
            info.S_Text=[dic objectForKey:@"s_text"];
            
            [SelectedCityDic addObject:info];
            }
        }
        if ([Status isEqualToString:@"failure"]) {
              [self hideLoader];
        }else{
        [self hideLoader];
            [self PlotForSelectedCity];}
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
    
    [self.view addSubview:Parentview];
    [progressView startAnimating];
}
-(void)hideLoader{
    [Parentview removeFromSuperview];
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    MKPinAnnotationView *pinView = nil;

    if(annotation != MapView.userLocation){
        static NSString *defaultPinID = @"mapPoint";
        pinView = (MKPinAnnotationView *)[MapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if(pinView == nil){
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
        }
      
        pinView.enabled = YES;
        pinView.image=[UIImage imageNamed:@"storeSmall.png"];
        pinView.canShowCallout = YES;
    
            }
    else {
        [MapView.userLocation setTitle:@"I am here"];
    }
      
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MapPoint *places=view.annotation;
    SelectedAddress=places.name;
    [StoreAddressTextField setTextAlignment:NSTextAlignmentRight];
    StoreAddressTextField.text=SelectedAddress;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    @try {
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
   
        MapView.region=mapView.region;
       
   
}

#pragma mark - table view data source 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return StoreCityArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCustomCell *CityCell=(HomeCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"CityCell"];
    if (CityCell==nil) {
        CityCell=[[HomeCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CityCell"];
    }
    
    if (indexPath.row %  2 == 0)
        [CityCell setBackgroundColor:[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1.0f]];
    else
        [CityCell setBackgroundColor:[UIColor whiteColor]];
   
    CouponInfo *info=[StoreCityArr objectAtIndex:indexPath.row];
    CityCell.C_NameLab.text=info.City_Name;
    return CityCell;
}

#pragma mark - table view delegates

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CouponInfo *info=[StoreCityArr objectAtIndex:indexPath.row];
    self.CityTextField.text=info.City_Name;
    self.StoreCityTab.alpha=0;
     NSString *first_name = info.C_ID;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //  http://198.12.150.189/~simssoe/index.php
    NSString  *urlstring = [NSString stringWithFormat:Main_Get_StoreBy_City,first_name];
    
    [self showLoader];
    
    BOOL CheckUrl=[self isValidURL:[NSURL URLWithString:urlstring]];
    
    if (CheckUrl==YES) {
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
        
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        
        
        
        Connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
        if(Connection1)
        {
            webData1 = [[NSMutableData alloc]init];
        }
        
    }else{

    urlstring=[NSString stringWithFormat:GET_STOREBY_CITY,first_name];
   // NSMutableData *body = [[NSMutableData alloc]init ];
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"POST"];
    
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
   

    
        Connection1 = [NSURLConnection connectionWithRequest:request delegate:self];
        if(Connection1)
        {
            webData1 = [[NSMutableData alloc]init];
        }
        else
        {
        
        
        }
    }
    
}

#pragma mark - uitextfield delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    self.StoreCityTab.alpha=1;
    return NO;
}

#pragma mark - direction button method

-(IBAction)PointOnWaze:(id)sender
{

    
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
             NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        s = [s invertedSet];
        
        NSRange r = [SelectedAddress rangeOfCharacterFromSet:s];
        if (r.location == NSNotFound) {
            NSLog(@"the string contains illegal characters");
             NSString *urlStr =[NSString stringWithFormat:@"waze://?q=%@",SelectedAddress];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }else{
        SelectedAddress=@"israil";
        
        SelectedAddress=[SelectedAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        NSString *urlStr =[NSString stringWithFormat:@"waze://?q=%@",SelectedAddress];
        
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];}
        
    } else {
        
        // Waze is not installed. Launch AppStore to install Waze app
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
    
}

#pragma  mark - add annotation on map

-(void)plotPoisitionOnMap:(NSArray*)plotArr
{
    if ([StoreArr count]>0) {
        
        for (id<MKAnnotation> annotation in MapView.annotations)
        {
           // NSLog(@" in for annotation ");
            if ([annotation isKindOfClass:[MapPoint class]])
            {
                //NSLog(@"in if annotation");
                [MapView removeAnnotation:annotation];
            }
        }
        count=0;
        int i;
        //Loop through the array of places returned from the Google API.
        for (i=0; i<[StoreArr count]; i++)
        {
            
            //Retrieve the NSDictionary object in each index of the array.
            
            CouponInfo *info=[StoreArr objectAtIndex:i];
            
            NSString *vicinity=info.S_Address;
         
            
            //Create a special variable to hold this coordinate info.
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.latitude=[info.S_Lat doubleValue];
            placeCoord.longitude=[info.S_Long doubleValue];
            
            //Create a new annotiation.
            MapPoint *placeObject = [[MapPoint alloc] initWithName:vicinity address:nil coordinate:placeCoord];
            [MapView addAnnotation:placeObject];
            
        }
        
        CouponInfo *setRegion=[StoreArr objectAtIndex:0];
        float latitude=[setRegion.S_Lat doubleValue];
        float longitude=[setRegion.S_Long doubleValue];
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        region.center.latitude = latitude ;
        region.center.longitude = longitude;
        [MapView setRegion:region animated:YES];
        
    }
    

}


-(void)PlotForSelectedCity
{
    if (SelectedCityDic>0) {
        count=0;
        isCitySelected=YES;
        for (id<MKAnnotation> annotation in MapView.annotations)
        {
           // NSLog(@" in for annotation ");
            if ([annotation isKindOfClass:[MapPoint class]])
            {
             //   NSLog(@"in if annotation");
                [MapView removeAnnotation:annotation];
            }
        }
        
        int i;
        //Loop through the array of places returned from the Google API.
        for (i=0; i<[SelectedCityDic count]; i++)
        {
            
            //Retrieve the NSDictionary object in each index of the array.
            
            CouponInfo *info=[SelectedCityDic objectAtIndex:i];
         
            //Get our name and address info for adding to a pin.
            NSString *name=info.S_Address;
            //Get the lat and long for the location.
         
            //Create a special variable to hold this coordinate info.
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.latitude=[info.S_Lat doubleValue];
            placeCoord.longitude=[info.S_Long doubleValue];
            
            //Create a new annotiation.
            MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:nil coordinate:placeCoord];
            
            
            [MapView addAnnotation:placeObject];
        }
        
        CouponInfo *setRegion=[SelectedCityDic objectAtIndex:0];
        float latitude=[setRegion.S_Lat doubleValue];
        float longitude=[setRegion.S_Long doubleValue];
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        region.center.latitude = latitude ;
        region.center.longitude = longitude;
        region.span.longitudeDelta = 0.27f;
        region.span.latitudeDelta = 0.27f;
        [MapView setRegion:region animated:YES];
        [MapView setDelegate:self];
        
        
    }
}

#pragma mark - call out button method

-(void)AddButTapped:(id)sender
{
    UIButton *but=(UIButton*)sender;
    CouponInfo *info;
    if (isCitySelected==YES) {
       info=[SelectedCityDic objectAtIndex:but.tag];
    }else{
        info=[StoreArr objectAtIndex:but.tag];
    }
    
    StoreAddressTextField.text=info.S_Address;
    SelectedAddress=info.S_Address;
    
}


#pragma mark - zoomIn ZoomOut Button

-(IBAction)ZoomInOut:(id)sender
{

    UIButton *but=(UIButton*)sender;
    if (but.tag==1) {
        MKCoordinateRegion region = MapView.region;
        MKCoordinateSpan span;
        span.latitudeDelta = region.span.latitudeDelta/2;
        span.longitudeDelta = region.span.longitudeDelta/2;
        region.span = span;
        [MapView setRegion:region animated:TRUE];
        
    }else if (but.tag==2){
        MKCoordinateRegion region = MapView.region;
        MKCoordinateSpan span;
        span.latitudeDelta = region.span.latitudeDelta*2;
        span.longitudeDelta = region.span.longitudeDelta*2;
        
        region.span = span;
        [MapView setRegion:region animated:TRUE];
    }
    
}

@end
