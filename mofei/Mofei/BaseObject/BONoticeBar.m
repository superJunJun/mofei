//
//  BONoticeBar.m
//
//  单行文字弹出提示条
//

#import "BONoticeBar.h"

#define nNoticeTextBarHoldDuration      3.0f

//BONoticeTextView

typedef NS_ENUM(NSInteger, BONoticeTextViewStatus)
{
    BONoticeTextViewStatusNone = 0,
    BONoticeTextViewStatusShowing,
    BONoticeTextViewStatusShowComplete,
    BONoticeTextViewStatusHiding,
    BONoticeTextViewStatusHideComplete
};

@class BONoticeTextView;
@protocol BONoticeTextViewDelegate <NSObject>
@required
- (void)noticeTextViewHideActionComplete:(BONoticeTextView *)view;
@end

@interface BONoticeTextView : UIView

@property (nonatomic) BONoticeTextViewStatus status;
@property (nonatomic) CGPoint centerPoint;
@property (strong, nonatomic) NSTimer *hideTimer;
//interface
@property (nonatomic) BOOL shouldHideImmediately;
@property (assign, nonatomic) id<BONoticeTextViewDelegate> delegate;
- (instancetype)initWithNoticeText:(NSString *)noticeText
                             style:(BONoticeBarStyle)style
                            center:(CGPoint)center;
- (void)noticeTextBarShow;
- (void)noticeTextBarHide;

@end

@implementation BONoticeTextView

- (instancetype)initWithNoticeText:(NSString *)noticeText
                             style:(BONoticeBarStyle)style
                            center:(CGPoint)center
{
    if(self = [super init])
    {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.shouldHideImmediately = NO;
        self.status = BONoticeTextViewStatusNone;
        self.centerPoint = center;
        
        UIFont *textFont = [UIFont systemFontOfSize:12];
        UIColor *textColor = [UIColor whiteColor];
        UIColor *bgViewShadowColor = [UIColor blackColor];
        if(style == BONoticeBarStyleWhite)
        {
            textColor = [UIColor blackColor];
            bgViewShadowColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        }
        
        UILabel *textLabel = [UILabel new];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.origin = CGPointMake(6, 4);
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = textFont;
        textLabel.textColor = textColor;
        textLabel.text = noticeText;
        [textLabel sizeToFit];
        [self addSubview:textLabel];
        
        CGRect frame = CGRectMake(0, 0, textLabel.width + 11, textLabel.height + 8);
        UIView *bgView = [[UIView alloc] initWithFrame:frame];
        bgView.backgroundColor = bgViewShadowColor;
        bgView.layer.cornerRadius = 4;
        bgView.layer.shadowOffset = CGSizeMake(3, 3);
        bgView.layer.shadowOpacity = 0.9;
        bgView.layer.shadowRadius = 1.0;
        bgView.layer.shadowColor = [UIColor grayColor].CGColor;
        bgView.alpha = 0.8;////
        [self insertSubview:bgView belowSubview:textLabel];
        
        self.frame = frame;
    }
    return self;
}

#pragma mark - OverrideSettingMethod

- (void)setShouldHideImmediately:(BOOL)shouldHideImmediately
{
    _shouldHideImmediately = shouldHideImmediately;
    if(shouldHideImmediately)
    {
        if(self.status != BONoticeTextViewStatusHiding
           && self.status != BONoticeTextViewStatusHideComplete)
        {
            self.status = BONoticeTextViewStatusHiding;
            [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(noticeTextBarHide) userInfo:nil repeats:NO];
        }
    }
}

#pragma mark - VisibleAction

- (void)hideTimerCancel
{
    if([self.hideTimer isValid])
    {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

- (void)noticeTextBarHide
{
    [self hideTimerCancel];
    self.status = BONoticeTextViewStatusHiding;
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.35 animations:^{
                         wself.alpha = 0;
        }completion:^(BOOL finished) {
            if(finished)
            {
                self.status = BONoticeTextViewStatusHideComplete;
                [wself.delegate noticeTextViewHideActionComplete:wself];
            }
    }];
}

- (void)noticeTextBarShow
{
    [self hideTimerCancel];
    self.alpha = 0;
    self.status = BONoticeTextViewStatusShowing;
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:nNoticeTextBarHoldDuration target:self selector:@selector(noticeTextBarHide) userInfo:nil repeats:NO];
    [self.superview bringSubviewToFront:self];
    [self appendShowAnimation];
}

- (void)appendShowAnimation
{
    CGPoint aimPoint = self.centerPoint;
    self.center = CGPointMake(aimPoint.x, aimPoint.y + 60);
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25 animations:^{
        wself.alpha = 1;
        wself.center = CGPointMake(aimPoint.x, aimPoint.y - 8);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            wself.center = CGPointMake(aimPoint.x, aimPoint.y + 2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                wself.center = aimPoint;
            } completion:^(BOOL finished) {
                if(finished)
                {
                    wself.status = BONoticeTextViewStatusShowComplete;
                    if(wself.shouldHideImmediately)
                    {
                        wself.shouldHideImmediately = YES;
                    }
                }
            }];
        }];
    }];
}

@end

//BONoticeBar
@interface BONoticeBar () <BONoticeTextViewDelegate>

@property (strong, nonatomic) NSMutableArray *noticeTextViews;
@property (weak, nonatomic) UIView *masterView;

@end

@implementation BONoticeBar

- (instancetype)initWithMasterView:(UIView *)masterView
{
    if(self = [super init])
    {
        self.masterView = masterView;
        self.noticeTextViews = [NSMutableArray new];
    }
    return self;
}

#pragma mark - BONoticeTextViewDelegate

- (void)noticeTextViewHideActionComplete:(BONoticeTextView *)view
{
    [view removeFromSuperview];
    [self.noticeTextViews removeObject:view];
}

#pragma mark - OverrideSettingMethod

- (void)noticeTextViewsAppendOneView:(BONoticeTextView *)view
{
    for(BONoticeTextView *noticeTextView in self.noticeTextViews)
    {
        noticeTextView.shouldHideImmediately = YES;
    }
    [self.noticeTextViews addObject:view];
}

- (void)setNoticeText:(NSString *)noticeText
{
    _noticeText = noticeText;
    if(noticeText.length > 0)
    {
        BONoticeTextView *noticeTextView = [[BONoticeTextView alloc] initWithNoticeText:noticeText style:self.style center:self.centerPoint];
        [self.masterView addSubview:noticeTextView];
        [self noticeTextViewsAppendOneView:noticeTextView];
        [noticeTextView noticeTextBarShow];
    }
}

@end
