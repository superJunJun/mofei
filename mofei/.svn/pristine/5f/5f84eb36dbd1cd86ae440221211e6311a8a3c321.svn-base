//
//  BaseTableViewController.h
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController : UITableViewController

@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (assign, nonatomic) UIRectEdge customEdgesForExtendedLayout;
@property (strong, nonatomic) NSString *titleText;
@property (assign, nonatomic) BOOL backButtonVisible;
- (void)popBackEventWillHappen;

@property (assign, nonatomic) CGPoint noticeBarCenter;
@property (assign, nonatomic) BOOL isNoticeStyleBlack;
- (void)setNoticeText:(NSString *)noticeText;

- (void)showProgressHUDWithLabelText:(NSString *)text;
- (void)showProgressCompleteWithLabelText:(NSString *)text isSucceed:(BOOL)isSucceed;
- (void)showProgressCompleteWithLabelText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object;
- (void)hiddenProgressHUD;

- (BOOL)networkIsValid;
- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result;
- (void)postURLRequestWithMessageCode:(NSUInteger)msgCode
                         HUDLabelText:(NSString *)text
                               params:(NSMutableDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completeBlock;

- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;

@end
