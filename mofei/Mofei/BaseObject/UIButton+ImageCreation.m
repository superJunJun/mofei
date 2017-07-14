//
//  UIButton+ImageCreation.m
//

#import "UIButton+ImageCreation.h"

CGSize maxSpaceSize(CGSize size1, CGSize size2)
{
    return CGSizeMake(MAX(size1.width, size2.width),
                      MAX(size1.height, size2.height));
}

@implementation UIButton (ImageCreation)

- (instancetype)initWithImage:(UIImage *)image
{
    CGSize btnSize = image.size;
    if(self = [super initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)])
    {
        [self setImage:image forState:UIControlStateNormal];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)imageH
{
    CGSize btnSize = maxSpaceSize(image.size, imageH.size);
    if(self = [self initWithImage:image
                 highlightedImage:imageH
                  givenButtonSize:btnSize])
    {}
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)imageH
              givenButtonSize:(CGSize)btnSize
{
    if(self = [super initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)])
    {
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:imageH forState:UIControlStateHighlighted];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)imageH
                        title:(NSString *)title
{
    CGSize btnSize = maxSpaceSize(image.size, imageH.size);
    if(self = [self initWithImage:image
                 highlightedImage:imageH
                        capInsets:UIEdgeInsetsZero
                  givenButtonSize:btnSize
                            title:title
                        titleFont:nil
                       titleColor:nil])
    {}
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)imageH
                        title:(NSString *)title
                    titleFont:(UIFont *)titleFont
                   titleColor:(UIColor *)titleColor
{
    CGSize btnSize = maxSpaceSize(image.size, imageH.size);
    if(self = [self initWithImage:image
                 highlightedImage:imageH
                        capInsets:UIEdgeInsetsZero
                  givenButtonSize:btnSize
                            title:title
                        titleFont:titleFont
                       titleColor:titleColor])
    {}
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)imageH
                    capInsets:(UIEdgeInsets)capInsets
              givenButtonSize:(CGSize)btnSize
                        title:(NSString *)title
                    titleFont:(UIFont *)titleFont
                   titleColor:(UIColor *)titleColor
{
    if(self = [super initWithFrame:CGRectMake(0, 0, btnSize.width, btnSize.height)])
    {
        if(!UIEdgeInsetsEqualToEdgeInsets(capInsets, UIEdgeInsetsZero))
        {
            image = [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
            imageH = [imageH resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
        }
        
        [self setBackgroundImage:image forState:UIControlStateNormal];
        [self setBackgroundImage:imageH forState:UIControlStateHighlighted];
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = titleFont;
        [self setTitleColor:titleColor forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark - ImageWithName

- (instancetype)initWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    if(self = [self initWithImage:image])
    {}
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)imageHName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageH = [UIImage imageNamed:imageHName];
    CGSize btnSize = maxSpaceSize(image.size, imageH.size);
    if(self = [self initWithImage:image highlightedImage:imageH givenButtonSize:btnSize])
    {}
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)imageHName
                  givenButtonSize:(CGSize)btnSize
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageH = [UIImage imageNamed:imageHName];
    if(self = [self initWithImage:image highlightedImage:imageH givenButtonSize:btnSize])
    {}
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)imageHName
                            title:(NSString *)title
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageH = [UIImage imageNamed:imageHName];
    CGSize btnSize = maxSpaceSize(image.size, imageH.size);
    if(self = [self initWithImage:image
                 highlightedImage:imageH
                        capInsets:UIEdgeInsetsZero
                  givenButtonSize:btnSize
                            title:title
                        titleFont:nil
                       titleColor:nil])
    {}
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)imageHName
                            title:(NSString *)title
                        titleFont:(UIFont *)titleFont
                       titleColor:(UIColor *)titleColor
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageH = [UIImage imageNamed:imageHName];
    CGSize btnSize = maxSpaceSize(image.size, imageH.size);
    if(self = [self initWithImage:image
                 highlightedImage:imageH
                        capInsets:UIEdgeInsetsZero
                  givenButtonSize:btnSize
                            title:title
                        titleFont:titleFont
                       titleColor:titleColor])
    {}
    return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
             highlightedImageName:(NSString *)imageHName
                        capInsets:(UIEdgeInsets)capInsets
                  givenButtonSize:(CGSize)btnSize
                            title:(NSString *)title
                        titleFont:(UIFont *)titleFont
                       titleColor:(UIColor *)titleColor
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *imageH = [UIImage imageNamed:imageHName];
    if(self = [self initWithImage:image
                 highlightedImage:imageH
                        capInsets:capInsets
                  givenButtonSize:btnSize
                            title:title
                        titleFont:titleFont
                       titleColor:titleColor])
    {}
    return self;
}


@end
