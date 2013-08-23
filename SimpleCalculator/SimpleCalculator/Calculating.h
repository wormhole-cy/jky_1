//
//  Calculating.h
//  SimpleCalculator
//
//  Created by admin on 13-8-14.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calculating : NSObject 

@property (nonatomic, retain) NSMutableArray *array;
@property (nonatomic, retain) NSDictionary *priority;
-(NSString *)calculatingWithString:(NSString *)str;

@end

