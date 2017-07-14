//
//  TYDTopRightCornerMenuView.h
//

#import <UIKit/UIKit.h>

@protocol TYDTopRightCornerMenuViewDelegate <NSObject>
@optional
- (void)menuItemTappedWithItemIndex:(NSUInteger)itemIndex;
@end

@interface TYDTopRightCornerMenuView : UIView

@property (nonatomic) BOOL isBackgroundDark;
@property (nonatomic) BOOL hideWhenTapOutside;
@property (nonatomic, readonly) NSUInteger menuItemsCount;
@property (nonatomic) id<TYDTopRightCornerMenuViewDelegate> delegate;

- (instancetype)init;
- (void)appendMenuItemImage:(UIImage *)itemImage itemTitle:(NSString *)itemTitle;
- (void)menuViewShow;
- (void)menuViewHide;
- (void)menuViewSwitchVisibleState;

@end
