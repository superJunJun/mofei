//
//  TYDTopRightCornerMenuView.m
//

#import "TYDTopRightCornerMenuView.h"

@interface TYDTopRightCornerMenuView ()

@property (strong, nonatomic) UIView *bgLayerView;
@property (strong, nonatomic) UIView *menuBaseView;
@property (strong, nonatomic) NSMutableArray *menuItems;

@end

@implementation TYDTopRightCornerMenuView

- (instancetype)init
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        
        UIControl *bgLayerView = [UIControl new];
        bgLayerView.backgroundColor = [UIColor clearColor];
        [bgLayerView addTarget:self action:@selector(tapOutside:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgLayerView];
        
        UIView *menuBaseView = [UIView new];
        menuBaseView.size = [self.class menuItemSize];
        menuBaseView.backgroundColor = [UIColor colorWithHex:0x666666];
        menuBaseView.layer.cornerRadius = 3;
        menuBaseView.layer.masksToBounds = YES;
        [self addSubview:menuBaseView];
        
        self.bgLayerView = bgLayerView;
        self.menuBaseView = menuBaseView;
        self.menuItems = [NSMutableArray new];
        self.hideWhenTapOutside = YES;
        self.isBackgroundDark = YES;
        self.hidden = YES;
    }
    return self;
}

- (UIView *)menuItemCreateWithTitle:(NSString *)title andImage:(UIImage *)itemImage
{
    CGRect frame = CGRectZero;
    frame.size = [self.class menuItemSize];
//    UILabel *menuItem = [[UILabel alloc] initWithFrame:frame];
//    menuItem.backgroundColor = [UIColor clearColor];
//    menuItem.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
//    menuItem.textColor = [UIColor whiteColor];
//    menuItem.textAlignment = NSTextAlignmentCenter;
//    menuItem.text = title;
    
    UIButton *menuItem = [[UIButton alloc] initWithFrame:frame];
    menuItem.backgroundColor = [UIColor clearColor];
    menuItem.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
    [menuItem setTitle:title forState:UIControlStateNormal];
    [menuItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [menuItem setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [menuItem addTarget:self action:@selector(tapOnMenuItem:) forControlEvents:UIControlEventTouchUpInside];
    
    if(itemImage)
    {
        UIImageView *itemIcon = [[UIImageView alloc] initWithImage:itemImage];
        itemIcon.center = menuItem.innerCenter;
        itemIcon.left = 12;
        [menuItem addSubview:itemIcon];
    }
    
//    menuItem.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMenuItem:)];
//    [menuItem addGestureRecognizer:tapGr];
    
    return menuItem;
}

- (void)appendMenuItemImage:(UIImage *)itemImage itemTitle:(NSString *)itemTitle
{
    UIView *menuItem = [self menuItemCreateWithTitle:itemTitle andImage:itemImage];
    [self.menuItems addObject:menuItem];
    
    self.menuBaseView.height = menuItem.height * self.menuItems.count;
    menuItem.bottom = self.menuBaseView.height;
    [self.menuBaseView addSubview:menuItem];
}

#pragma mark - OverrideSettingMethod

- (void)setIsBackgroundDark:(BOOL)isBackgroundDark
{
    _isBackgroundDark = isBackgroundDark;
    if(isBackgroundDark)
    {
        self.bgLayerView.backgroundColor = [UIColor colorWithHex:0x0 andAlpha:0.2];
    }
    else
    {
        self.bgLayerView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - TouchEvent

- (void)tapOnMenuItem:(id)menuItem
{
    [self menuViewHide];
    if([self.delegate respondsToSelector:@selector(menuItemTappedWithItemIndex:)]
       && [self.menuItems containsObject:menuItem])
    {
        [self.delegate menuItemTappedWithItemIndex:[self.menuItems indexOfObject:menuItem]];
    }
}

- (void)tapOutside:(id)sender
{
    if(self.hideWhenTapOutside)
    {
        [self menuViewHide];
    }
}

#pragma mark - Menu Visible Method

- (void)menuViewShow
{
    self.frame = self.superview.bounds;
    self.bgLayerView.frame = self.bounds;
    self.menuBaseView.topRight = CGPointMake(self.width, 0);
    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
}

- (void)menuViewHide
{
    self.hidden = YES;
}

- (void)menuViewSwitchVisibleState
{
    if(self.isHidden)
    {
        [self menuViewShow];
    }
    else
    {
        [self menuViewHide];
    }
}

#pragma mark - ClassMethod

+ (CGSize)menuItemSize
{
    return CGSizeMake(160, 34);
}

@end
