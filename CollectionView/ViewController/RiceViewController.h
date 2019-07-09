//
//  RiceViewController.h
//  CollectionView
//
//  Created by Arka Banerjee on 17/08/17.
//  Copyright © 2017 Arka Banerjee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RiceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *riceCollectionVw;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (strong, nonatomic) NSMutableArray *arrResult;
@property (strong, nonatomic) NSString *selectedRoomId;


@end
