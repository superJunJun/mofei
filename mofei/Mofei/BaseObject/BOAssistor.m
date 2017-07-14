//
//  BOAssistor.m
//
//  常用的辅助功能
//

#import "BOAssistor.h"
#import "SvUDIDTools.h"
#import "NSString+MD5Addition.h"

@implementation BOAssistor

#pragma mark - Regular Expression

+ (BOOL)resourceString:(NSString *)resStr evalueWithPredicateRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:resStr];
}

+ (BOOL)personNameIsValid:(NSString *)name
{
    NSString *regex = @"^[\u4e00-\u9fa5]{2,15}$";
    return [self resourceString:name evalueWithPredicateRegex:regex];
}

+ (BOOL)postCodeIsValid:(NSString *)postCode
{
    NSString *regex = @"^[1-9]{1}(\\d+){5}$";
    return [self resourceString:postCode evalueWithPredicateRegex:regex];
}

+ (BOOL)cellPhoneNumberIsValid:(NSString *)cellPhoneNumber
{
    NSString *regex = @"^[1][3-8]\\d{9}$";
    return [self resourceString:cellPhoneNumber evalueWithPredicateRegex:regex];
}

+ (BOOL)emailIsValid:(NSString *)email
{
    NSString *regex = @"^(\\w)+(\\.\\w+)*@(\\w)+((\\.\\w+)+)$";
    return [self resourceString:email evalueWithPredicateRegex:regex];
}

+ (BOOL)usernameIsValidLocalFunc:(NSString *)username
{
    //NSString *regex = @"^[a-zA-Z|\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]{1,19}$";
    NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5]{2,20}$";
    return [self resourceString:username evalueWithPredicateRegex:regex];
}

+ (BOOL)usernameIsValid:(NSString *)username
{//字符开头，限4-20字符，1个汉字为2个字符
    int finalLength = (int)[self chineseCharactersLengthInString:username];
    if(finalLength >= 4 && finalLength <= 20)
    {
        return [self usernameIsValidLocalFunc:username];
    }
    return NO;
}

+ (BOOL)phoneNumberIsValid:(NSString *)phoneNumber
{
    //NSString *regex = @"^(([1][3-8]\\d{9})|((\\d{3}-\\d{8})|(\\d{4}-\\d{7})))$";
    NSString *regex = @"^(([1][3-8]\\d{9})|([0][1-9]{2}-\\d{8})|([0][1-9]{2}\\d{8})|([0][1-9]{3}\\d{7})|([0][1-9]{3}-\\d{7})|([1-9]\\d{7})|([1-9]\\d{6}))$";
    return [self resourceString:phoneNumber evalueWithPredicateRegex:regex];
}

+ (BOOL)passwordLengthIsValid:(NSString *)password
{//4~48
    return (password.length >= 6 && password.length <= 48);
}

+ (BOOL)passwordIsValid:(NSString *)password
{
    NSString *regex = @"[0-9a-zA-Z]{6,20}";
    return [self resourceString:password evalueWithPredicateRegex:regex];
}

+ (NSUInteger)chineseCharactersLengthInString:(NSString *)string
{
    NSUInteger len = string.length;
    // 汉字字符集
    NSString *pattern  = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    // 计算中文字符的个数
    NSInteger numMatch = [regex numberOfMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    return len + numMatch;
}

//@"/^[".chr(0xa1)."-".chr(0xff)."A-Za-z0-9_]+$/"   //GB2312汉字字母数字下划线正则表达式
//@"/^[/x{4e00}-/x{9fa5}A-Za-z0-9_]+$/u"            //UTF-8汉字字母数字下划线正则表达式

//+ (NSUInteger)chineseCharactersLengthInString:(NSString *)string
//{
//    NSUInteger totalLength = string.length;
//    NSCharacterSet *chineseCharacterSet = [NSCharacterSet characterSetWithRange:NSMakeRange(19968, 20901)];/*\u4e00 - \u9fa5*/
//    NSArray *components = [string componentsSeparatedByCharactersInSet:chineseCharacterSet];
//
//    string = [NSString pathWithComponents:components];
//    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
//    return totalLength - string.length;
//}

+ (NSString *)stringTrim:(NSString *)resStr
{
    return [resStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font
{
    if([string respondsToSelector:@selector(sizeWithAttributes:)])
    {
        return [string sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    else
    {
        return [string sizeWithFont:font];
    }
}

+ (CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)mode
{
    if(string.length == 0)
    {
        return CGSizeZero;
    }
    
    CGSize limitedSize = CGSizeMake(width, MAXFLOAT);
    if([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        return [string boundingRectWithSize:limitedSize
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName:font}
                                    context:nil].size;
    }
    else
    {
        return [string sizeWithFont:font constrainedToSize:limitedSize lineBreakMode:mode];
    }
}

+ (NSString *)replaceSpaceByBlankStringWidth:(CGFloat)width font:(UIFont *)font
{
    if(width <= 0 || !font)
    {
        return @"";
    }
    NSMutableString *aimString = [@" " mutableCopy];
    CGSize size;
    while(TRUE)
    {
        size = [self string:aimString sizeWithFont:font];
        if(size.width >= width)
        {
            break;
        }
        [aimString appendString:@" "];
    }
    return aimString;
}

+ (BOOL)isImageFilePath:(NSString *)imagePath
{
    NSString *pathExtension = imagePath.pathExtension.lowercaseString;
    if([pathExtension isEqualToString:@"png"]
       || [pathExtension isEqualToString:@"jpg"]
       || [pathExtension isEqualToString:@"jpe"]
       || [pathExtension isEqualToString:@"jpeg"]
       || [pathExtension isEqualToString:@"gif"])
    {
        return YES;
    }
    return NO;
}

+ (NSInteger)randomNumberBetweenNumber:(NSInteger)num1 andNumber:(NSInteger)num2
{
    if(num1 > num2)
    {
        //swap
        num1 += num2;
        num2 = num1 - num2;
        num1 = num1 - num2;
    }
    return arc4random() % (num2 - num1 + 1) + num1;
}

#pragma mark - Supported Font

+ (void)supportedFontsInfoPrint
{
    NSMutableDictionary *infoDic = [NSMutableDictionary new];
    
    NSArray *familyNames = [UIFont familyNames];
    for(NSInteger i = 0; i < familyNames.count; i++)
    {
        NSString *fontFamilyName = familyNames[i];
        [infoDic setValue:[UIFont fontNamesForFamilyName:fontFamilyName] forKey:fontFamilyName];
    }
    NSLog(@"supportedFontFamilyNamesCount:%ld\n%@", (long)familyNames.count, infoDic);
}

#pragma mark - NavigationBarButtonItem Create

+ (UIBarButtonItem *)barButtonItemCreateWithImage:(UIImage *)image
                                 highlightedImage:(UIImage *)imageH
                                           target:(id)target
                                           action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    if(imageH)
    {
        [button setImage:imageH forState:UIControlStateHighlighted];
    }
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemCreateWithImageName:(NSString *)imageName
                                 highlightedImageName:(NSString *)imageNameH
                                               target:(id)target
                                               action:(SEL)action
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageH = [UIImage imageNamed:imageNameH];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    if(imageH)
    {
        [button setImage:imageH forState:UIControlStateHighlighted];
    }
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

#pragma mark - Struct Show

+ (void)rangeShow:(NSRange)range withTitle:(NSString *)title
{
    NSLog(@"%@:(%d, %d)", title, (int)range.location, (int)range.length);
}

+ (void)rectangleShow:(CGRect)rect withTitle:(NSString *)title
{
    NSLog(@"%@:(%.2f, %.2f: %.2f, %.2f)", title, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

+ (void)pointShow:(CGPoint)point withTitle:(NSString *)title
{
    NSLog(@"%@:(%.2f, %.2f)", title, point.x, point.y);
}

+ (void)sizeShow:(CGSize)size withTitle:(NSString *)title
{
    NSLog(@"%@:(%.2f, %.2f)", title, size.width, size.height);
}

+ (void)indexPathShow:(NSIndexPath *)indexPath withTitle:(NSString *)title
{
    NSLog(@"%@:<%ld, %ld>", title, (long)indexPath.section, (long)indexPath.row);
}

+ (NSArray *)appUrlSchemes
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSArray *urlDics = [info objectForKey:@"CFBundleURLTypes"];
    NSDictionary *urlDic = urlDics[0];
    NSArray *urlSchemes = [urlDic objectForKey:@"CFBundleURLSchemes"];;
    
    return urlSchemes;
}

+ (NSString *)appShortVersionString
{
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    return info[@"CFBundleShortVersionString"];
}

+ (NSNumber *)appVersionNumber
{
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    return info[@"CFBundleNumericVersion"];
}

+ (NSString *)appBundleID
{
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    return info[@"CFBundleIdentifier"];
}

+ (NSString *)deviceUDID
{
    return [[SvUDIDTools UDID] MD5String];
}

//distance单位（米），返回值单位：公里
+ (NSString *)distanceStringWithDistance:(CGFloat)distance
{
    CGFloat templeDistance = distance / 1000;
    NSString *distanceString = @"";
    if(distance < 10)
    {
        distanceString = [NSString stringWithFormat:@"%.3f", templeDistance];
    }
    else if(distance < 100)
    {
        distanceString = [NSString stringWithFormat:@"%.2f", templeDistance];
    }
    else if(distance < 1000)
    {
        distanceString = [NSString stringWithFormat:@"%.1f", templeDistance];
    }
    else
    {
        distanceString = [NSString stringWithFormat:@"%ld", (long)templeDistance];
    }
    return distanceString;
}

+ (NSString *)charArrayToHexString:(char *)charArray length:(int)length
{
    NSMutableString *string = [NSMutableString new];
    if(length <= 0)
    {
        return @"0x0";
    }
    [string appendString:@"0x"];
    for(int i = 0; i < length; i++)
    {
        UInt8 oneChar = charArray[i];
        [string appendFormat:@"%02x ", oneChar];
    }
    return string;
}

@end
