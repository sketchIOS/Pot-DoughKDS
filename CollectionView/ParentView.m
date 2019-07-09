//
//  ParentView.m
//  InResturentOrder
//
//  Created by IOS DEVELOPER on 09/03/18.
//  Copyright © 2018 IOS DEVELOPER. All rights reserved.
//

#import "ParentView.h"

@implementation ParentView
-(id)init{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ParentView" owner:nil options:nil];
    self=[nib lastObject];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
