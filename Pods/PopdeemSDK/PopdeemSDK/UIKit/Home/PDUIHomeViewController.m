//
//  PDHomeViewController.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 05/01/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import "PopdeemSDK.h"
#import "PDUIHomeViewController.h"
#import "PDTheme.h"
#import "PDUtils.h"
#import "PDAPIClient.h"
#import "PDUINoRewardsTableViewCell.h"
#import "PDUIPhotoCell.h"
#import "PDUICheckinCell.h"
#import "PDUIClaimViewController.h"
#import "PDUIHomeViewModel.h"
#import "PDSocialMediaManager.h"
#import "PDUIFeedImageViewController.h"
#import "PDRewardActionAPIService.h"
#import "PDUIRedeemViewController.h"
#import "PDLocationValidator.h"
#import "PDUIRewardWithRulesTableViewCell.h"
#import "PDUIWalletRewardTableViewCell.h"
#import "PDUIInstagramUnverifiedWalletTableViewCell.h"
#import "PDUIFBLoginWithWritePermsViewController.h"
#import "PDUINoRewardTableViewCell.h"
#import "PDUISettingsViewController.h"
#import "PDUIInboxButton.h"
#import "PDBrandApiService.h"
#import "PDUISocialLoginHandler.h"
#import "PDUIRewardV2TableViewCell.h"
#import "ProfileTableViewCell.h"
#import "PDUIProfileButtonTableViewCell.h"
#import "PDUIGratitudeViewController.h"
#import "PDUserAPIService.h"
#import "PDUICustomBadge.h"
#import "PDMessageStore.h"
#import "PDTierEvent.h"
#import "PDUITierEventTableViewCell.h"
#import "PDCustomer.h"
#import "PDUIClaimV2ViewController.h"


#define kPlaceholderCell @"PlaceholderCell"
#define kRewardWithRulesTableViewCell @"RewardWithRulesCell"
#define kRewardV2Cell @"RewardV2Cell"
#define kWalletTableViewCell @"WalletCell"
#define kInstaUnverifiedTableViewCell @"kInstaUnverifiedTableViewCell"
#define kNoRewardsCell @"NoRewardsCell"
#define kNProfileCell @"ProfileCell"
#define kProfileButtonCell @"PDUIProfileButtonTableViewCell"
#define kTierCell @"PDUITierEventTableViewCell"

@interface PDUIHomeViewController () {
  BOOL rewardsLoading, feedLoading, walletLoading;
  NSIndexPath *walletSelectedIndex;
  
  BOOL claimAction;
  BOOL autoVerify;
  NSInteger verifyRewardId;
  BOOL firstLaunch;
}
@property (nonatomic, retain) PDUIHomeViewModel *model;
@property (nonatomic) PDUIClaimViewController *claimVC;
@property (nonatomic) BOOL *loggingIn;
@property (nonatomic, strong) PDLocationValidator *locationValidator;
@property (nonatomic, retain) UIColor *startingNavColor;
@property (nonatomic, retain) UIColor *startingNavTextColor;
@property (nonatomic, retain) UIView *historySectionView;

@end

@implementation PDUIHomeViewController



- (instancetype) initFromNib {
  NSBundle *podBundle = [NSBundle bundleForClass:[PopdeemSDK class]];
  if (self = [self initWithNibName:@"PDUIHomeViewController" bundle:podBundle]) {
    self.model = [[PDUIHomeViewModel alloc] initWithController:self];
    self.claimVC = [[PDUIClaimViewController alloc] initFromNib];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    return self;
  }
  return nil;
}

- (instancetype) init {
  if (self = [self initFromNib]) {
    _brand = nil;
    return self;
  }
  return nil;
}

- (instancetype) initWithBrand:(PDBrand*)b {
  if (self = [self initFromNib]) {
    _brand = b;
    _model.brand = b;
    return self;
  }
  return nil;
}

- (instancetype) initWithBrandId:(NSInteger)brandId {
  if (self = [self initFromNib]) {
    PDBrand *b = [PDBrandStore findBrandByIdentifier:brandId];
    if (!b) {
      PDLog(@"Error finding brand with ID: %ld", brandId);
      return nil;
    }
    _brand = b;
    _model.brand = b;
    return self;
  }
  return nil;
}

- (void) awakeFromNib {
  [super awakeFromNib];
  self.model = [[PDUIHomeViewModel alloc] initWithController:self];
}

- (void)renderView {
  self.loadingView = [[PDUIModalLoadingView alloc] initWithDefaultsForView:self.view];
  [self.model setupView];
}

- (void) viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self.model updateSubViews];
  [self.view setNeedsDisplay];
  self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}



- (void) registerNibs {
  NSBundle *podBundle = [NSBundle bundleForClass:[PopdeemSDK class]];
  UINib *pcnib = [UINib nibWithNibName:@"PlaceholderTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:pcnib forCellReuseIdentifier:kPlaceholderCell];
  
  UINib *rwrcnib = [UINib nibWithNibName:@"PDUIRewardWithRulesTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:rwrcnib forCellReuseIdentifier:kRewardWithRulesTableViewCell];
  
  UINib *rwrc2nib = [UINib nibWithNibName:@"PDUIRewardV2TableViewCell" bundle:podBundle];
  [[self tableView] registerNib:rwrc2nib forCellReuseIdentifier:kRewardV2Cell];
  
  UINib *walletnib = [UINib nibWithNibName:@"PDUIWalletRewardTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:walletnib forCellReuseIdentifier:kWalletTableViewCell];
  
  UINib *instaUnverified = [UINib nibWithNibName:@"PDUIInstagramUnverifiedWalletTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:instaUnverified forCellReuseIdentifier:kInstaUnverifiedTableViewCell];
  
  UINib *noRewards = [UINib nibWithNibName:@"PDUINoRewardTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:noRewards forCellReuseIdentifier:kNoRewardsCell];
  
  UINib *profile = [UINib nibWithNibName:@"ProfileTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:profile forCellReuseIdentifier:kNProfileCell];
  
  UINib *profileButton = [UINib nibWithNibName:@"PDUIProfileButtonTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:profileButton forCellReuseIdentifier:kProfileButtonCell];
  
  UINib *tierCell = [UINib nibWithNibName:@"PDUITierEventTableViewCell" bundle:podBundle];
  [[self tableView] registerNib:tierCell forCellReuseIdentifier:kTierCell];
  
    
}

- (void) viewDidDisappear:(BOOL)animated {
  if (@available(iOS 11.0, *)) {
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.navigationController.navigationBar.translucent = YES;
  }
}

- (void)viewDidLoad {
    
    //UIView *noActionPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 600)];
    //noActionPopup.backgroundColor = UIColor.blueColor;
    //[self.tableView addSubview:noActionPopup];
    
  firstLaunch = YES;
  if (_brandVendorSearchTerm != nil) {
    _brand = [PDBrandStore findBrandBySearchTerm:_brandVendorSearchTerm];
    _model.brand = _brand;
    [self setup];
  } else {
    [self setup];
  }
  if (@available(iOS 11.0, *)) {
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.navigationController.navigationBar.translucent = YES;
  }
  
}

- (void) setup {
  
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:FacebookLoginSuccess object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedItemDidDownload) name:@"PDFeedItemImageDidDownload" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coverImageDidDownload) name:@"PDRewardCoverImageDidDownload" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:PDUserDidLogout object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postVerified) name:InstagramVerifySuccessFromWallet object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(instagramPostMade:) name:InstagramPostMade object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:_model selector:@selector(fetchInbox) name:PopdeemNotificationReceived object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:PDUserDidLogin object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateUser) name:PDUserDidUpdate object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateTableView) name:ShouldUpdateTableView object:nil];
  [self registerNibs];
  [super viewDidLoad];
  
  [self.tableView setUserInteractionEnabled:YES];
  //  if (_brand) {
  //    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 190)];
  //  } else {
  self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
  //  }
  
  [self styleNavbar];
  
  if (PopdeemThemeHasValueForKey(@"popdeem.images.tableViewBackgroundImage")) {
    UIImageView *tvbg = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    [tvbg setImage:PopdeemImage(@"popdeem.images.tableViewBackgroundImage")];
    [self.tableView setBackgroundView:tvbg];
  }
    
    // fix for scroll glitch iOS 11
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
  
  self.refreshControl = [[UIRefreshControl alloc]init];
  [self.refreshControl setTintColor:[UIColor darkGrayColor]];
  [self.refreshControl setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
  [self.refreshControl addTarget:self action:@selector(reloadAction) forControlEvents:UIControlEventValueChanged];
  
  
  self.title = translationForKey(@"popdeem.home.title", @"Rewards");
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.view setBackgroundColor:PopdeemColor(PDThemeColorViewBackground)];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.model fetchRewards];
    if (self.model.feed.count == 0) {
      [self.model fetchFeed];
    }
    [self.model fetchWallet];
    [self.model fetchInbox];
  });
  
  self.model.feed = [PDFeeds feed];
  
  if (!_segmentedControl) {
    _segmentedControl = [[PDUISegmentedControl alloc] initWithItems:@[
                                                                      translationForKey(@"popdeem.home.segmentedControl.rewards", @"Rewards"),
                                                                      translationForKey(@"popdeem.home.segmentedControl.activity", @"Activity"),
                                                                      translationForKey(@"popdeem.home.segmentedControl.wallet", @"Profile")
                                                                      ]];
    _segmentedControl.parentView = self.view;
    if (_brand.theme) {
      [_segmentedControl applyTheme:_brand.theme];
    }
    _segmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    _segmentedControl.clipsToBounds = YES;
    
    //    CALayer *topBottomBorders = [CALayer layer];
    //    topBottomBorders.borderColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0].CGColor;
    //    topBottomBorders.borderWidth = 0.5;
    //    topBottomBorders.frame = CGRectMake(-1, 0, _segmentedControl.frame.size.width+2, _segmentedControl.frame.size.height);
    //    [_segmentedControl.layer addSublayer:topBottomBorders];
    [_segmentedControl addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  }
  
  UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  
  // Setting the swipe direction.
  [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
  [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
  
  // Adding the swipe gesture on image view
  [self.tableView addGestureRecognizer:swipeLeft];
  [self.tableView addGestureRecognizer:swipeRight];
  
  _historySectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
  UILabel *historyTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 40)];
  [historyTitleLabel setText:translationForKey(@"popdeem.profile.myHistoryText", @"MY HISTORY")];
  [historyTitleLabel setFont:PopdeemFont(PDThemeFontBold, 12)];
  [historyTitleLabel setTextColor:[UIColor blackColor]];
  [_historySectionView addSubview:historyTitleLabel];
  [_historySectionView setBackgroundColor:[UIColor whiteColor]];
  
  [self renderView];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
  
  NSInteger selected = _segmentedControl.selectedSegmentIndex;
  if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
    switch (selected) {
        case 0:
        return;
        break;
      default:
        [_segmentedControl setSelectedSegmentIndex:selected-1];
        [self.tableView reloadData];
        break;
    }
  }
  
  if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
    switch (selected) {
        case 2:
        return;
        break;
      default:
        [_segmentedControl setSelectedSegmentIndex:selected+1];
        [self.tableView reloadData];
        break;
    }
  }
}

- (void) inboxAction {
  PDUIMsgCntrTblViewController *mvc = [[PDUIMsgCntrTblViewController alloc] initFromNib];
  [self.navigationController pushViewController:mvc animated:YES];
}
- (void) settingsAction {
  PDUISettingsViewController *mvc = [[PDUISettingsViewController alloc] initFromNib];
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
  [self.navigationController pushViewController:mvc animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
  self.title = translationForKey(@"popdeem.home.title", @"Rewards");
  [self.view setUserInteractionEnabled:YES];

//    if (!firstLaunch) {
//        [_model fetchRewards];
//        [_model fetchWallet];
//    }
    firstLaunch = NO;
  if (_loadingView && !_loggingIn) {
    [_loadingView hideAnimated:YES];
  }
  if (_didLogin) {
    [self userDidLogin];
  }
  AbraLogEvent(ABRA_EVENT_PAGE_VIEWED, @{ABRA_PROPERTYNAME_SOURCE_PAGE : ABRA_PROPERTYVALUE_PAGE_REWARDS_HOME});
  [self styleNavbar];
}

- (void) viewWillAppear:(BOOL)animated {
  if (_didClaim) {
    claimAction = NO;
    _didClaim = NO;
    //[_segmentedControl setSelectedSegmentIndex:2];
    [_model fetchWallet];
    _model.rewards = [PDRewardStore orderedByDistanceFromUser];
    [_model fetchWallet];
    [self.tableView reloadData];
    [self.tableView reloadInputViews];
    PDUIGratitudeViewController *gViewController = [[PDUIGratitudeViewController alloc] initWithType:PDGratitudeTypeShare reward:self.willClaimReward];
    
    [self presentViewController:gViewController animated:NO completion:^{
      
    }];
    PDUserAPIService *service = [[PDUserAPIService alloc] init];
    NSString *ident = [NSString stringWithFormat:@"%ld",[[PDUser sharedInstance] identifier]];
    [service getUserDetailsForId:ident authenticationToken:[[PDUser sharedInstance] userToken] completion:^(PDUser *user, NSError *error) {
      PDLog(@"Fetch User Details");
      [self.tableView reloadData];
      [self.tableView reloadInputViews];
    }];
  }
}

- (void) styleNavbar {
  if (PopdeemThemeHasValueForKey(@"popdeem.nav")) {
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:PopdeemColor(PDThemeColorPrimaryApp)];
    [self.navigationController.navigationBar setTintColor:PopdeemColor(PDThemeColorPrimaryInverse)];
    
    UIFont *headerFont;
    if (PopdeemThemeHasValueForKey(PDThemeFontNavbar)) {
      headerFont = PopdeemFont(PDThemeFontNavbar, 22.0f);
    } else {
      headerFont = PopdeemFont(PDThemeFontBold, 17.0f);
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : PopdeemColor(PDThemeColorPrimaryInverse),
                                                                      NSFontAttributeName : headerFont
                                                                      }];
    
    [self.navigationController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                                          NSForegroundColorAttributeName : PopdeemColor(PDThemeColorPrimaryInverse),
                                                                                          NSFontAttributeName : PopdeemFont(PDThemeFontNavbar, 17.0f)}
                                                                               forState:UIControlStateNormal];
    if (PopdeemThemeHasValueForKey(@"popdeem.images.navigationBar")){
      [self.navigationController.navigationBar setBackgroundImage:PopdeemImage(@"popdeem.images.navigationBar") forBarMetrics:UIBarMetricsDefault];
    }
    if (@available(iOS 11.0, *)) {
      self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
      self.navigationController.navigationBar.translucent = YES;
    }
  }
  
  //Brand Specific Theme
  if (_brand.theme != nil) {
    _startingNavColor = self.navigationController.navigationBar.barTintColor;
    _startingNavTextColor = self.navigationController.navigationBar.tintColor;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:PopdeemColorFromHex(_brand.theme.primaryAppColor)];
    [self.navigationController.navigationBar setTintColor:PopdeemColorFromHex(_brand.theme.primaryInverseColor)];
    
    UIFont *headerFont;
    if (PopdeemThemeHasValueForKey(PDThemeFontNavbar)) {
      headerFont = PopdeemFont(PDThemeFontNavbar, 17.0f);
    } else {
      headerFont = PopdeemFont(PDThemeFontBold, 17.0f);
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : PopdeemColorFromHex(_brand.theme.primaryInverseColor),
                                                                      NSFontAttributeName : headerFont
                                                                      }];
    
    [self.navigationController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                                          NSForegroundColorAttributeName : PopdeemColorFromHex(_brand.theme.primaryInverseColor),
                                                                                          NSFontAttributeName : PopdeemFont(PDThemeFontPrimary, 16.0f)}
                                                                               forState:UIControlStateNormal];
  }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  //    if ([self.refreshControl isRefreshing]) {
  //        [self reloadAction];
  //    }
}

- (void) reloadAction {
  switch (self.segmentedControl.selectedSegmentIndex) {
      case 0:
      [self.model fetchRewards];
      break;
      case 1:
      [self.model fetchFeed];
      break;
      case 2:
      [self.model fetchWallet];
      break;
    default:
      break;
  }
  [self.refreshControl endRefreshing];
}

- (void) viewWillLayoutSubviews {
  //  [_model viewWillLayoutSubviews];
}

- (void) viewWillDisappear:(BOOL)animated {
  if (_loadingView && !_loggingIn) {
    [_loadingView hideAnimated:YES];
  }
}


- (void) segmentedControlDidChangeValue:(PDUISegmentedControl*)sender {
  BOOL shouldNav = self.tableView.contentOffset.y > self.tableView.tableHeaderView.frame.size.height;
  [self.tableView reloadData];
  [self.tableView reloadInputViews];
  [self.tableView reloadSectionIndexTitles];
  switch(sender.selectedSegmentIndex) {
      case 0:
      AbraLogEvent(ABRA_EVENT_PAGE_VIEWED, @{ABRA_PROPERTYNAME_SOURCE_PAGE : ABRA_PROPERTYVALUE_PAGE_REWARDS_HOME});
      break;
      case 1:
      AbraLogEvent(ABRA_EVENT_PAGE_VIEWED, @{ABRA_PROPERTYNAME_SOURCE_PAGE : ABRA_PROPERTYVALUE_PAGE_ACTIVITY_FEED});
      break;
      case 2:
      AbraLogEvent(ABRA_EVENT_PAGE_VIEWED, @{ABRA_PROPERTYNAME_SOURCE_PAGE : ABRA_PROPERTYVALUE_PAGE_WALLET});
      break;
    default:
      break;
  }
  if (shouldNav) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  switch (_segmentedControl.selectedSegmentIndex) {
      case 0:
      return 1;
      break;
      case 1:
      return 1;
      break;
      case 2:
      return 2;
      break;
    default:
      return 1;
      break;
  }
}

- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if (section == 0 && _segmentedControl.selectedSegmentIndex != 2) {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1.0f)];
    [footerView setBackgroundColor:PopdeemColor(PDThemeColorTableViewSeperator)];
    return footerView;
  }
  return nil;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return _segmentedControl;
  }
  if (_segmentedControl.selectedSegmentIndex == 2 && section == 1) {
    return _historySectionView;
  }
  return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 40;
  }
  if (section == 1) {
    return 40;
  }
  return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 0.5f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (_segmentedControl.selectedSegmentIndex) {
      case 0:
      return _model.rewards.count > 0 ? _model.rewards.count : 1;
      break;
      case 1:
      return _model.feed.count > 0 ? _model.feed.count : 1;
      break;
      case 2:
      if (section == 0) {
        if ([[PDUser sharedInstance] isRegistered]) {
          return 3;
        } else {
          return 2;
        }
      } else if (section == 1) {
        return _model.wallet.count > 0 ? _model.wallet.count : 1;
      }
      return 1;
      break;
    default:
      return 1;
  }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PDReward *reward;
  PDRFeedItem *feedItem;
  switch (_segmentedControl.selectedSegmentIndex) {
      case 0:
      if (_model.rewards.count == 0) {
        if (!_model.rewardsLoading) {
          PDUINoRewardTableViewCell *norw = [[self tableView] dequeueReusableCellWithIdentifier:kNoRewardsCell];
          if (_brand.theme != nil) {
            [norw setTheme:_brand.theme];
          }
          [norw setupWithMessage:translationForKey(@"popdeem.home.infoCell.noRewards",@"There are no Rewards available right now.\nPlease check back later.")];
          return norw;
        } else {
          return [self.tableView dequeueReusableCellWithIdentifier:kPlaceholderCell];
        }
      } else {
        reward = [_model.rewards objectAtIndex:indexPath.row];
        PDUIRewardV2TableViewCell *rwrcell = [self.tableView dequeueReusableCellWithIdentifier:kRewardV2Cell];
        if (_brand.theme != nil) {
          [rwrcell setupForReward:reward theme:_brand.theme];
        } else {
          [rwrcell setupForReward:reward];
        }
        if (rwrcell.rewardImageView.image == nil) {
          NSURL *url = [NSURL URLWithString:reward.coverImageUrl];
          NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
              UIImage *image = [UIImage imageWithData:data];
              if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  id updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                  if (updateCell != nil && [updateCell isKindOfClass:[PDUIRewardV2TableViewCell class]]) {
                    PDUIRewardV2TableViewCell *updaterwrcell = (PDUIRewardV2TableViewCell*)updateCell;
                    updaterwrcell.rewardImageView.image = image;
                    reward.coverImage = image;
                  }
                });
              }
            }
          }];
          [task2 resume];
        }
        return rwrcell;
      }
      break;
      case 1:
      //Feeds
      if (_model.feed.count == 0) {
        if (!_model.feedLoading) {
          PDUINoRewardTableViewCell *norw = [[self tableView] dequeueReusableCellWithIdentifier:kNoRewardsCell];
          if (_brand.theme != nil) {
            [norw setTheme:_brand.theme];
          }
          [norw setupWithMessage:translationForKey(@"popdeem.home.infoCell.noFeed",@"There is nothing in the feed right now.\nPlease check back later.")];
          return norw;
        } else {
          return [self.tableView dequeueReusableCellWithIdentifier:kPlaceholderCell];
        }
      } else {
        if (feedLoading) {
          return [self.tableView dequeueReusableCellWithIdentifier:kPlaceholderCell];
        }
        if (indexPath.row >= _model.feed.count) {
          return [self.tableView dequeueReusableCellWithIdentifier:kPlaceholderCell];
        }
        feedItem = [_model.feed objectAtIndex:indexPath.row];
        float width = self.view.frame.size.width;
        float feedHeight = 65 + 80 + 20 + width;
        return [[PDUIFeedCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, feedHeight) forFeedItem:feedItem];
      }
      break;
      case 2:
      if (indexPath.section == 0) {
        if ([[PDUser sharedInstance] isRegistered]) {
          if (indexPath.row == 0) {
            ProfileTableViewCell *profile = [[self tableView] dequeueReusableCellWithIdentifier:kNProfileCell];
            [profile setProfile];
            return profile;
          }
          if (indexPath.row == 1) {
            PDUIProfileButtonTableViewCell *socialAccountCell = [[self tableView] dequeueReusableCellWithIdentifier:kProfileButtonCell];
            [socialAccountCell.label setText:translationForKey(@"popdeem.profile.connectSocialAccountsText", @"Connect Social Media Accounts")];
            socialAccountCell.shouldShowBadge = NO;
            return socialAccountCell;
          }
          if (indexPath.row == 2) {
            PDUIProfileButtonTableViewCell *messagesCell = [[self tableView] dequeueReusableCellWithIdentifier:kProfileButtonCell];
            [messagesCell.label setText:translationForKey(@"popdeem.profile.messagesTitleText", @"Messages")];
            messagesCell.shouldShowBadge = YES;
            if ([PDMessageStore unreadCount] > 0) {
              [messagesCell showBadge:YES];
            } else {
              [messagesCell showBadge:NO];
            }
            return messagesCell;
          }
        } else {
          if (indexPath.row == 0) {
            PDUIProfileButtonTableViewCell *socialAccountCell = [[self tableView] dequeueReusableCellWithIdentifier:kProfileButtonCell];
            [socialAccountCell.label setText:translationForKey(@"popdeem.profile.connectSocialAccountsText", @"Connect Social Media Accounts")];
            socialAccountCell.shouldShowBadge = NO;
            return socialAccountCell;
          }
          if (indexPath.row == 1) {
            PDUIProfileButtonTableViewCell *messagesCell = [[self tableView] dequeueReusableCellWithIdentifier:kProfileButtonCell];
            [messagesCell.label setText:translationForKey(@"popdeem.profile.messagesTitleText", @"Messages")];
            messagesCell.shouldShowBadge = YES;
            if ([PDMessageStore unreadCount] > 0) {
              [messagesCell showBadge:YES];
            } else {
              [messagesCell showBadge:NO];
            }
            return messagesCell;
          }
        }
        if (indexPath.row == 0) {
          ProfileTableViewCell *profile = [[self tableView] dequeueReusableCellWithIdentifier:kNProfileCell];
          [profile setProfile];
          return profile;
        }
      } else {
        if (_model.wallet.count == 0) {
          if (!_model.walletLoading) {
            PDUINoRewardTableViewCell *norw = [[self tableView] dequeueReusableCellWithIdentifier:kNoRewardsCell];
            if (_brand.theme != nil) {
              [norw setTheme:_brand.theme];
            }
            [norw setupWithMessage:translationForKey(@"popdeem.home.infoCell.noWallet",@"There is nothing in your history right now.\nPlease check back later.")];
            return norw;
          } else {
            return [self.tableView dequeueReusableCellWithIdentifier:kPlaceholderCell];
          }
        } else if (_model.wallet.count > indexPath.row) {
          id item = [_model.wallet objectAtIndex:indexPath.row];
          if ([item isKindOfClass:[PDReward class]]) {
            reward = (PDReward*)item;
            if (reward.claimedSocialNetwork == PDSocialMediaTypeInstagram &&
                reward.instagramVerified == NO &&
                reward.autoDiscovered == NO) {
              PDUIInstagramUnverifiedWalletTableViewCell *walletCell = [self.tableView dequeueReusableCellWithIdentifier:kInstaUnverifiedTableViewCell];
              [walletCell setupForReward:reward];
              if (autoVerify && verifyRewardId == reward.identifier) {
                [walletCell beginVerifying];
                autoVerify = NO;
              }
              if (walletCell.rewardImageView.image == nil) {
                NSURL *url = [NSURL URLWithString:reward.coverImageUrl];
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                  if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                        PDUIRewardWithRulesTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                          updateCell.rewardImageView.image = image;
                        }
                      });
                    }
                  }
                }];
                [task2 resume];
              }
              return walletCell;
            } else {
              PDUIWalletRewardTableViewCell *walletCell = [self.tableView dequeueReusableCellWithIdentifier:kWalletTableViewCell];
              if (_brand.theme != nil) {
                [walletCell setupForReward:reward theme:_brand.theme];
              } else {
                [walletCell setupForReward:reward];
              }
              if (walletCell.rewardImageView.image == nil) {
                NSURL *url = [NSURL URLWithString:reward.coverImageUrl];
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                  NSLog(@"Response: %@",response);
                  if (task2) {
                    [task2 cancel];
                  }
                  if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                        PDUIRewardWithRulesTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                          updateCell.rewardImageView.image = image;
                          reward.coverImage = image;
                        }
                      });
                    }
                  } else if (error) {
                    PDLog(@"Error: %@", error.localizedDescription);
                  }
                }];
                [task2 resume];
              }
              return walletCell;
            }
          } else if ([item isKindOfClass:[PDTierEvent class]]) {
            PDUITierEventTableViewCell *tierEventCell = [[self tableView] dequeueReusableCellWithIdentifier:kTierCell];
            [tierEventCell setupForTierEvent:(PDTierEvent*)item];
            return tierEventCell;
          }
        }
      }
    default:
      break;
  }
  return [[UITableViewCell alloc] init];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell isKindOfClass:[PDUIInstagramUnverifiedWalletTableViewCell class]]) {
    [(PDUIInstagramUnverifiedWalletTableViewCell*)cell wake];
  }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (_segmentedControl.selectedSegmentIndex) {
      case 0:
      return NO;
      break;
      case 1:
      return NO;
      break;
      case 2:
      return NO;
      break;
    default:
      return NO;
      break;
  }
  return NO;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  PDReward *r;
  r = [_model.wallet objectAtIndex:indexPath.row];
  
  if (r.instagramVerified == NO) {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                                                      title:translationForKey(@"popdeem.instagram.wallet.verifyButtonTitle", @"Verify")
                                                                    handler:^(UITableViewRowAction *rowAction, NSIndexPath *indexPath){
                                                                      
                                                                    }];
    action.backgroundColor = PopdeemColor(PDThemeColorPrimaryApp);
    return @[action];
  }
  return @[];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self cellHeightForIndex:indexPath];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 1) {
    return @"MY HISTORY";
  }
  return @"";
}

- (float) cellHeightForIndex:(NSIndexPath*)indexPath {
  NSInteger index = indexPath.row;
  switch (_segmentedControl.selectedSegmentIndex) {
      case 0:
      //Rewards
      if (_model.rewards.count == 0) {
        return 100;
      }
      return 200;
      break;
      case 1:
      //Feed
      if (_model.feed.count == 0) {
        return 100;
      }
      if (_model.feed.count > index && [(PDRFeedItem*)[_model.feed objectAtIndex:index] actionImageData] != nil) {
        float width = self.view.frame.size.width;
        float feedHeight = 65 + 80 + 20 + width;
        return feedHeight;
      } else {
        return 75;
      }
      break;
      case 2:
      //Wallet
      if (indexPath.section == 0) {
        if ([[PDUser sharedInstance] isRegistered]) {
          if (indexPath.row == 0) {
            //Only show the profile ambassador bar if Customer uses ambassador
            if ([[PDCustomer sharedInstance] incrementAdvocacyPoints] != nil) {
              return 125;
            } else {
              return 50;
            }
          } else {
            return 50;
          }
        } else {
          return 50;
        }
      } else {
        if (walletSelectedIndex && [indexPath isEqual:walletSelectedIndex]) {
          if (indexPath.row < _model.wallet.count) {
            PDReward *r = _model.wallet[indexPath.row];
            switch (r.type) {
                case PDRewardTypeInstant:
                case PDRewardTypeCoupon:
                return 285;
                break;
                case PDRewardTypeSweepstake:
                return 205;
                break;
              default:
                break;
            }
          }
          return 255;
        }
      }
      return 100;
      break;
    default:
      break;
  }
  return 0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  PDUIWalletRewardTableViewCell *wcell;
  PDUIWalletRewardTableViewCell *lastCell;
  //    PDReward *walletReward;
  //  __block UIAlertView *av;
  switch (_segmentedControl.selectedSegmentIndex) {
      case 0:
      //Rewards
      if (_model.rewards.count == 0) return;
      if ([_model.rewards objectAtIndex:indexPath.row]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self processClaimForIndexPath:indexPath];
        });
        return;
      }
      break;
      case 1:
      return;
      break;
      case 2:
      if (indexPath.section == 0) {
        if ([[PDUser sharedInstance] isRegistered]) {
          if (indexPath.row == 1) {
            //Settings
            [self settingsAction];
            return;
          }
          if (indexPath.row == 2) {
            //Messages
            [self messagesTapped];
            return;
          }
          return;
        } else {
          if (indexPath.row == 0) {
            //Settings
            [self settingsAction];
            return;
          }
          if (indexPath.row == 1) {
            //Messages
            [self messagesTapped];
            return;
          }
        }
      } else {
        if (_model.wallet.count == 0) return;
        _selectedWalletReward = [_model.wallet objectAtIndex:indexPath.row];
        if ([_selectedWalletReward isKindOfClass:[PDTierEvent class]]) {
          return;
        }
        if (_selectedWalletReward) {
          if (_selectedWalletReward.revoked) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Reward Revoked"
                                                         message:@"This reward has been revoked"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles: nil];
            [av show];
            return;
          }
          //For sweepstakes we dont show the alert
          if (_selectedWalletReward.type == PDRewardTypeSweepstake) {
            wcell = (PDUIWalletRewardTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [wcell setSelectionStyle:UITableViewCellSelectionStyleNone];
            if (walletSelectedIndex && [walletSelectedIndex isEqual:indexPath]) {
              lastCell = (PDUIWalletRewardTableViewCell*)[self.tableView cellForRowAtIndexPath:walletSelectedIndex];
              [lastCell rotateArrowRight];
              walletSelectedIndex = nil;
              [wcell rotateArrowRight];
            } else {
              if (walletSelectedIndex) {
                //Rotate the previous cell back to right
                PDUIWalletRewardTableViewCell *lastCell = (PDUIWalletRewardTableViewCell*)[self.tableView cellForRowAtIndexPath:walletSelectedIndex];
                [lastCell rotateArrowRight];
              }
              walletSelectedIndex = indexPath;
              [wcell rotateArrowDown];
            }
            [self.tableView reloadData];
            return;
          }
          if (_selectedWalletReward.creditString != nil && _selectedWalletReward.creditString.length > 0) {
            return;
          }
          if (_selectedWalletReward.claimedSocialNetwork == PDSocialMediaTypeInstagram && _selectedWalletReward.instagramVerified == NO) {
            return;
          }
          
          UIAlertView *av = [[UIAlertView alloc] initWithTitle:translationForKey(@"popdeem.redeem.redeemNowText", @"Redeem Reward Now?")
                                                       message:translationForKey(@"popdeem.redeem.redeemSureText", @"Are you sure you want to redeem this now?")
                                                      delegate:self
                                             cancelButtonTitle:translationForKey(@"popdeem.redeem.cancelText", @"Cancel")
                                             otherButtonTitles:translationForKey(@"popdeem.redeem.redeemText", @"Redeem"), nil];
          [av setTag:400];
          [av show];
          
        }
      }
      break;
    default:
      break;
  }
  //  [tableView beginUpdates];
  //  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  //  //if you are doing any animation you have deselect the row here inside.
  //  [tableView endUpdates];
}

- (void) redeemSelectedReward {
  walletSelectedIndex = [self.tableView indexPathForSelectedRow];
  if (!_selectedWalletReward) {
    return;
  }
  if (_selectedWalletReward.type != PDRewardTypeSweepstake) {
    PDRewardActionAPIService *service = [[PDRewardActionAPIService alloc] init];
    _loadingView = [[PDUIModalLoadingView alloc] initForView:self.navigationController.view titleText:@"Please Wait" descriptionText:@"Redeeming your Reward"];
    [_loadingView showAnimated:YES];
    __weak typeof(self) weakSelf = self;
    [service redeemReward:_selectedWalletReward.identifier completion:^(NSError *error){
      [weakSelf.loadingView hideAnimated:YES];
      if (error) {
        PDLogError(@"Something went wrong: %@",error);
      } else {
        
        PDUIRedeemViewController *rvc = [[PDUIRedeemViewController alloc] initFromNib];
        [rvc setReward:_selectedWalletReward];
        [self.navigationController pushViewController:rvc animated:YES];
        [PDWallet remove:_selectedWalletReward.identifier];
        _selectedWalletReward = nil;
        walletSelectedIndex = nil;
        _model.wallet = [PDWallet wallet];
        [self.tableView reloadData];
        if (_selectedWalletReward) {
          AbraLogEvent(ABRA_EVENT_REDEEMED_REWARD, (@{
                                                      ABRA_PROPERTYNAME_REWARD_NAME : _selectedWalletReward.rewardDescription,
                                                      ABRA_PROPERTYNAME_REWARD_ID : [NSString stringWithFormat:@
                                                                                     "%li",(long)_selectedWalletReward.identifier]
                                                      }));
        }
      }
    }];
  }
}



- (void) processClaimForIndexPath:(NSIndexPath*)indexPath {
  if (![[PDUser sharedInstance] isRegistered]) {
    PDUISocialLoginHandler *loginHandler = [[PDUISocialLoginHandler alloc] init];
    [loginHandler presentLoginModal];
    return;
  }
  PDReward *reward = [_model.rewards objectAtIndex:indexPath.row];
  if (reward.action == PDRewardActionSocialLogin) {
    if (![[PDUser sharedInstance] isRegistered]) {
      PDUISocialLoginHandler *loginHandler = [[PDUISocialLoginHandler alloc] init];
      [loginHandler presentLoginModal];
      return;
    }
    return;
  } else if (reward.action == PDRewardActionNone) {
    if (![[PDUser sharedInstance] isRegistered]) {
      PDUISocialLoginHandler *loginHandler = [[PDUISocialLoginHandler alloc] init];
      [loginHandler presentLoginModal];
      return;
    }
    
      _noActionView = [[PDUINoActionRewardView alloc] initForView:self.navigationController.view reward:reward homeVC:self];
      [_noActionView showAnimated:YES];
      

  } else {
      PDUIClaimV2ViewController *claimController = [[PDUIClaimV2ViewController alloc] initFromNib];
    claimController.closestLocation = _closestLocation;
      [claimController setupWithReward:reward];
    self.willClaimReward = reward;
//    if (_brand) {
//      claimController.brand = _brand;
//    }
//    [claimController setHomeController:self];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationController] pushViewController:claimController animated:YES];
  }
}


- (void) claimNoActionReward:(PDReward*)reward {
    [self.model claimNoAction:reward closestLocation:nil];
}


- (void) scrollToIndexPath:(NSIndexPath*)path {
  [self.tableView scrollRectToVisible:[self.tableView rectForRowAtIndexPath:path] animated:YES];
}

- (void) redeemButtonPressed {
  _selectedWalletReward = [_model.wallet objectAtIndex:walletSelectedIndex.row];
  if (_selectedWalletReward.revoked) {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Reward Revoked"
                                                 message:@"This reward has been revoked"
                                                delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles: nil];
    [av show];
    return;
  }
  //For sweepstakes we dont show the alert
  if (_selectedWalletReward.type == PDRewardTypeSweepstake) {
    return;
  }
  
  walletSelectedIndex = [self.tableView indexPathForSelectedRow];
  
  if (_selectedWalletReward.type != PDRewardTypeSweepstake) {
    PDRewardActionAPIService *service = [[PDRewardActionAPIService alloc] init];
    _loadingView = [[PDUIModalLoadingView alloc] initForView:self.navigationController.view
                                                   titleText:@"Please Wait"
                                             descriptionText:@"Redeeming your Reward"];
    [_loadingView showAnimated:YES];
    
    [service redeemReward:_selectedWalletReward.identifier completion:^(NSError *error){
      [_loadingView hideAnimated:YES];
      if (error) {
        PDLogError(@"Something went wrong: %@",error);
      } else {
        PDUIRedeemViewController *rvc = [[PDUIRedeemViewController alloc] initFromNib];
        [rvc setReward:_selectedWalletReward];
        [self.navigationController pushViewController:rvc animated:YES];
        [PDWallet remove:_selectedWalletReward.identifier];
        _selectedWalletReward = nil;
        walletSelectedIndex = nil;
        _model.wallet = [PDWallet wallet];
        [self.tableView reloadData];
      }
    }];
  }
}

- (void) messagesTapped {
  if (!_messageCenter) {
    _messageCenter = [[PDUIMsgCntrTblViewController alloc] initFromNib];
  }
  self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
  [self.navigationController pushViewController:_messageCenter animated:YES];
}

- (void) userDidLogin {
  [self.model fetchRewards];
  [self.model fetchInbox];
  self.model.feed = [PDFeeds feed];
  [self.model fetchWallet];
  AbraLogEvent(ABRA_EVENT_CONNECTED_ACCOUNT, (@{
                                                ABRA_PROPERTYNAME_SOCIAL_NETWORK : ABRA_PROPERTYVALUE_SOCIAL_NETWORK_FACEBOOK,
                                                ABRA_PROPERTYNAME_SOURCE_PAGE : @"Rewards Home"
                                                }));
  if ([[PDUser sharedInstance] advocacyScore] <= 30) {
    [self performSelector:@selector(showConnect) withObject:nil afterDelay:1.0];
  }
  
  PDUserAPIService *service = [[PDUserAPIService alloc] init];
  NSString *ident = [NSString stringWithFormat:@"%ld",[[PDUser sharedInstance] identifier]];
  [service getUserDetailsForId:ident authenticationToken:[[PDUser sharedInstance] userToken] completion:^(PDUser *user, NSError *error) {
    PDLog(@"Fetch User Details");
    [self.tableView reloadData];
    [self.tableView reloadInputViews];
  }];
  _didLogin = NO;
  //[_segmentedControl setSelectedSegmentIndex:2];
}

- (void) showConnect {
  PDUIGratitudeViewController *gViewController = [[PDUIGratitudeViewController alloc] initWithType:PDGratitudeTypeConnect];

  [self presentViewController:gViewController animated:NO completion:^{
    
  }];
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView.tag == 400) {
    switch (buttonIndex) {
        case 0:
        PDLog(@"Cancel Redeem");
        walletSelectedIndex = nil;
        _selectedWalletReward = nil;
        break;
        case 1:
        PDLog(@"Redeem");
        [self redeemSelectedReward];
        break;
      default:
        break;
    }
  } else if (alertView.tag == 2) {
    [_model fetchWallet];
    [_segmentedControl setSelectedSegmentIndex:2];
    _model.rewards = [PDRewardStore orderedByDistanceFromUser];
    [self.tableView reloadData];
    [self.tableView reloadInputViews];
    
  }
}

- (void) feedItemDidDownload {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
  });
}

- (void) coverImageDidDownload {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
  });
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self.view setNeedsLayout];
  [self.view setNeedsDisplay];
  //  if (_brand) {
  //    [self.tableView.tableHeaderView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 190)];
  //  } else {
  [self.tableView.tableHeaderView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 140)];
  //  }
}

- (void) loggedOut {
    
    NSMutableArray *newArray = _model.wallet.mutableCopy;
    [newArray removeAllObjects];
    _model.wallet = newArray.copy;
    
    [self.tableView reloadData];
    [self.tableView reloadInputViews];

}

- (void) postVerified {
  [self.model fetchWallet];
  UIAlertView *av = [[UIAlertView alloc] initWithTitle:translationForKey(@"popdeem.instagram.postVerified.title", @"Congratulations")
                                               message:translationForKey(@"popdeem.instagram.postVerified.body", @"Your post has been successfully verified.")
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
  [av show];
}

- (void) instagramPostMade:(NSNotification*)notification {
  autoVerify = YES;
  NSNumber *ident = [[notification userInfo] objectForKey:@"rewardId"];
  if (ident) {
    verifyRewardId = [ident integerValue];
  }
}

- (void) sweepstakeAlert {
  if (!_selectedWalletReward) return;
  
  
}

- (void)viewSafeAreaInsetsDidChange {
  [super viewSafeAreaInsetsDidChange];
  self.tableView.contentInset = self.view.safeAreaInsets;
}

- (void) moveToSection:(NSInteger)section {
  if (section < 3) {
    [self.segmentedControl setSelectedSegmentIndex:section];
    //[self scrollToIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [self.tableView reloadData];
    [self.tableView reloadInputViews];
  }
}

- (void) didUpdateUser {
  [self.tableView reloadInputViews];
  [self.tableView reloadData];
}

- (void) updateRewardData {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView beginUpdates];
    if (self.model.rewardRemoveIndexSets.count > 0) {
      [self.tableView deleteRowsAtIndexPaths:self.model.rewardRemoveIndexSets withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    if (self.model.rewardAddIndexSets.count > 0) {
      [self.tableView insertRowsAtIndexPaths:self.model.rewardAddIndexSets withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
  });
}

- (void) shouldUpdateTableView {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
    [self.tableView setUserInteractionEnabled:YES];
  });
}

@end
