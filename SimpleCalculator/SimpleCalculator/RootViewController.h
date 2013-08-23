//
//  RootViewController.h
//  SimpleCalculator
//
//  Created by admin on 13-8-14.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Calculating;
@interface RootViewController : UIViewController
{
    Calculating *calcuteDelegate;
}
@property (nonatomic, retain) UILabel *displayLabel;

-(void)buttonWithButton:(UIButton *)button withFram:(CGRect)frame withTitle:(NSString *)str;
@end
