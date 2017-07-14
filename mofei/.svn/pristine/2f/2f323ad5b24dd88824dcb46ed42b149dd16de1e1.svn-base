//
//  BaseTableViewController.m
//

#import "BaseTableViewController.h"
#import "BOHUDManager.h"
#import "BONoticeBar.h"
#import "TYDAppDelegate.h"

#define MBProgressHUDCompleteStayTime                   0.6
#define MBProgressHUDCompleteAdditionalFuncDelayTime    0.65

@interface BaseTableViewController () <TYDSuspendEventDelegate>

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIBarButtonItem *naviBackButtonItem;
@property (strong, nonatomic) BOHUDManager *hudManager;
@property (strong, nonatomic) BONoticeBar *noticeBar;

@end

@implementation BaseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcff];
    self.customEdgesForExtendedLayout = UIRectEdgeNone;
    self.clearsSelectionOnViewWillAppear = YES;
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self localNavigationBarItemsLoad];
    self.hudManager = [BOHUDManager defaultManager];
}

- (void)localNavigationBarItemsLoad
{
    UIImage *backBtnImage = [UIImage imageNamed:@"common_naviBackBtn"];
    UIImage *backBtnImageH = [UIImage imageNamed:@"common_naviBackBtnH"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backBtnImage.size.width, backBtnImage.size.height)];
    [backButton setImage:backBtnImage forState:UIControlStateNormal];
    [backButton setImage:backBtnImageH forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(popBackEventWillHappen) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.backButton = backButton;
    self.backButtonVisible = YES;
    self.naviBackButtonItem = backItem;
    self.naviBackButtonItem.enabled = NO;
}

- (void)popBackEventWillHappen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TYDAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.eventDelegate = self;
    
    if(self.navigationController.viewControllers.count > 1)
    {
        if(self.navigationItem.leftBarButtonItem != self.naviBackButtonItem)
        {
            self.navigationItem.leftBarButtonItem = self.naviBackButtonItem;
        }
        self.naviBackButtonItem.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    TYDAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.eventDelegate = nil;
    
    self.naviBackButtonItem.enabled = NO;
}

#pragma mark - OverrideSettingMethod

- (void)setCustomEdgesForExtendedLayout:(UIRectEdge)customEdgesForExtendedLayout
{
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = customEdgesForExtendedLayout;
        _customEdgesForExtendedLayout = customEdgesForExtendedLayout;
    }
}

- (void)setNavigationBarTintColor:(UIColor *)navigationBarTintColor
{
    _navigationBarTintColor = navigationBarTintColor;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.tintColor = navigationBarTintColor;
    if([navigationBar respondsToSelector:@selector(barTintColor)])
    {
        navigationBar.barTintColor = navigationBarTintColor;
    }
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.navigationItem.title = titleText;
}

- (void)setBackButtonVisible:(BOOL)backButtonVisible
{
    if(_backButtonVisible != backButtonVisible)
    {
        _backButtonVisible = backButtonVisible;
        self.backButton.hidden = !backButtonVisible;
    }
}

#pragma mark - HUD

- (void)showProgressHUDWithLabelText:(NSString *)text
{
    [self.hudManager progressHUDShowWithText:text];
}

- (void)showProgressCompleteWithLabelText:(NSString *)text isSucceed:(BOOL)isSucceed
{
    [self.hudManager progressHUDShowWithCompleteText:text isSucceed:isSucceed];
}

- (void)momentaryShowProgressHUDWithLabelText:(NSString *)text additionalTarget:(id)target action:(SEL)action object:(id)object
{
    [self.hudManager progressHUDMomentaryShowWithText:text target:target action:action object:object];
}

- (void)showProgressCompleteWithLabelText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object
{
    [self.hudManager progressHUDShowWithCompleteText:text isSucceed:isSucceed additionalTarget:target action:action object:object];
}

- (void)hiddenProgressHUD
{
    [self.hudManager progressHUDHideImmediately];
}

#pragma mark - NoticeBar

- (void)noticeBarCreate
{
    self.noticeBar = [[BONoticeBar alloc] initWithMasterView:self.view];
    self.noticeBar.centerPoint = CGPointMake(self.view.innerCenter.x, self.view.height - 100);
}

- (void)setNoticeText:(NSString *)noticeText
{
    if(!self.noticeBar)
    {
        [self noticeBarCreate];
    }
    self.noticeBar.noticeText = noticeText;
}

- (void)setNoticeBarCenter:(CGPoint)noticeBarCenter
{
    if(!self.noticeBar)
    {
        [self noticeBarCreate];
    }
    self.noticeBar.centerPoint = noticeBarCenter;
}

- (void)setIsNoticeStyleBlack:(BOOL)isNoticeStyleBlack
{
    if(!self.noticeBar)
    {
        [self noticeBarCreate];
    }
    self.noticeBar.style = isNoticeStyleBlack ? BONoticeBarStyleBlack : BONoticeBarStyleWhite;
}

#pragma mark - URLRequest

- (BOOL)networkIsValid
{
    return [TYDPostUrlRequest networkConnectionIsAvailable];
}

- (void)postURLRequestFailed:(NSUInteger)msgCode result:(id)result
{
    [self hiddenProgressHUD];
    [self setNoticeText:sNetworkError];
    
    NSError *error = result;
    NSLog(@"httpRequestFailed! msgCode:%lu, Error - %@ %@", (unsigned long)msgCode, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)postURLRequestWithMessageCode:(NSUInteger)msgCode
                         HUDLabelText:(NSString *)text
                               params:(NSMutableDictionary *)params
                        completeBlock:(PostUrlRequestCompleteBlock)completeBlock
{
    [self showProgressHUDWithLabelText:text];
    
    if(![self networkIsValid])
    {
        [self hiddenProgressHUD];
        [self setNoticeText:sNetworkFailed];
        return;
    }
    __weak typeof(self) wself = self;
    [TYDPostUrlRequest postUrlRequestWithMessageCode:msgCode
                                              params:params
                                       completeBlock:completeBlock
                                         failedBlock:^(NSUInteger msgCode, id result) {
                                             [wself postURLRequestFailed:msgCode result:result];
                                         }];
}

#pragma mark - TYDSuspendEventDelegate

- (void)applicationWillEnterForeground
{}

- (void)applicationDidBecomeActive
{}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
