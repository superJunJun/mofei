//
//  BONoticeBar.h
//
//  单行文字弹出提示条
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BONoticeBarStyle)
{
    BONoticeBarStyleBlack = 0, //黑底白字，默认风格
    BONoticeBarStyleWhite = 1  //白底黑字
};

@interface BONoticeBar : NSObject

@property (strong, nonatomic) NSString *noticeText;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) BONoticeBarStyle style;

- (instancetype)initWithMasterView:(UIView *)masterView;

@end
