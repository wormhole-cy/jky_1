//
//  RootViewController.m
//  SimpleCalculator
//
//  Created by admin on 13-8-14.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "RootViewController.h"
#import "Calculating.h"
@interface RootViewController ()

@end

@implementation RootViewController

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
	// Do any additional setup after loading the view.
    
    
    NSArray *buttonTitleArray = @[@"1",@"2",@"3",@"c",@"<-",@"4",@"5",@"6",@"+",@"-",
                                  @"7",@"8",@"9",@"*",@"/",@"(",@"0",@")",@".",@"=",
                                  @"^2",@"^3",@"%"];
    //用一个数组存放button的title值
    
    for (int i = 0; i < 23; i++) {
        static int x = 0;
        static int y = 0;
        if (x == 5) {
            x = 0;
            y++;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        CGRect frame = CGRectMake(30 + 55 * x, 200 + 55 * y, 45, 45);
        NSString *str = [buttonTitleArray objectAtIndex:i];
        [self buttonWithButton:button withFram:frame withTitle:str];
        x++;
    }
    
    self.displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, 290, 100)];
    self.displayLabel.backgroundColor = [UIColor lightGrayColor];
    self.displayLabel.text = @"";
    self.displayLabel.textColor = [UIColor blueColor];
    self.displayLabel.textAlignment = NSTextAlignmentRight;
    self.displayLabel.font = [UIFont fontWithName:@"Arial" size:30];
    [self.view addSubview:self.displayLabel];
    [self.displayLabel release];
}

-(void)buttonWithButton:(UIButton *)button withFram:(CGRect)frame withTitle:(NSString *)str
{
    button.frame = frame;
    button.backgroundColor = [UIColor blackColor];
    [button setTitle:str forState:UIControlStateNormal];
    [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
}
-(void)clickButtonAction:(UIButton *)button
{
    NSString *str1 = button.currentTitle;
    if ([str1 isEqualToString:@"c"]) { //按清除键
        self.displayLabel.text = [NSString string];
        return;
    }
    if ([str1 isEqualToString:@"<-"]) {//消除一位
        if ([self.displayLabel.text isEqualToString:@""]) {
            return;
        }
        NSInteger count = [self.displayLabel.text length];
        NSString *string = [self.displayLabel.text substringToIndex:count - 1];
        self.displayLabel.text = string;
        return;
    }
    if ([str1 isEqualToString:@"="]) {
        NSString *labelString = self.displayLabel.text;
        if ([labelString isEqualToString:@""]) {
            return;
        }
        NSLog(@"string:%@",labelString);
        calcuteDelegate= [[Calculating alloc] init];
        self.displayLabel.text = [calcuteDelegate calculatingWithString:labelString];
        [calcuteDelegate release];
        return;
    }
    NSString *str2 = [self.displayLabel.text stringByAppendingString:str1];
    self.displayLabel.text = str2;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
