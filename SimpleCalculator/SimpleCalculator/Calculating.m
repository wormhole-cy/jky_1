//
//  Calculating.m
//  SimpleCalculator
//
//  Created by admin on 13-8-14.
//  Copyright (c) 2013年 admin. All rights reserved.
//

#import "Calculating.h"



@implementation Calculating

-(id)init
{
    if (self = [super init]) {
        self.priority = @{@"(": @0,@"^":@1,@"%":@2,@"*": @3, @"/": @3, @"+": @4, @"-": @4, @")": @5,  @"e": @6};
        //运算符优先级表
    }
    return self;
}

-(NSString *)calculatingWithString:(NSString *)str
{
    void (^block1)(NSString *str) = ^(NSString *str) {  //该方法用于将label读取的字符串进行拆分处理，并存放到数组中；比如5-（8+4）字符串存放到数组的形式是：(5,"-","(",8,"+",4,")")
        NSInteger length = [str length];
        self.array = [NSMutableArray array];
        
        NSInteger i = 0;
        UniChar c = [str characterAtIndex:0];
        if (c == '-' || c == '+') {//以正负号开头的情况，在正负号之前补充0，再存放如数组；比如-7开头就要变成0-7
            if (length > 1) {
                UniChar c1 = [str characterAtIndex:1];
                if (c1 >= '0' && c1 <= '9') {
                    [self.array addObject:@"0"];
                    [self.array addObject:[NSString stringWithCharacters:&c length:1]];
                    i++;
                }
            }
        }
        NSMutableString *mString = [NSMutableString string];
        while (i < length)
        {
            c = [str characterAtIndex:i];
            if ((c >= '0' && c <= '9') || c == '.')
            {//遇到数字，就要读取整个数，包括小数点，读取完整后再存入数组中
                [mString appendFormat:@"%c",c];
                if (i == length - 1) {
                    [self.array addObject:mString];
                    mString = [NSMutableString string];
                }
            }
            else
            {
                if (![mString isEqualToString:@""]) {//将完整的数存放到数组中
                    [self.array addObject:mString];
                    mString = [NSMutableString string];
                }
                if (c == '(')
                {
                    if (i > 0)
                    {
                        UniChar xc = [str characterAtIndex:i - 1];
                        if (xc >= '0' && xc <= '9') {  //"7（8+2）"这种省略乘号的写法，要将乘号补充完整
                            [self.array addObject:@"*"];
                            [self.array addObject:@"("];
                            i++;
                            continue;
                        }
                    }
                    if (i < length - 1)
                    {
                        UniChar c1 = [str characterAtIndex:i+1];
                        if (c1 == '-' || c1 == '+') {  //"(-7)+6"这种带正负号的数的情况，要补充0；变成(0-7)+6
                            [self.array addObject:@"("];
                            [self.array addObject:@"0"];
                            i++;
                            continue;
                        }
                    }
                }
                else if (c == ')')
                {
                    if (i < length - 1)
                    {
                        UniChar xc = [str characterAtIndex:i + 1];
                        if (xc >= '0' && xc <= '9') {  //"(3+4)7"这种省略乘号的情况，同样补充乘号变成"(3+4)*7"
                            [self.array addObject:@")"];
                            [self.array addObject:@"*"];
                            i++;
                            continue;
                        }
                    }
                }
                [self.array addObject:[NSString stringWithCharacters:&c length:1]];
            }
            i++;
        }
        [self.array insertObject:@"(" atIndex:0];
        [self.array addObject:@")"];//存完表达式之后，整个表达式用一对()括起来，为了方便处理
    };
    
    NSString *(^block2)(NSString *str, double x1, double x2) = ^(NSString *str, double x1, double x2)
    {//进行不带任何括号的二元字符串表达式计算，返回运算结果;如8-4
        double aresult = 0;
        unichar ch = [str characterAtIndex:0];
        NSString *string = [NSString string];
        BOOL isOK = YES;
        switch (ch) {
            case '+':
                aresult = x1 + x2;
                break;
            case '-':
                aresult = x1 - x2;
                break;
            case '*':
                aresult = x1 * x2;
                break;
            case '/':
                if (x2 == 0) {
                    string = @"error";
                    isOK = NO;
                }
                aresult = x1 / x2;
            case '^':
                if (x2 == 2) {
                    aresult = x1 * x1;
                }
                else
                    aresult = x1 * x1 * x1;
                break;
            case '%':
                aresult = (int)x1 % (int)x2;
                break;
            default:
                isOK = NO;
                string = @"error";
                break;
        }
        if (isOK == YES) {
            string = [NSString stringWithFormat:@"%f",aresult];
        }
        return string;
    };
    
    
    NSString * (^block3)(NSMutableArray *arr) = ^(NSMutableArray *arr)
    {//传进一个不带括号的表达式数组，进行合法性判断，并对合法的表达式计算结果，返回计算结果
        NSMutableArray *stack1 = [NSMutableArray arrayWithObject:@"error"];//运算数栈，栈底元素设置为error，用于判断合法性
        NSMutableArray *stack2 = [NSMutableArray arrayWithObject:@"e"];//运算符栈，栈底元素设置为e，最小优先级运算符，方便处理
        NSString *result = [NSString string];
        [arr addObject:@"e"];//在表达式最后面添加一个e运算符，方便处理
        while (1)
        {//绝对循环，知道运算结果出来或者不合法
            NSString *subStr1 = [arr objectAtIndex:0];//获取表达式数组中的第一个元素
            UniChar c = [subStr1 characterAtIndex:[subStr1 length] - 1];
            if (c >= '0' && c <= '9') {//如获取的元素是运算数就直接进到运算数栈
                [stack1 insertObject:subStr1 atIndex:0];//插到栈顶
                [arr removeObjectAtIndex:0];//元素每次进栈之后要在数组中移除该元素
            }
            else
            {//元素是运算符，则每次都要跟运算符栈的栈顶元素比较优先级
                NSString *topStack2 = [stack2 objectAtIndex:0]; //取得运算符栈栈顶元素
                if ([subStr1 isEqualToString:@"e"] && [topStack2 isEqualToString:@"e"]) {//当取得元素和栈顶元素都为e时，说明表达式运算结束，获取运算结果
                    result = [stack1 objectAtIndex:0];
                    break;
                }
                NSInteger one = [[self.priority objectForKey:subStr1] integerValue];//对取得的元素在优先级表中获取优先级
                NSInteger two = [[self.priority objectForKey:topStack2] integerValue];//对栈顶元素在优先级表中获取优先级
                if (one < two) {//取得的运算符的优先级大于栈顶元素优先级时，该运算符直接进栈
                    [stack2 insertObject:subStr1 atIndex:0];
                    [arr removeObjectAtIndex:0];
                }
                else
                {//优先级不大的时候，就要取栈顶运算符先进行运算
                    
                    //先取两个运算数，如果取到error说明，表达式输入不合法，直接终止循环
                    NSString *strX = [stack1 objectAtIndex:0];
                    if ([strX isEqualToString:@"error"]) {
                        result = @"error";
                        break;
                    }
                    double x1 = [strX doubleValue];
                    [stack1 removeObjectAtIndex:0];
                    strX = [stack1 objectAtIndex:0];
                    if ([strX isEqualToString:@"error"]) {
                        result = @"error";
                        break;
                    }
                    double x2 = [strX doubleValue];
                    [stack1 removeObjectAtIndex:0];
                    [stack2 removeObjectAtIndex:0];
                    //计算结果
                    result = block2(topStack2, x2, x1);
                    if ([result isEqualToString:@"error"]) {//如果计算返回的结果是error说明输入的表达式不合法
                        break;
                    }
                    [stack1 insertObject:result atIndex:0];//返回合法结果，就将结果放进运算数栈，进行下一轮处理
                }
            }
        }
        return result;
    };
    
    
    
    block1(str);//将表达式从字符串变成数组
    [self.array addObject:@"e"];
    [self.array insertObject:@"e" atIndex:0];
    //数组头部和尾部插入e，方便处理
    NSLog(@"%@",self.array);
    
    
    NSInteger count = [self.array count];
    NSString *finalResult = [NSString string];
    
    //从表达式尾部向前找，遇到“(”就用i标记该位置，再从该位置向尾部找配对的第一个“)”，将括号里面的子表达式，取出来进行合法性判断和计算结果处理，将结果返回并代替原表达式（包括一对括号也一起被取代）
    for (NSInteger i = count - 2; i >= 0; i--)
    {
        NSString *str1 = [self.array objectAtIndex:i];
        if ([str1 isEqualToString:@"e"])
        {//遇到e的时候就判断是不是表达式数组为("e",5,"e")形式，如果是则5就是最终的结果，如果不是则说明原表达式不合法
            finalResult = [self.array objectAtIndex:1];
            if ([self.array count] > 3) {
                finalResult = @"error";
            }
            return finalResult;
        }
        if ([str1 isEqualToString:@"("])
        {//遇到了"("就向尾部寻找配对括号，找不到配对括号，说明表达式不合法
            NSString *subResult = [NSString string];
            for (NSInteger j = i + 1; j <= count - 1; j++)
            {
                NSString *str2 = [self.array objectAtIndex:j];
                if ([str2 isEqualToString:@"e"]) {//找不到配对括号
                    finalResult = @"error";
                    return finalResult;
                }
                if ([str2 isEqualToString:@")"])
                {
                    NSRange range = NSMakeRange(i+1, j-i-1);
                    //生成子数组，生成的子数组肯定不存在括号问题
                    NSArray *subArray = [self.array subarrayWithRange:range];
                    NSMutableArray *arr = [NSMutableArray arrayWithArray:subArray];
                    subResult = block3(arr);
                    if ([subResult isEqualToString:@"error"]) {
                        finalResult = @"error";
                        return finalResult;
                    }
                    //将返回结果代替表达式，包括括号一起代替
                    range = NSMakeRange(i, j - i +1);
                    [self.array replaceObjectsInRange:range
                                 withObjectsFromArray:[NSArray arrayWithObject:subResult]];
                    count = [self.array count];//代替之后，重新获取新表达式的count
                    break;
                }
            }
        }
    }
    return finalResult;
}

@end
