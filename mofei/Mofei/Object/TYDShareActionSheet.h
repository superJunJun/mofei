//
//  TYDShareActionSheet.h
//
//  视图截图保存分享的ActionSheet
//

#import <UIKit/UIKit.h>

@class TYDShareActionSheet;
@protocol TYDShareActionSheetDelegate <NSObject>
@optional
- (void)screenShotImageSaveToAlbumWillBegin;
- (void)screenShotImageSaveToAlbumComplete:(BOOL)succeed;
@end

@interface TYDShareActionSheet : NSObject
//如果底层视图为

+ (instancetype)defaultSheet;
- (void)setDelegate:(UIViewController<TYDShareActionSheetDelegate> *)delegate screenShotView:(UIView *)screenShotView;
- (void)actionSheetShow;
- (void)actionSheetDismiss;

@end
