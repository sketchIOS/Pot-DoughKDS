//
//  RiceViewController.m
//  CollectionView
//
//  Created by Arka Banerjee on 17/08/17.
//  Copyright © 2017 Arka Banerjee. All rights reserved.
//

#import "RiceViewController.h"
#import "RiceCollectionViewCell.h"
#import "exclamationAlert.h"
#import <AFHTTPSessionManager.h>
#import "AppDelegate.h"
#import "commonUrl.h"
#import "orderListView.h"

@interface RiceViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,alertDelegate>{

    __weak IBOutlet UIScrollView *scrollV;
    NSMutableArray *arrTime,*arrTable,*arrHead,*arrheight,*arrColor;
    NSMutableArray *arrItem;
    float height;
    float width;
    NSDictionary *dict_Result;
    AppDelegate *appDelegate;
    BOOL willUpdate;
    exclamationAlert *alertVw;
    RiceCollectionViewCell  *cellDelete;
    int count;
    NSMutableArray *resultArray;
    NSTimer *timer;
    float floteValue;
}

@end

@implementation RiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    width = 0;
    floteValue = 0;

    
    [_riceCollectionVw registerNib:[UINib nibWithNibName:@"RiceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"RiceCollectionViewCell"];
  
    _riceCollectionVw.delegate = self;
    _riceCollectionVw.dataSource = self;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(getOrderListforChefUpdate) userInfo:nil repeats:YES];
    
    [self performSelector:@selector(getOrderListforChefUpdate) withObject:nil afterDelay:1.0];

    NSDate *d = [NSDate dateWithTimeIntervalSinceNow: 10.0];
    NSTimer *t = [[NSTimer alloc] initWithFireDate: d
                                          interval: 20
                                            target: self
                                          selector:@selector(getOrderListforChefUpdate)
                                          userInfo:nil repeats:YES];

    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:t forMode: NSDefaultRunLoopMode];
    
   // [t release];
    willUpdate = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// uicollectionView delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrResult.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    RiceCollectionViewCell *cell = [_riceCollectionVw dequeueReusableCellWithReuseIdentifier:@"RiceCollectionViewCell" forIndexPath:indexPath];

    cell.tag = indexPath.row;
    NSLog(@"index = %ld",cell.tag);
    dict_Result = [_arrResult objectAtIndex:cell.tag];
    NSArray *orderDetailsArray = [dict_Result valueForKey:@"order_details"];
    floteValue = cell.timeTableView.frame.origin.y+cell.timeTableView.frame.size.height-30;
    //float floteValue = cell.timeTableView.frame.origin.y;
    for (orderListView *orderView in cell.orderScrollView.subviews) {
        if ([orderView isKindOfClass:[orderListView class]]) {
            [orderView removeFromSuperview];
        }
    }
    //For Order View
    for (int i=0; i<orderDetailsArray.count; i++) {
        orderListView *orderView = [[orderListView alloc] init];
        //NSString *strA = @" QTY :  ";
        NSDictionary *orderDetailsDict = [orderDetailsArray objectAtIndex:i];
        if([(NSString*)[orderDetailsDict objectForKey:@"name"] isKindOfClass:[NSNull class]]){
            orderView.lbl_HeadCount.text = @"";
        }else
           orderView.lbl_HeadCount.text = [orderDetailsDict objectForKey:@"name"];
        orderView.numberOfItemLbl.text = [orderDetailsDict objectForKey:@"meal_quantity"];
        orderView.lbl_Item.text = [self getItemDetails:[orderDetailsDict objectForKey:@"productArr"]];
        CGRect descriptionFrame = orderView.lbl_Item.frame;
        descriptionFrame.size.height = [self getLabelHeight:orderView.lbl_Item];
        NSLog(@"%f",[self getLabelHeight:orderView.lbl_Item]);
        orderView.lbl_Item.frame = descriptionFrame;
        height = 50 + descriptionFrame.size.height;
        NSLog(@"height %f",height);

        [orderView setFrame:CGRectMake(0,floteValue, 265, height)];
        [cell.orderScrollView addSubview:orderView];
        floteValue = floteValue+orderView.frame.size.height+10;

    }
    NSLog(@"scroll height=%f",cell.orderScrollView.frame.size.height);
    NSLog(@"scroll height=%f",floteValue);

    [cell.orderScrollView setFrame:CGRectMake(cell.timeTableView.frame.origin.x,cell.timeTableView.frame.origin.y+cell.timeTableView.frame.size.height, cell.orderScrollView.frame.size.width, self.view.frame.size.height-235)];
    [cell.orderScrollView setContentSize:CGSizeMake(0, floteValue)];

    NSString *string = [dict_Result objectForKey:@"order_date"];
    NSArray *arr = [string componentsSeparatedByString:@" "];
    NSString *str_Time = [arr objectAtIndex:1];
    NSLog(@"Time %@",str_Time);
    cell.lbl_Time.text = str_Time;
    NSString *str_userId = [dict_Result objectForKey:@"users_id"];
    
    if(! str_userId.length){
        cell.lbl_Table.text = [dict_Result objectForKey:@"user_token"];
    }
    else{
        NSString *str_fname = [dict_Result objectForKey:@"fname"];
        NSString *str_lname = [dict_Result objectForKey:@"lname"];
       // NSString *str_name = [str_fname stringByAppendingString:str_lname];
        NSString *str_name = [[str_fname stringByAppendingString:@" "] stringByAppendingString:str_lname];
        NSLog(@"name %@", str_name);
        cell.lbl_Table.text = str_name;
    }
    //NSString *strA = @" QTY :  ";
    
    //cell.lbl_HeadCount.text = [strA stringByAppendingString:[dict_Result objectForKey:@"meal_quantity"]];
    
    if(!str_userId.length){
        NSString *colorCode = [dict_Result objectForKey:@"color_code"];
        if ([colorCode isKindOfClass:[NSNull class]]) {
            cell.backgroundColor = [self colorWithHexString:@"E6E6E6"];
        }else{
            cell.backgroundColor = [self colorWithHexString:[dict_Result objectForKey:@"color_code"]];
        }
    }
    
    else
    {
        cell.backgroundColor = [self colorWithHexString:@"E6E6E6"];
    }
    
//    cell.lbl_Item.text     = [self getItemDetails:[dict_Result objectForKey:@"order_details"]];
//    CGRect descriptionFrame = cell.lbl_Item.frame;
//    descriptionFrame.size.height = [self getLabelHeight:cell.lbl_Item];
//    NSLog(@"%f",[self getLabelHeight:cell.lbl_Item]);
//    cell.lbl_Item.frame = descriptionFrame;

//    height = 90 + descriptionFrame.size.height;
//
//    NSLog(@"height  %f",height);
//
    [cell setFrame:CGRectMake(width, 0, 280, floteValue+40)];
    CGRect frameCell = cell.frame;
    frameCell.size.height = floteValue+40;
    cell.frame = frameCell;
    
    width = width+cell.frame.size.width +10;
    NSLog(@"width  %f",width);
    [collectionView setContentSize:CGSizeMake(width, 0)];
    
    //[cell.orderScrollView setFrame:CGRectMake(cell.timeTableView.frame.origin.x,cell.timeTableView.frame.origin.y+cell.timeTableView.frame.size.height, cell.orderScrollView.frame.size.width, floteValue)];
    //[cell.orderScrollView setContentSize:CGSizeMake(0, floteValue+height+30)];
    //collectionView.frame = CGRectMake(0, 0, width, floteValue);
    collectionView.frame = CGRectMake(0, 0, width, self.view.frame.size.height-80);
    scrollV.contentSize = CGSizeMake(width, 0);

//    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(deleteCell:)];
//    swipe.direction = UISwipeGestureRecognizerDirectionUp;
 //   cell.userInteractionEnabled = YES;
 //   [cell addGestureRecognizer:swipe];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCell:)];
    cell.userInteractionEnabled = YES;
    [cell addGestureRecognizer:longPressRecognizer];
    
    NSLog(@"%ld",cell.tag);
    
    return cell;
}

-(void) deleteCell : (UILongPressGestureRecognizer*) swipeGesture{
    
//    CGPoint location = [swipeGesture locationInView:_riceCollectionVw];
//    
//    NSIndexPath *indexPath = [_riceCollectionVw indexPathForItemAtPoint:location];
//    
//    NSLog(@"%ld",swipeGesture.view.tag);
    
//    RiceCollectionViewCell *cell = (RiceCollectionViewCell*) [_riceCollectionVw cellForItemAtIndexPath:[NSIndexPath indexPathForRow:swipeGesture.view.tag inSection:0]];
    if (swipeGesture.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        //Do Whatever You want on Began of Gesture
        cellDelete = (RiceCollectionViewCell  *)swipeGesture.view;
        [self alertViewMessage:@"Successfully Completed"];
    }
   
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(width, floteValue);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);

}


- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}


- (IBAction)btnBackAction:(id)sender {
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIColor *)colorWithHexString:(NSString *)hexString
{
    unsigned int hex;
    [[NSScanner scannerWithString:hexString] scanHexInt:&hex];
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

-(NSMutableString *)getItemDetails:(NSArray *) itemDetails{
    
    NSLog(@"Items %@", itemDetails);
    
    NSMutableString *str_Item = [NSMutableString string];
    NSDictionary *dict;
    NSString *str,*str_attributes;
    for (int i = 0; i< itemDetails.count; i++) {
        
        dict = [itemDetails objectAtIndex:i];
        
        NSLog(@"dict >>> %@",dict);
        
        str = [dict objectForKey:@"name"];
        str_attributes  = [dict objectForKey:@"product_attribute"];
        if([str_attributes length] > 0)
        {
            str = [NSString stringWithFormat:@"%@ (%@)",[dict objectForKey:@"name"],[dict objectForKey:@"product_attribute"]];
        }
        [str_Item appendFormat:@"%@\n",str];
        
    }
    return str_Item;
    
}

-(void)alertViewMessage:(NSString *) message{
    
    alertVw = [[exclamationAlert alloc] init];
    alertVw.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    alertVw.alertDelegate = self;
    [self.view addSubview:alertVw ];
    alertVw.lbl_alertMessage.text = message;
    
}

-(void)alertActionForSuccess{
    willUpdate = NO;
    [appDelegate startHUDInView:self.view];
    NSString *str_orderId;
    NSDictionary *dict = [_arrResult objectAtIndex:cellDelete.tag];
    NSLog(@"dict  %@", dict);
    
    str_orderId = [dict objectForKey:@"id"];
    
    NSLog(@"str_orderId  %@",str_orderId);
    
    NSDictionary *orderDict = @{@"lanid" : @"1",
                                @"orderid" : str_orderId,
                                @"deliverystatus" : @"5" };
    
    NSLog(@"orderDict  %@",orderDict);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager POST:ChangeOrderStatus_URL parameters:orderDict progress:nil success:^(NSURLSessionTask *task, id resPonceObject){
            NSDictionary *responseDict = (NSDictionary*)resPonceObject;
            
            
            NSString *strStatus = [responseDict objectForKey:@"status"];
            
            NSLog(@"status %@",strStatus);
            NSLog(@"responseDict %@",responseDict);
            if ([strStatus intValue] == 1) {
                [_arrResult removeObjectAtIndex:cellDelete.tag];
                
                [UIView animateWithDuration:1.0 animations:^{
                    
                    //      cell.frame = CGRectMake(0, -cell.frame.size.height, cell.frame.size.width, cell.frame.size.height);
                    cellDelete.frame = CGRectMake(cellDelete.frame.origin.x, -cellDelete.frame.size.height, cellDelete.frame.size.width, cellDelete.frame.size.height);
                    
                } completion:^(BOOL finished) {
                    width = 0;
                    [_riceCollectionVw reloadData];
                    willUpdate = YES;
                }];
            }
            else if([strStatus intValue] == 0){
                
            }
            [appDelegate stopHUD];
        }failure:^(NSURLSessionTask *myOpration, NSError *error){
            NSLog(@"error=%@",error);
            [appDelegate stopHUD];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}
-(void)getOrderListforChefUpdate
{
    if (!willUpdate)
        return;
//    NSLog(@"dfdsfsddddddddddddddddddddd");
    [appDelegate startHUDInView:self.view];
    
    NSDictionary *dict = @{@"lanid" : @"1",
                            };//@"pcatid" : _btn_itemId
    
    NSLog(@"dict %@",dict);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager POST:ORDERLISTFORCHEF_URL parameters:dict progress:nil success:^(NSURLSessionTask *task, id resPonceObject){
            NSDictionary *responseDict = (NSDictionary*)resPonceObject;
            
            resultArray = [responseDict objectForKey:@"result"];
            NSDictionary *resultDict;
            for(int i = 0; i<resultArray.count;i++){
                
                resultDict = [resultArray objectAtIndex:i];
            }
            
            NSString *strStatus = [responseDict objectForKey:@"status"];
            
            NSLog(@"status %@",strStatus);
            NSLog(@"responseDict %@",responseDict);
            NSLog(@"Result %@", resultArray);
           
            
            
            if ([strStatus intValue] == 1) {
                
                
                [_arrResult removeAllObjects];
                
                _arrResult =  [resultArray mutableCopy];
                
                NSLog(@"ArrResult  %@",_arrResult);
                width = 0;
                [_riceCollectionVw reloadData];
                
                [self alertViewToastMessage:@"Order Updated"];
            }
            
            else if([strStatus intValue] == 0){
                
                //           [ConstantClass alert:@"" message:@"Invalid Login"];
                
            }
            
            
            [appDelegate stopHUD];
            
            
            
        }failure:^(NSURLSessionTask *myOpration, NSError *error){
            NSLog(@"error=%@",error);
            [appDelegate stopHUD];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        
    });
}

// Toast Alert

-(void)alertViewToastMessage:(NSString *) message{
    
    
    NSString *alert_message = message;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:alert_message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    int duration = 1; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}



@end
