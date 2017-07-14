//
//  TYDSportCircleView.m
//
//  "运动"首页 运动目标完成环装效果视图
//
//  取整函数ceil(),floor()
//

#import "TYDSportCircleView.h"
#import "TYDUnitLabel.h"

#define nMaxDegreePerCircle         280
#define nFullDegreePerCircle        360

#define nSportCircleViewRadius      120
//#define nCapIconBarRadius           15
//#define nSportCircleBorderWidth     3.5

#define nPercentValuePaintOffset    0.02
#define nRunBasicPace               0.01

@interface TYDSportCircleView ()

@property (strong, nonatomic) UIImageView *capIcon;    //百分比圆形图标
@property (strong, nonatomic) UILabel *percentLabel;//百分比标签
@property (strong, nonatomic) TYDUnitLabel *recordLabel; //当前运动量标签
@property (strong, nonatomic) UILabel *targetLabel; //目标运动量标签

@property (nonatomic) CGFloat percentValue;
@property (nonatomic) CGFloat currentPercentValue;

@property (strong, nonatomic) NSTimer *runTimer;
@property (nonatomic) CGFloat runPace;

//@property (nonatomic) BOOL isRunPaceIncrease;
//@property (nonatomic) NSInteger runTimerCount;
//应用CAAnimation进行动画

@end

@implementation TYDSportCircleView

- (instancetype)init
{
    CGRect frame = CGRectZero;
    frame.size = [self.class sportCircleViewSize];
    if(self = [super initWithFrame:frame])
    {
        UIImageView *capIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sport_statusCircleIcon"]];
        [self addSubview:capIcon];
        
        UILabel *percentLabel = [UILabel new];
        percentLabel.backgroundColor = [UIColor clearColor];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        percentLabel.font = [UIFont fontWithName:@"Arial" size:10];
        percentLabel.textColor = [UIColor colorWithHex:0xe23674];
        percentLabel.text = @"100%";
        [percentLabel sizeToFit];
        percentLabel.text = @"0%";
        percentLabel.center = capIcon.innerCenter;
        [capIcon addSubview:percentLabel];
        
        UIFont *numberTextFont = [UIFont fontWithName:sFontNameForRBNo2Light size:100];
        UIColor *numberTextColor = [UIColor colorWithHex:0xffffff];
        UIFont *unitTextFont = [UIFont fontWithName:@"Arial" size:14];
        UIColor *unitTextColor = [UIColor colorWithHex:0xffffff andAlpha:0.65];
        NSString *unitText = sCalorieBasicShortUnit;
        CGPoint centerPoint = self.innerCenter;
        //视觉效果需要偏移
        centerPoint.x += [BOAssistor string:unitText sizeWithFont:unitTextFont].width * 0.35;
        centerPoint.y += 8;
        TYDUnitLabel *recordLabel = [[TYDUnitLabel alloc] initWithNumberText:@"0" numberTextFont:numberTextFont numberTextColor:numberTextColor unitText:unitText unitTextFont:unitTextFont unitTextColor:unitTextColor alignmentType:UIViewAlignmentCenter spaceCountForInterval:1];
        recordLabel.center = centerPoint;
        [self addSubview:recordLabel];
        
        UIFont *markTextFont = [UIFont fontWithName:@"Arial" size:15];
        UIColor *markTextColor = unitTextColor;
        UILabel *zeroLabel = [UILabel new];
        zeroLabel.backgroundColor = [UIColor clearColor];
        zeroLabel.font = markTextFont;
        zeroLabel.textColor = markTextColor;
        zeroLabel.text = @"0";
        [zeroLabel sizeToFit];
        [self addSubview:zeroLabel];
        
        UILabel *targetLabel = [UILabel new];
        targetLabel.backgroundColor = [UIColor clearColor];
        targetLabel.font = markTextFont;
        targetLabel.textColor = markTextColor;
        targetLabel.text = @"300";
        [targetLabel sizeToFit];
        [self addSubview:targetLabel];
        
        self.percentLabel = percentLabel;
        self.recordLabel = recordLabel;
        self.targetLabel = targetLabel;
        self.capIcon = capIcon;
        self.backgroundColor = [UIColor clearColor];
        _percentValue = 0;
        _currentPercentValue = 0;
        _calorieTargetValue = 300;
        _calorieBurnedValue = 0;
        
        //设置运动目标标签位置
        CGFloat maxAngle = M_PI * 2 * nMaxDegreePerCircle / nFullDegreePerCircle;
        CGFloat startAngle = M_PI * (nFullDegreePerCircle * 1.5 - nMaxDegreePerCircle) / nFullDegreePerCircle;
        CGFloat endAngle = startAngle + maxAngle;
        UIBezierPath *path = [self circlePathWithStartAngle:startAngle endAngle:endAngle];
        targetLabel.center = path.currentPoint;
        targetLabel.top += capIcon.height * 0.5 + 2;
        
        //设置"0"标签位置
        zeroLabel.center = CGPointMake(self.width - targetLabel.center.x, targetLabel.center.y);
    }
    return self;
}

- (UIBezierPath *)circlePathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    CGRect frame = self.bounds;
    CGFloat capImageRadius = self.capIcon.width * 0.5;
    CGPoint circleCenter = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    CGFloat radius = nSportCircleViewRadius - capImageRadius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:circleCenter
                    radius:radius
                startAngle:startAngle
                  endAngle:endAngle
                 clockwise:YES];
    //path.lineWidth = nSportCircleBorderWidth;
    path.lineCapStyle = kCGLineCapRound;//kCGLineCapButt;
    
    return path;
}

#pragma mark - OverrideSettingMethod

- (void)setCurrentPercentValue:(CGFloat)currentPercentValue
{
    if(_currentPercentValue != currentPercentValue)
    {
        _currentPercentValue = currentPercentValue;
        [self setNeedsDisplay];
    }
}

- (void)setPercentValue:(CGFloat)percentValue
{
    if(percentValue < 0.0)
    {
        percentValue = 0.0;
    }
    else if(percentValue > 0 && percentValue < 0.01)
    {
        percentValue = 0.01;
    }
    else if(percentValue > 1.0)
    {
        percentValue = 1.0;
    }
    
    _percentValue = percentValue;
    self.percentLabel.text = [NSString stringWithFormat:@"%d%%", (int)(percentValue * 100)];
    
    //circle Animation
    [self percentValueChangeTimerCancel];
    self.runPace = (self.percentValue > self.currentPercentValue) ? nRunBasicPace : -nRunBasicPace;
    self.runTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(percentValueChangeAction) userInfo:nil repeats:YES];
}

- (void)setCalorieTargetValue:(NSUInteger)calorieTargetValue
{
    if(calorieTargetValue < 1)
    {
        calorieTargetValue = 1;
    }
    _calorieTargetValue = calorieTargetValue;
    
    self.targetLabel.text = [NSString stringWithFormat:@"%ld", (long)calorieTargetValue];
    CGPoint center = self.targetLabel.center;
    [self.targetLabel sizeToFit];
    self.targetLabel.center = center;
}

- (void)setCalorieBurnedValue:(NSUInteger)calorieBurnedValue
{
    _calorieBurnedValue = calorieBurnedValue;
    
    CGPoint center = self.recordLabel.center;
    self.recordLabel.numberText = [NSString stringWithFormat:@"%ld", (long)calorieBurnedValue];
    self.recordLabel.center = center;
    
    self.percentValue = calorieBurnedValue * 1.0 / self.calorieTargetValue;
}

- (void)setCalorieTargetValue:(NSInteger)targetValue andBurnedValue:(NSInteger)burnedValue
{
    self.calorieTargetValue = targetValue;
    self.calorieBurnedValue = burnedValue;
}

#pragma mark - Circle Run Method

- (void)percentValueChangeTimerCancel
{
    if([self.runTimer isValid])
    {
        [self.runTimer invalidate];
        self.runTimer = nil;
    }
}

- (void)percentValueChangeAction
{
    CGFloat currentValue = self.currentPercentValue + self.runPace;
    if((self.runPace > 0 && currentValue >= self.percentValue)
       || (self.runPace < 0 && currentValue <= self.percentValue))
    {
        [self percentValueChangeTimerCancel];
        currentValue = self.percentValue;
    }
    self.currentPercentValue = currentValue;
}

#pragma mark - Override DrawRect

//绘制时位置校正，首末端带3%的偏移
//避免百分比圆形图标覆盖起始和目标任务值标签
//0%-3%，绘制位置都为3%
//97%-%100，绘制位置都为97%
- (CGFloat)paintPercentValueCheck:(CGFloat)percentValue
{
    if(percentValue < nPercentValuePaintOffset)//0.03
    {//防止覆盖开始的“0”，预留百分比圆形图标偏移
        percentValue = nPercentValuePaintOffset;
    }
    if(percentValue > 1 - nPercentValuePaintOffset)//0.97
    {//防止覆盖运动目标数字标签，预留百分比圆形图标偏移
        percentValue = 1 - nPercentValuePaintOffset;
    }
    return percentValue;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat currentPercentValueT = [self paintPercentValueCheck:self.currentPercentValue];
    CGFloat maxAngle = M_PI * 2 * nMaxDegreePerCircle / nFullDegreePerCircle;
    CGFloat startAngle = M_PI * (nFullDegreePerCircle * 1.5 - nMaxDegreePerCircle) / nFullDegreePerCircle;
    CGFloat middleAngle = startAngle + maxAngle * currentPercentValueT;
    CGFloat endAngle = startAngle + maxAngle;
    
    UIColor *deepColor = [UIColor colorWithHex:0xffffff];
    UIColor *lightColor = [UIColor colorWithHex:0xffffff andAlpha:0.2];
    
    //开始绘制
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //绘制浅粉圆弧
    UIBezierPath *path = [self circlePathWithStartAngle:middleAngle endAngle:endAngle];
    path.lineWidth = 4;
    [lightColor setStroke];
    [path stroke];
    
    //绘制深粉圆弧
    path = [self circlePathWithStartAngle:startAngle endAngle:middleAngle];
    path.lineWidth = 8;
    [deepColor setStroke];
    [path stroke];
    
    //结束绘制
    CGContextRestoreGState(context);
    
    //绘制运动目标完成比例圆形图标
    self.capIcon.center = path.currentPoint;
    
    //绘制完成比例标签
    //self.percentLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.currentPercentValue * 100];
}

#pragma mark - ClassMethod

+ (CGSize)sportCircleViewSize
{
    return CGSizeMake(nSportCircleViewRadius * 2, nSportCircleViewRadius * 2);
}

@end
