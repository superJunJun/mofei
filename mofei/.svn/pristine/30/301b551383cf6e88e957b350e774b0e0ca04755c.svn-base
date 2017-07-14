//
//  BaseTabBarController.m
//  Mofei
//
//  Created by macMini_Dev on 14-8-28.
//  Copyright (c) 2014年 Young. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()

@property (strong, nonatomic) NSArray *customTabBarItemIcons;
@property (strong, nonatomic) NSArray *customTabBarItemLabels;
@property (nonatomic) NSUInteger selectedItemIndex;

@end

@implementation BaseTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customTabBarLoad];
}

- (void)customTabBarLoad
{
    NSMutableArray *tabBarItemIcons = [NSMutableArray new];
    NSMutableArray *tabBarItemLabels = [NSMutableArray new];
    
    CGRect frame = self.tabBar.bounds;
    UIView *customTabBar = [[UIView alloc] initWithFrame:frame];
    customTabBar.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:customTabBar];
    
    UIView *pinkLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, customTabBar.frame.size.width, 1)];
    pinkLine.backgroundColor = [UIColor colorWithHex:0xe23674];
    [customTabBar addSubview:pinkLine];
    
    UIImageView *tabBarBg = [[UIImageView alloc] initWithFrame:customTabBar.bounds];
    tabBarBg.image = [[UIImage imageNamed:@"common_tabBarBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 1, 3, 1) resizingMode:UIImageResizingModeStretch];
    [customTabBar addSubview:tabBarBg];
    
    NSArray *itemIconNames = @[@"common_tabBarItemSport", @"common_tabBarItemBestie", @"common_tabBarItemBreast", @"common_tabBarItemMe"];
    NSArray *itemIconNamesH = @[@"common_tabBarItemSportH", @"common_tabBarItemBestieH", @"common_tabBarItemBreastH", @"common_tabBarItemMeH"];
    NSArray *itemTitles = @[@"运动", @"专属日历", @"美胸达人", @"我的"];
    UIColor *grayColor = [UIColor colorWithHex:0xa2a2a2];
    UIColor *pinkColor = [UIColor colorWithHex:0xe23674];
    UIFont *titleFont = [UIFont fontWithName:@"Arial" size:10];
    
    NSInteger itemCount = itemTitles.count;
    frame.size.width /= itemCount;
    CGPoint innerCenter = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    CGFloat verInterval = 2;
    for(NSInteger i = 0; i < itemCount; i++)
    {
        UIControl *item = [[UIControl alloc] initWithFrame:frame];
        item.backgroundColor = [UIColor clearColor];
        [item addTarget:self action:@selector(tabBarItemTap:) forControlEvents:UIControlEventTouchDown];
        item.tag = i;
        [customTabBar addSubview:item];
        
        UIImage *itemIconImage = [UIImage imageNamed:itemIconNames[i]];
        UIImage *itemIconImageH = [UIImage imageNamed:itemIconNamesH[i]];
        UIImageView *itemIcon = [[UIImageView alloc] initWithImage:itemIconImage highlightedImage:itemIconImageH];
        itemIcon.center = innerCenter;
        [item addSubview:itemIcon];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = titleFont;
        titleLabel.textColor = grayColor;
        titleLabel.highlightedTextColor = pinkColor;
        titleLabel.text = itemTitles[i];
        [titleLabel sizeToFit];
        titleLabel.center = innerCenter;
        [item addSubview:titleLabel];
        
        itemIcon.top = (item.height - itemIcon.height - titleLabel.height - verInterval) * 0.5;
        titleLabel.top = itemIcon.bottom + verInterval;
        frame.origin.x += item.width;
        
        [tabBarItemIcons addObject:itemIcon];
        [tabBarItemLabels addObject:titleLabel];
    }
    
    self.customTabBarItemIcons = tabBarItemIcons;
    self.customTabBarItemLabels = tabBarItemLabels;
    
    _selectedItemIndex = 2;
    self.selectedItemIndex = 0;
}

#pragma mark - OverrideSettingMethod

- (void)setSelectedItemIndex:(NSUInteger)index
{
    if(index < self.customTabBarItemIcons.count
       && _selectedItemIndex != index)
    {
        UIImageView *lastTabBarItemIcon = self.customTabBarItemIcons[_selectedItemIndex];
        UILabel *lastTabBarItemLabel = self.customTabBarItemLabels[_selectedItemIndex];
        UIImageView *currentTabBarItemIcon = self.customTabBarItemIcons[index];
        UILabel *currentTabBarItemLabel = self.customTabBarItemLabels[index];
        
        lastTabBarItemIcon.highlighted = NO;
        lastTabBarItemLabel.highlighted = NO;
        currentTabBarItemIcon.highlighted = YES;
        currentTabBarItemLabel.highlighted = YES;
        _selectedItemIndex = index;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    if(self.selectedIndex == selectedIndex)
    {
        self.selectedItemIndex = selectedIndex;
    }
}

#pragma mark - TouchEvent

- (void)tabBarItemTap:(UIControl *)sender
{
    self.selectedIndex = sender.tag;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
