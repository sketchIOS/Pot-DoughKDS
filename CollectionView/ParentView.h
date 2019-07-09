//
//  ParentView.h
//  InResturentOrder
//
//  Created by IOS DEVELOPER on 09/03/18.
//  Copyright © 2018 IOS DEVELOPER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgvMainCat;
@property (weak, nonatomic) IBOutlet UIControl *cntrlMainCat;
//-(void)initialSetUp:(NSDictionary*)catMainDetails;
@end
