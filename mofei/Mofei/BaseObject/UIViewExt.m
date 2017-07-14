/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIViewExt.h"

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

CGRect CGRectMoveToCenter(CGRect rect, CGPoint center)
{
    CGRect newrect = CGRectZero;
    newrect.origin.x = center.x - CGRectGetMidX(rect);
    newrect.origin.y = center.y - CGRectGetMidY(rect);
    newrect.size = rect.size;
    return newrect;
}

@implementation UIView (ViewGeometry)

// Retrieve and set the origin
- (CGPoint)origin
{
	return self.frame.origin;
}

- (void)setOrigin:(CGPoint)aPoint
{
	CGRect newframe = self.frame;
	newframe.origin = aPoint;
	self.frame = newframe;
}

// Retrieve and set the size
- (CGSize)size
{
	return self.frame.size;
}

- (void)setSize:(CGSize)aSize
{
	CGRect newframe = self.frame;
	newframe.size = aSize;
	self.frame = newframe;
}

// Query other frame locations
- (CGPoint)bottomRight
{
	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (void)setBottomRight:(CGPoint)bottomRight
{
    CGRect frame = self.frame;
    frame.origin.x = bottomRight.x - frame.size.width;
    frame.origin.y = bottomRight.y - frame.size.height;
    self.frame = frame;
}

- (CGPoint)bottomLeft
{
	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (void)setBottomLeft:(CGPoint)bottomLeft
{
    CGRect frame = self.frame;
    frame.origin.x = bottomLeft.x;
    frame.origin.y = bottomLeft.y - frame.size.height;
    self.frame = frame;
}

- (CGPoint)topRight
{
	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y;
	return CGPointMake(x, y);
}

- (void)setTopRight:(CGPoint)topRight
{
    CGRect frame = self.frame;
    frame.origin.x = topRight.x - frame.size.width;
    frame.origin.y = topRight.y;
    self.frame = frame;
}

// Retrieve and set height, width, top, bottom, left, right
- (CGFloat)height
{
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newheight
{
	CGRect newframe = self.frame;
	newframe.size.height = newheight;
	self.frame = newframe;
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newwidth
{
	CGRect newframe = self.frame;
	newframe.size.width = newwidth;
	self.frame = newframe;
}

- (CGFloat)top
{
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)newtop
{
	CGRect newframe = self.frame;
	newframe.origin.y = newtop;
	self.frame = newframe;
}

- (CGFloat)left
{
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)newleft
{
	CGRect newframe = self.frame;
	newframe.origin.x = newleft;
	self.frame = newframe;
}

- (CGFloat)bottom
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)newbottom
{
	CGRect newframe = self.frame;
	newframe.origin.y = newbottom - self.frame.size.height;
	self.frame = newframe;
}

- (CGFloat)right
{
	return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)xCenter
{
    return self.center.x;
}

- (void)setXCenter:(CGFloat)xCenter
{
    CGPoint center = self.center;
    center.x = xCenter;
    self.center = center;
}

- (CGFloat)yCenter
{
    return self.center.y;
}

- (CGPoint)innerCenter
{
//    CGPoint center = self.center;
//    return CGPointMake(center.x - self.left, center.y - self.right);
//    return CGPointMake(self.width * 0.5, self.height * 0.5);
    return CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
}

- (void)setYCenter:(CGFloat)yCenter
{
    CGPoint center = self.center;
    center.y = yCenter;
    self.center = center;
}

- (void)setRight:(CGFloat)newright
{
	CGFloat delta = newright - (self.frame.origin.x + self.frame.size.width);
	CGRect newframe = self.frame;
	newframe.origin.x += delta ;
	self.frame = newframe;
}

// Move via offset
- (void)moveBy:(CGPoint)delta
{
	CGPoint newcenter = self.center;
	newcenter.x += delta.x;
	newcenter.y += delta.y;
	self.center = newcenter;
}

// Scaling
- (void)scaleBy:(CGFloat)scaleFactor
{
	CGRect newframe = self.frame;
	newframe.size.width *= scaleFactor;
	newframe.size.height *= scaleFactor;
	self.frame = newframe;
}

// Ensure that both dimensions fit within the given size by scaling down
- (void)fitInSize:(CGSize)aSize
{
	CGFloat scale;
	CGRect newframe = self.frame;
	
	if(newframe.size.height && (newframe.size.height > aSize.height))
	{
		scale = aSize.height / newframe.size.height;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	if(newframe.size.width && (newframe.size.width >= aSize.width))
	{
		scale = aSize.width / newframe.size.width;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	self.frame = newframe;	
}

@end

