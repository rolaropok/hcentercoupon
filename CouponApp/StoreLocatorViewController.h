//
//  StoreLocatorViewController.h
//  ToysRUsIL
//
//  Created by parkhya on 8/27/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AMPActivityIndicator.h"

@interface StoreLocatorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,MKMapViewDelegate>
{
 UIView *Parentview;
    
    NSMutableArray *StoreArr;
    NSMutableArray *StoreCityArr;
    
     NSMutableArray *SelectedCityDic;
    
    BOOL isCitySelected;
    
    NSString *SelectedAddress;
    
}
@property (weak, nonatomic) IBOutlet UITextField *CityTextField;
@property (weak, nonatomic) IBOutlet UITextField *StoreAddressTextField;
@property (weak, nonatomic) IBOutlet MKMapView *MapView;

@property(nonatomic,retain)NSString *WazeAddress;

@property(nonatomic,strong)AMPActivityIndicator* progressView;
@property(nonatomic,strong)AMPActivityIndicator* progressView2;

-(IBAction)StoreLocatorFavoritsBtnClicked:(id)sender;
-(IBAction)StoreLocatorPolicyBtnClicked:(id)sender;
-(IBAction)StoreLocatorShopOnlineBtnClicked:(id)sender;
-(IBAction)StoreLocatorCrossBtnClikced:(id)sender;

-(IBAction)PointOnWaze:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *StoreCityTab;

-(IBAction)ZoomInOut:(id)sender;

@end
