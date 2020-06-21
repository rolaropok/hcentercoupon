//
//  DataBase.m
//  CouponApp
//
//  Created by parkhya on 8/26/14.
//  Copyright (c) 2014 parkhya. All rights reserved.
//

#import "DataBase.h"
#import <sqlite3.h>

static DataBase *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


@implementation DataBase


@synthesize isFirst;
#pragma mark - get shared instance method

+(DataBase*)getSharedInstance
{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance findDBPath];
    }
    return sharedInstance;
}

#pragma mark - find dbpath method

- (void)findDBPath
{
    NSString *databaseName = @"CouponApp.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    databasepath = [[NSString alloc] initWithFormat:@"%@", [documentsDir stringByAppendingPathComponent:databaseName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:databasepath];
    
    if(!success) {
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        [fileManager copyItemAtPath:databasePathFromApp toPath:databasepath error:nil];
    }
    
    isFirst = true;
}


#pragma mark - coupon methods

- (BOOL) AddToFavoriteListData:(CouponInfo*)CoupInfo{
    //[self findDBPath];
    const char *dbpath = [databasepath UTF8String];
    // NSLog(@"DBPATH:%s",dbpath);
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        /* *******("cdate" TEXT, "cimage" TEXT, "cname" TEXT, "cid" TEXT, "todate" TEXT, "totallikes" TEXT, "ctext" TEXT ,"cshareimage" TEXT, "couponNumber" TEXT)******* */
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into FavoriteList (cdate,cimage,cname,cid,todate,totallikes,ctext,cshareimage,couponNumber) values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",CoupInfo.C_Date,CoupInfo.C_Image,CoupInfo.C_Name,CoupInfo.C_ID,CoupInfo.To_Date,CoupInfo.Total_Like,CoupInfo.C_Text,CoupInfo.C_sImageUrl,CoupInfo.CouponNumber];
        
        //  NSLog(@"%@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        // NSLog(@"%i",sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL));
        
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        //  NSLog(@"%i",sqlite3_step(statement));
        //  NSLog(@"error %s.",sqlite3_errmsg(database));
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        { sqlite3_finalize(statement);
            sqlite3_close(database);
            return YES;
        }
        else { sqlite3_finalize(statement);
            sqlite3_close(database);
            return NO;
        }
        sqlite3_reset(statement);
    }
    return NO;
}


-(NSMutableArray*)receiveAllData
{
    //[self findDBPath];
    NSMutableArray *record = [[NSMutableArray alloc]init];
    NSString *coupon_names = @"";
   //  NSLog(@"%@",databasepath);
    //  NSLog(@"%s",[databasepath UTF8String]);
    const char *dbpath=[databasepath UTF8String];
    //NSLog(@"DBPATH:%s",dbpath);
    if (sqlite3_open(dbpath, &database)==SQLITE_OK) {
        NSString *selectSQL=[NSString stringWithFormat:@"select * from FavoriteList"];
        const char *select_stmt=[selectSQL UTF8String];
        // NSLog(@"%i",sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL));
        int res = sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL);
        if (res!=SQLITE_OK){
            // NSLog(@"Problem with prepare statement.");
        }
        else{
            //NSInteger temp=0,num=0;
            
            while(sqlite3_step(statement)==SQLITE_ROW){
                CInfo = [[CouponInfo alloc]init];
                
                // medInfo.ID=[[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)]intValue];
                
                CInfo.C_Date=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
                CInfo.C_Image=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
                CInfo.C_Name=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
                CInfo.C_ID=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
                CInfo.To_Date=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
                CInfo.Total_Like=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
                CInfo.C_Text=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 6)];
                CInfo.C_sImageUrl=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 7)];
                CInfo.CouponNumber=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 8)];
                [record addObject:CInfo];
                
                coupon_names = [coupon_names stringByAppendingString:[NSString stringWithFormat:@"%@,",CInfo.C_Name ]];
            }
        }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
   
    
    if(isFirst && [record count] > 0)
    {
        
        NSString *url = [NSString stringWithFormat:@"%@=%@",Main_Coupon_Status_Url,coupon_names];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
        [request setHTTPMethod: @"GET"];
        NSError *requestError;
        NSURLResponse *urlResponse = nil;
    
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        if(response != nil)
        {
            NSString *res = [[[NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil] objectAtIndex:0] objectForKey:@"status"];
        
            NSArray* status = [res componentsSeparatedByString: @","];
            int removed = 0;
       
            for (int i=0; i< [status count]-1; i++)
            {
           
                if([[status objectAtIndex:i] isEqualToString:@"0"])
                {
                    [self deleteDataFromFavoritesList:[record objectAtIndex:i-removed ]];
                    [record removeObjectAtIndex:i-removed];
                
                }
            }
        }
        
        isFirst = NO;
    }
    return record;
}

-(BOOL)CheckCouponId:(NSString*)CoupId
{

    const char *dbpath=[databasepath UTF8String];

    if (sqlite3_open(dbpath, &database)==SQLITE_OK) {
        NSString *selectSQL=[NSString stringWithFormat:@"select * from FavoriteList where cid=\"%@\"",CoupId];
        const char *select_stmt=[selectSQL UTF8String];

        int res = sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL);
        if (res!=SQLITE_OK){
            //  NSLog(@"Problem with prepare statement.");
        }
        else{

            
            if (sqlite3_step(statement)==SQLITE_ROW){
                sqlite3_finalize(statement);
                sqlite3_close(database);
                return YES;
                
            }else{
                sqlite3_finalize(statement);
                sqlite3_close(database);
                return NO;
            }
        }
        sqlite3_reset(statement);
        
    }

    sqlite3_close(database);
    return NO;
}

-(BOOL)deleteDataFromFavoritesList:(CouponInfo*)coupon
{
    //[self findDBPath];
    BOOL isSuccess=NO;

    //NSLog(@"%@",databasepath);
    
    const char *dbpath=[databasepath UTF8String];
    
    // NSLog(@"DBPATH:%s",dbpath);
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from FavoriteList where cid=\"%@\"",coupon.C_ID];
        
        // NSLog(@"%@",deleteSQL);
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt,-1, &statement, NULL);
        //NSLog(@"%d",sqlite3_step(statement));
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            sqlite3_close(database);
            isSuccess=YES;
        }
        else {
            sqlite3_close(database);
            
            isSuccess=NO;
        }
        sqlite3_reset(statement);
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return isSuccess;
}
@end
