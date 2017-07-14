//
//  TYDHistogramView.m
//

#import "TYDHistogramView.h"

#define nSolidLineWidth                 1
#define nDashLineWidth                  1
#define fTextFont                       [UIFont systemFontOfSize:10]
#define fMaxValueTextFont               [UIFont systemFontOfSize:10]
#define nMaxValueLabelBottomInterval    2
#define nItemViewHeightMin              0//1

@interface TYDHistogramView ()

@property (strong, nonatomic) UIView *linesView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *baseView;

@property (strong, nonatomic) NSMutableArray *itemViews;

@property (strong, nonatomic) UIColor *itemBgColor;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat itemInterval;
@property (nonatomic) NSUInteger itemCount;

@property (strong, nonatomic) UIColor *dashLineColor;
@property (strong, nonatomic) UIColor *solidLineColor;
//@property (nonatomic) BOOL leftSolidLineEnable;
//@property (nonatomic) BOOL bottomSolidLineEnable;

@property (strong, nonatomic) NSArray *valueLevels;
@property (strong, nonatomic) UIColor *valueLevelTextColor;
@property (strong, nonatomic) UIColor *timeStampTextColor;
@property (nonatomic) TYDHistogramTimeStampType timeStampType;
@property (nonatomic) CGFloat histogramMaxHeight;
@property (nonatomic) CGFloat histogramTopInterval;

@property (nonatomic) NSUInteger maxValue;
@property (strong, nonatomic) UILabel *maxValueLabel;

@end

@implementation TYDHistogramView

- (instancetype)initWithCoreViewSize:(CGSize)coreViewSize
                     backgroundColor:(UIColor *)backgroundColor
                      solidLineColor:(UIColor *)solidLineColor
                       dashLineColor:(UIColor *)dashLineColor
                 valueLevelTextColor:(UIColor *)valueLevelTextColor
                  timeStampTextColor:(UIColor *)timeStampTextColor
                           itemColor:(UIColor *)itemColor
                           itemWidth:(CGFloat)itemWidth
                        itemInterval:(CGFloat)itemInterval
                         valueLevels:(NSArray *)valueLevels
                     maxValueVisible:(BOOL)maxValueVisible
                       timeStampType:(TYDHistogramTimeStampType)timeStampType
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.itemBgColor = itemColor;
        self.solidLineColor = solidLineColor;
        self.dashLineColor = dashLineColor;
        self.valueLevelTextColor = valueLevelTextColor;
        self.timeStampTextColor = timeStampTextColor;
        self.itemWidth = itemWidth;
        self.itemInterval = itemInterval;
        self.valueLevels = valueLevels;
        self.timeStampType = timeStampType;
        
        self.histogramMaxHeight = coreViewSize.height;
        self.histogramTopInterval = 0;
        [self itemCountFix];
        
        if(maxValueVisible)
        {
            self.histogramTopInterval = ([BOAssistor string:@"0" sizeWithFont:fMaxValueTextFont].height + nMaxValueLabelBottomInterval);
            self.histogramMaxHeight -= self.histogramTopInterval;
        }
        
        CGRect frame = CGRectMake(0, 0, coreViewSize.width + nSolidLineWidth, coreViewSize.height + nSolidLineWidth);
        UIView *linesView = [[UIView alloc] initWithFrame:frame];
        linesView.backgroundColor = backgroundColor;
        [self addSubview:linesView];
        
        frame = CGRectMake(0, 0, coreViewSize.width, coreViewSize.height);
        frame.size.height += [BOAssistor string:@"0" sizeWithFont:fTextFont].height + 6;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.backgroundColor = [UIColor clearColor];
        //scrollView.showsHorizontalScrollIndicator = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = NO;
        scrollView.bounces = YES;
        scrollView.contentSize = scrollView.frame.size;
        [self addSubview:scrollView];
        
        frame = scrollView.bounds;
        UIView *baseView = [[UIView alloc] initWithFrame:frame];
        baseView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:baseView];
        
        if(maxValueVisible)
        {
            UILabel *maxValueLabel = [UILabel new];
            maxValueLabel.backgroundColor = [UIColor clearColor];
            maxValueLabel.font = fMaxValueTextFont;
            maxValueLabel.textColor = valueLevelTextColor;
            maxValueLabel.text = @" ";
            [maxValueLabel sizeToFit];
            [baseView addSubview:maxValueLabel];
            
            self.maxValueLabel = maxValueLabel;
        }
        
        self.linesView = linesView;
        self.scrollView = scrollView;
        self.baseView = baseView;
        
        [self linesViewAppendLines];
        [self itemViewsLoad];
        [self timeStampLabelsLoad];
        [self levelValueLabelLoad];
        
        self.maxValue = 0;
        //Test ViewSize
        //self.backgroundColor = [UIColor redColor];
        //baseView.backgroundColor = [UIColor redColor];
        
        //居中
        self.scrollView.contentOffset = CGPointMake((self.baseView.width - self.scrollView.width) * 0.5, 0);
    }
    return self;
}

- (void)itemCountFix
{
    NSInteger count = 0;
    switch(self.timeStampType)
    {
        case TYDHistogramTimeStampType15MinutesPerDay:
        case TYDHistogramTimeStampType15MinutesPerDayShort:
            count = 4 * 24;
            break;
        case TYDHistogramTimeStampTypeDaysPerWeek:
            count = 7;
            break;
        case TYDHistogramTimeStampTypeHoursPerDay:
            count = 24;
            break;
        case TYDHistogramTimeStampTypeDaysPerMonth:
        default:
            count = 31;
            break;
    }
    self.itemCount = count;
}

- (void)itemViewsLoad
{
    UIScrollView *scrollView = self.scrollView;
    UIView *baseView = self.baseView;
    NSMutableArray *itemViews = [NSMutableArray new];
    
    CGFloat itemMinHeight = nItemViewHeightMin;
    CGFloat horOffset = self.itemInterval;
    CGFloat itemWidth = self.itemWidth;
    CGFloat itemInterval = self.itemInterval;
    
    CGFloat top = self.histogramTopInterval + self.histogramMaxHeight - itemMinHeight;
    CGRect frame = CGRectMake(horOffset, top, itemWidth, itemMinHeight);
    
    for(NSUInteger count = 0; count < self.itemCount; count++)
    {
        UIView *item = [[UIView alloc] initWithFrame:frame];
        item.backgroundColor = self.itemBgColor;
        [baseView addSubview:item];
        [itemViews addObject:item];
        
        frame.origin.x += (itemWidth + itemInterval);
    }
    
    baseView.width = frame.origin.x;
    if(baseView.width < scrollView.width)
    {
        baseView.width = scrollView.width;
    }
    scrollView.contentSize = baseView.size;
    self.itemViews = itemViews;
}

- (void)levelValueLabelLoad
{
    NSMutableArray *levelMarkLabels = [NSMutableArray new];
    
    CGFloat bottom = self.linesView.bottom;
    NSUInteger stepValuesCount = self.valueLevels.count;
    //CGFloat heightMax = self.linesView.height;
    CGFloat heightMax = self.histogramMaxHeight;
    CGFloat stepHeight = heightMax / (stepValuesCount - 1);
    UIFont *font = fTextFont;
    UIColor *textColor = self.timeStampTextColor;
    
    CGFloat labelWidthMax = 0;
    for(NSInteger index = 1; index < stepValuesCount; index++)
    {
        UILabel *levelLabel = [UILabel new];
        levelLabel.backgroundColor = [UIColor clearColor];
        levelLabel.textColor = textColor;
        levelLabel.font = font;
        levelLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.valueLevels[index] integerValue]];
        levelLabel.textAlignment = NSTextAlignmentRight;
        [levelLabel sizeToFit];
        levelLabel.origin = CGPointMake(0, bottom - stepHeight * index);
        [self addSubview:levelLabel];
        
        [levelMarkLabels addObject:levelLabel];
        if(levelLabel.width > labelWidthMax)
        {
            labelWidthMax = levelLabel.width;
        }
    }
    
    for(UILabel *levelLabel in levelMarkLabels)
    {
        levelLabel.width = labelWidthMax;
    }
    
    CGFloat leftAlign = labelWidthMax + 4;
    self.scrollView.left = leftAlign;
    self.linesView.topRight = self.scrollView.topRight;
    
    self.size = CGSizeMake(self.scrollView.right, self.scrollView.bottom);
}

- (void)timeStampLabelsLoad
{
    NSArray *texts = nil;
    NSMutableArray *timeStampLabels = [NSMutableArray new];
    NSInteger markInterval = 1;
    CGFloat itemWidth = self.itemWidth;
    CGFloat itemInterval = self.itemInterval;
    UIFont *font = fTextFont;
    UIColor *textColor = self.timeStampTextColor;
    UIView *baseView = self.baseView;
    UIScrollView *scrollView = self.scrollView;
    
    switch(self.timeStampType)
    {
        case TYDHistogramTimeStampType15MinutesPerDay:
            texts = @[@"2:00", @"4:00", @"6:00", @"8:00", @"10:00", @"12:00", @"14:00", @"16:00", @"18:00", @"20:00", @"22:00", @"00:00"];
            markInterval = 8;
            break;
        case TYDHistogramTimeStampType15MinutesPerDayShort:
            texts = @[@"2", @"4", @"6", @"8", @"10", @"12", @"14", @"16", @"18", @"20", @"22", @"24"];
            markInterval = 8;
            break;
        case TYDHistogramTimeStampTypeDaysPerMonth:
            texts = @[@"7", @"14", @"21", @"28"];
            markInterval = 7;
            break;
        case TYDHistogramTimeStampTypeDaysPerWeek:
            texts = @[@"一", @"二", @"三", @"四", @"五", @"六", @"日"];
            markInterval = 1;
            break;
        case TYDHistogramTimeStampTypeHoursPerDay:
        default:
            texts = @[@"6:00", @"12:00", @"18:00", @"00:00"];
            markInterval = 6;
            break;
    }
    
    for(NSInteger count = 1; count <= texts.count; count++)
    {
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = textColor;
        label.font = font;
        label.text = [NSString stringWithFormat:@"%@", texts[count - 1]];
        [label sizeToFit];
        label.xCenter = count * markInterval * (itemInterval + itemWidth) - itemWidth * 0.5;
        label.bottom = baseView.height;
        [baseView addSubview:label];
        [timeStampLabels addObject:label];
    }
    UILabel *lastLabel = timeStampLabels.lastObject;
    CGFloat right = lastLabel.right;
    if(baseView.width < right)
    {
        baseView.width = right;
    }
    scrollView.contentSize = baseView.size;
}

- (void)linesViewAppendLines
{
    CGRect frame = self.linesView.bounds;
    CGFloat bottom = frame.origin.y + frame.size.height;
    CGFloat right = frame.origin.x + frame.size.width;
    UIColor *solidLineColor = self.solidLineColor;
    UIColor *dashLineColor = self.dashLineColor;
    NSUInteger stepValuesCount = self.valueLevels.count;
    CGFloat heightMax = frame.size.height - self.histogramTopInterval;
    CGFloat stepHeight = heightMax / (stepValuesCount - 1);
    CGFloat dashLineWidth = nDashLineWidth;
    CGFloat solidLineWidth = nSolidLineWidth;
    
    //等级分隔虚线
    UIBezierPath *path = [UIBezierPath bezierPath];
    for(NSInteger index = 1; index < stepValuesCount; index++)
    {
        CGFloat y = bottom - stepHeight * index + dashLineWidth;
        [path moveToPoint:CGPointMake(0, y)];
        [path addLineToPoint:CGPointMake(right, y)];
    }
    CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
    dashLineLayer.path = path.CGPath;
    dashLineLayer.lineWidth = dashLineWidth;
    dashLineLayer.lineDashPattern = @[@3, @1];
    dashLineLayer.lineDashPhase = -1.0;
    dashLineLayer.fillColor = [UIColor clearColor].CGColor;
    dashLineLayer.strokeColor = dashLineColor.CGColor;
    dashLineLayer.frame = frame;
    [self.linesView.layer addSublayer:dashLineLayer];
    
    //左侧实线
    [path removeAllPoints];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, bottom - nSolidLineWidth)];
    //底部实线
    [path addLineToPoint:CGPointMake(right, bottom - nSolidLineWidth)];
    CAShapeLayer *solidLineLayer = [CAShapeLayer layer];
    solidLineLayer.path = path.CGPath;
    solidLineLayer.lineWidth = solidLineWidth;
    solidLineLayer.fillColor = [UIColor clearColor].CGColor;
    solidLineLayer.strokeColor = solidLineColor.CGColor;
    solidLineLayer.frame = frame;
    [self.linesView.layer addSublayer:solidLineLayer];
}

- (void)setMaxValueLabelXCenter:(CGFloat)xCenter bottom:(CGFloat)bottom
{
    if(self.maxValueLabel)
    {
        self.maxValueLabel.text = self.maxValue > 0 ? [NSString stringWithFormat:@"%ld", (long)self.maxValue] : @" ";
        [self.maxValueLabel sizeToFit];
        
        self.maxValueLabel.bottom = bottom - nMaxValueLabelBottomInterval;
        self.maxValueLabel.xCenter = xCenter;
        
        self.maxValueLabel.left = MAX(self.maxValueLabel.left, 0);
        self.maxValueLabel.top = MAX(self.maxValueLabel.top, 0);
        self.maxValueLabel.right = MIN(self.maxValueLabel.right, self.maxValueLabel.superview.width);
    }
}

#pragma mark - Refresh Value

- (void)refreshAllValues:(NSArray *)values animated:(BOOL)animated
{
    NSUInteger itemCount = self.itemCount;
    NSUInteger valueCount = MIN(values.count, itemCount);
    NSUInteger index = 0;
    self.maxValue = 0;
    
    for(; index < valueCount; index++)
    {
        [self refreshOneValue:values[index] atIndex:index animated:animated];
    }
    for(; index < itemCount; index++)
    {
        [self refreshOneValue:@0 atIndex:index animated:animated];
    }
}

- (void)refreshOneValue:(NSNumber *)value atIndex:(NSUInteger)index
{
    [self refreshOneValue:value atIndex:index animated:YES];
}

- (void)clearAllValuesAnimated:(BOOL)animated
{
    self.maxValue = 0;
    for(NSUInteger index = 0; index < self.itemCount; index++)
    {
        [self refreshOneValue:@0 atIndex:index animated:animated];
    }
}

- (void)refreshOneValue:(NSNumber *)value atIndex:(NSUInteger)index animated:(BOOL)animated
{
    if(index < self.itemCount)
    {
        UIView *item = self.itemViews[index];
        CGFloat heightNew = [self itemHeightWithValue:value];
        CGRect frame = item.frame;
        if(frame.size.height == heightNew)
        {
            if(value.integerValue > self.maxValue)
            {
                self.maxValue = value.integerValue;
                [self setMaxValueLabelXCenter:item.xCenter bottom:frame.origin.y];
            }
            return;
        }
        frame.origin.y -= (heightNew - frame.size.height);
        frame.size.height = heightNew;
        
        if(value.integerValue > self.maxValue)
        {
            self.maxValue = value.integerValue;
            [self setMaxValueLabelXCenter:item.xCenter bottom:frame.origin.y];
        }
        
        void (^itemHeightChange)(void) = ^{
            item.frame = frame;
        };
        if(animated)
        {
            [UIView animateWithDuration:0.25 animations:itemHeightChange];
        }
        else
        {
            itemHeightChange();
        }
        itemHeightChange = nil;
    }
}

- (CGFloat)itemHeightWithValue:(NSNumber *)value
{
    CGFloat heightMin = nItemViewHeightMin;
    CGFloat heightMax = self.histogramMaxHeight;
    NSInteger intValue = value.integerValue;
    NSUInteger stepValuesCount = self.valueLevels.count;
    CGFloat stepHeight = heightMax / (stepValuesCount - 1);
    NSUInteger index = 0;
    for(; index < stepValuesCount; index++)
    {
        NSNumber *stepValue = self.valueLevels[index];
        if(intValue <= stepValue.integerValue)
        {
            break;
        }
    }
    
    CGFloat height = heightMin;
    if(index == 0)//min
    {
        height = 0;
    }
    else if(index >= stepValuesCount)//max
    {
        height = heightMax;
    }
    else
    {
        NSInteger numberLow = [self.valueLevels[index - 1] integerValue];
        NSInteger numberHigh = [self.valueLevels[index] integerValue];
        height = (index + (intValue - numberLow) * 1.0 / (numberHigh - numberLow) - 1) * stepHeight;
    }
    
    if(height < heightMin)
    {
        height = heightMin;
    }
    
    return height;
}

@end
