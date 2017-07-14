//
//  TYDShareActionSheet.m
//
//  视图截图保存分享的ActionSheet
//

#import "TYDShareActionSheet.h"
#import "WeiboSDK.h"
#import "WXApi.h"

#define sTitleSaveToAlbum       @"保存到本地相册"
#define sTitleShareToWechat     @"分享 微信好友"
#define sTitleShareToFriends    @"分享 朋友圈"
#define sTitleShareToSinaWeibo  @"分享 新浪微博"
#define sTitleShare             nil
//#define sTitleShare             @"分享与保存"
//#define sTitleSaveToAlbum       @"本地相册"
//#define sTitleShareToWechat     @"微信好友"
//#define sTitleShareToFriends    @"朋友圈"
//#define sTitleShareToSinaWeibo  @"新浪微博"
//#define sTitleShare             @"保存或分享"

typedef NS_ENUM(NSInteger, ShareActionSheetIndex)
{
    ShareActionSheetIndexSaveToAlbum = 0,
    ShareActionSheetIndexShareToWeChat,
    ShareActionSheetIndexShareToFriends,
    ShareActionSheetIndexShareToSinaWeibo,
};

@interface TYDShareActionSheet () <UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (weak, nonatomic) UIView *screenShotView;

@property (weak, nonatomic) UIViewController<TYDShareActionSheetDelegate> *delegate;

@end

@implementation TYDShareActionSheet

- (void)setDelegate:(UIViewController<TYDShareActionSheetDelegate> *)delegate screenShotView:(UIView *)screenShotView
{
    self.delegate = delegate;
    self.screenShotView = screenShotView;
}

#pragma mark - SingleTon

- (instancetype)init
{
    if(self = [super init])
    {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:sTitleShare delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:sTitleSaveToAlbum otherButtonTitles:sTitleShareToWechat, sTitleShareToFriends, sTitleShareToSinaWeibo, nil];
        self.delegate = nil;
        self.screenShotView = nil;
    }
    return self;
}

+ (instancetype)defaultSheet
{
    static TYDShareActionSheet *defaultSheetInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        defaultSheetInstance = [[self alloc] init];
    });
    return defaultSheetInstance;
}

#pragma mark - ShowAction

- (void)actionSheetShow
{
    if(self.delegate)
    {
        UITabBarController *tabBarController = self.delegate.tabBarController;
        if(self.delegate == tabBarController.selectedViewController
           || self.delegate.navigationController == tabBarController.selectedViewController)
        {
            [self.actionSheet showFromTabBar:tabBarController.tabBar];
        }
        else
        {
            [self.actionSheet showInView:self.delegate.view];
        }
    }
}

- (void)actionSheetDismiss
{
    [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:NO];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"shareActionSheet ButtonIndex:%d", (int)buttonIndex);
    switch(buttonIndex)
    {
        case ShareActionSheetIndexSaveToAlbum:
            [self saveImageToLocalAlbum];
            break;
        case ShareActionSheetIndexShareToWeChat:
            [self shareImageToWeChat];
            break;
        case ShareActionSheetIndexShareToFriends:
            [self shareImageToFriends];
            break;
        case ShareActionSheetIndexShareToSinaWeibo:
            [self shareImageToSinaWeibo];
            break;
    }
}

#pragma mark - SaveToAlbum

//保存到本地相册
- (void)saveImageToLocalAlbum
{
    if([self.delegate respondsToSelector:@selector(screenShotImageSaveToAlbumWillBegin)])
    {
        [self.delegate screenShotImageSaveToAlbumWillBegin];
    }
    UIImage *viewImage = [self screenShotCreateWithView:self.screenShotView];
    UIImageWriteToSavedPhotosAlbum(viewImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    /*NSLocalizedDescription = "Data unavailable";
     NSLocalizedRecoverySuggestion = "Launch the Photos application";
     NSUnderlyingError = "Error Domain=ALAssetsLibraryErrorDomain Code=-3310 \"Data unavailable\" UserInfo=0x15e06350 {NSLocalizedRecoverySuggestion=Launch the Photos application, NSUnderlyingError=0x15e65790 \"The operation couldn\U2019t be completed. (com.apple.photos error -3001.)\", NSLocalizedDescription=Data unavailable}";*/
    if(error)
    {
        NSString *message = @"图片保存失败，请检查“设置-隐私-照片”中是否对本应用开放许可";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(screenShotImageSaveToAlbumComplete:)])
        {
            [self.delegate screenShotImageSaveToAlbumComplete:!error];
        }
    }
}

#pragma mark - Share

//分享到微信好友
- (void)shareImageToWeChat
{
    UIImage *viewImage = [self screenShotCreateWithView:self.screenShotView];
    UIImage *thumbImage = [self thumbImageCreateWithViewImage:viewImage];
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];
//    if([self imageDataSizeMeasure:thumbImage] < (32 * 1024))
//    {
//        NSLog(@"thumbImageSize OK");
//        [message setThumbImage:thumbImage];
//    }
//    else
//    {
//        NSLog(@"thumbImageSize TooLarge");
//    }
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(viewImage, 1);
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

//分享到微信朋友圈
- (void)shareImageToFriends
{
    UIImage *viewImage = [self screenShotCreateWithView:self.screenShotView];
    UIImage *thumbImage = [self thumbImageCreateWithViewImage:viewImage];
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];
//    if([self imageDataSizeMeasure:thumbImage] < (32 * 1024))
//    {
//        NSLog(@"thumbImageSize OK");
//        [message setThumbImage:thumbImage];
//    }
//    else
//    {
//        NSLog(@"thumbImageSize TooLarge");
//    }
    
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(viewImage, 1);
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

//分享到新浪微博
- (void)shareImageToSinaWeibo
{
    UIImage *viewImage = [self screenShotCreateWithView:self.screenShotView];
    NSData *viewImageData = UIImageJPEGRepresentation(viewImage, 1);
    
    WBMessageObject *message = [WBMessageObject message];
    WBImageObject *image = [WBImageObject object];
    image.imageData = viewImageData;
    message.imageObject = image;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessage":@"mofei"};
    //request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    
    [WeiboSDK sendRequest:request];
}

#pragma mark - ScreenShotImage

- (NSUInteger)imageDataSizeMeasure:(UIImage *)image
{
    NSUInteger length = 0;
    if(image)
    {
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        length = imageData.length;
    }
    return length;
}

- (UIImage *)thumbImageCreateWithViewImage:(UIImage *)viewImage
{
    UIImage *thumbImage = nil;
    if(viewImage)
    {
        CGSize thumbImageMaxSize = CGSizeMake(200, 200);
        CGSize viewImageSize = viewImage.size;
        CGFloat xScale = thumbImageMaxSize.width / viewImageSize.width;
        CGFloat yScale = thumbImageMaxSize.height / viewImageSize.height;
        CGFloat scale = MIN(xScale, yScale);
        scale = MIN(1, scale);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage];
        imageView.size = CGSizeMake(viewImageSize.width * scale, viewImageSize.height * scale);
        thumbImage = [self screenShotCreateWithView:imageView];
    }
    return thumbImage;
}

- (UIImage *)screenShotCreateWithView:(UIView *)screenShotView
{
    UIImage *viewImage = nil;
    if(screenShotView)
    {
        CGSize imageSize = screenShotView.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        //UIGraphicsBeginImageContext(imageSize);
        //CGContextRef context = UIGraphicsGetCurrentContext();
        //CGContextSaveGState(context);
        [screenShotView.layer renderInContext:UIGraphicsGetCurrentContext()];
        //CGContextRestoreGState(context);
        viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return viewImage;
}

@end
