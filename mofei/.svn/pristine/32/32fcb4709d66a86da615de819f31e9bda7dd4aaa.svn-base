//
//  BaseScrollController.m
//

#import "BaseScrollController.h"
#import "BaseNavigationController.h"

@interface BaseScrollController ()

@end

@implementation BaseScrollController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _baseViewBaseHeight = 0;
    [self localBasicViewsLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserverForKeyboardFrameChangeEvent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserverForKeyboardFrameChangeEvent];
}

- (void)localBasicViewsLoad
{
    CGRect frame = self.view.bounds;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = frame.size;
    scrollView.pagingEnabled = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.bounces = YES;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    scrollView.alwaysBounceVertical = YES;//
    [self.view addSubview:scrollView];
    
    frame.size.height = self.baseViewBaseHeight;
    UIControl *baseView = [[UIControl alloc] initWithFrame:frame];
    baseView.backgroundColor = [UIColor clearColor];
    [baseView addTarget:self action:@selector(tapOnSpace:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:baseView];
    
    _scrollView = scrollView;
    _baseView = baseView;
    _textFields = [BOTextFieldCollection new];
}

- (void)setBaseViewBaseHeight:(CGFloat)baseViewBaseHeight
{
    _baseViewBaseHeight = baseViewBaseHeight;
    self.baseView.height = baseViewBaseHeight;
    self.scrollView.contentSize = self.baseView.size;
}

#pragma mark - Observer

- (void)addObserverForKeyboardFrameChangeEvent
{
    if(!self.textFields.isEmpty)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)removeObserverForKeyboardFrameChangeEvent
{
    if(!self.textFields.isEmpty)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

#pragma mark - KeyBoard FrameChange

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    //NSLog(@"keyboardFrameWillChange");
    NSDictionary *notificationInfo = notification.userInfo;
    CGRect frameOfKeyboard = [notificationInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSTimeInterval duration = [notificationInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions options = [notificationInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    //将键盘本身的相对于屏幕的坐标系frame转换为当前view坐标系的坐标
    frameOfKeyboard = [self.view convertRect:frameOfKeyboard fromView:window];
    
    if(frameOfKeyboard.origin.y < self.view.frame.size.height)
    {
        //keyBoard showOrRise
        [self keyboardShowOrRiseWithKeyboardFrame:frameOfKeyboard animationDuration:duration animationOptions:options];
    }
    else
    {
        //keyBoard hide
        [self keyboardHideWithAnimationDuration:duration animationOptions:options];
    }
}

- (void)keyboardShowOrRiseWithKeyboardFrame:(CGRect)frameOfKeyboard animationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options
{
    NSLog(@"keyBoardWillShowOrRise");
    
    CGRect frameOfScrollView = self.scrollView.frame;
    frameOfScrollView.size.height = frameOfKeyboard.origin.y;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    
    CGFloat scrollViewBottomLine = contentOffset.y + frameOfScrollView.size.height;
    UITextField *firstResponderTextField = [self.textFields firstResponderTextField];
    if(firstResponderTextField)
    {
        CGRect frameOfTextField = firstResponderTextField.frame;
        frameOfTextField = [self.baseView convertRect:frameOfTextField fromView:firstResponderTextField.superview];
        
        CGFloat textFieldBottomLine = frameOfTextField.origin.y + frameOfTextField.size.height;
        textFieldBottomLine += 10;//补偿
        
        if(textFieldBottomLine > scrollViewBottomLine)
        {
            contentOffset.y = textFieldBottomLine - frameOfScrollView.size.height;
        }
    }
    
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:duration//0.25
                          delay:0.0
                        options:options//UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         wself.scrollView.frame = frameOfScrollView;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                         {
                             [wself.scrollView setContentOffset:contentOffset animated:YES];
                         }
                     }];
}

- (void)keyboardHideWithAnimationDuration:(NSTimeInterval)duration animationOptions:(UIViewAnimationOptions)options
{
    NSLog(@"keyBoardWillHide");
    self.scrollView.frame = self.view.bounds;
}

#pragma mark - TouchEvent

- (void)tapOnSpace:(id)sender
{
    [self.textFields allTextFieldsResignFirstResponder];
}

- (void)popBackEventWillHappen
{
    [self.textFields allTextFieldsResignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
