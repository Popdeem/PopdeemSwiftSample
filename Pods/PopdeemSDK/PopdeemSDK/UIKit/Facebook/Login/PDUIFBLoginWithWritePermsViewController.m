//
//  PDUIFBLoginWithWritePermsViewController.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 26/07/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import "PDUIFBLoginWithWritePermsViewController.h"
#import "PDUtils.h"
#import "PopdeemSDK.h"
#import "PDConstants.h"
#import "PDAPIClient.h"
#import "PDTheme.h"
#import "PDSocialMediaManager.h"
#import "PDUIModalLoadingView.h"
#import "PDUser.h"

@interface PDUIFBLoginWithWritePermsViewController ()

@end

@implementation PDUIFBLoginWithWritePermsViewController

- (instancetype) initForParent:(UIViewController*)parent loginType:(PDFacebookLoginType)loginType {
	_connected = NO;
  _success = NO;
	if (self = [super init]) {
		_parent = parent;
		self.viewModel = [[PDUIFBLoginWithWritePermsViewModel alloc] initForParent:self loginType:loginType];
		return self;
	}
	return nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[_viewModel setup];
	[self.view setBackgroundColor:[UIColor clearColor]];
	self.backingView = [[UIView alloc] initWithFrame:_parent.view.frame];
	[self.backingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
	[self.view addSubview:_backingView];
	UITapGestureRecognizer *backingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
	[_backingView addGestureRecognizer:backingTap];
	
	_cardView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:_cardView];
	_label = [[UILabel alloc] initWithFrame:CGRectZero];
	[_cardView addSubview:_label];
	_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	[_cardView addSubview:_imageView];
	_actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_actionButton setBackgroundColor:[UIColor clearColor]];
	[_cardView addSubview:_actionButton];
	[self renderView];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) renderView {
	
	CGFloat currentY = 0;
	
	CGFloat cardWidth = _parent.view.frame.size.width * 0.8;
	CGFloat cardHeight = _parent.view.frame.size.height * 0.80;
	CGFloat cardX = _parent.view.frame.size.width * 0.1;
	CGRect cardRect = CGRectMake(cardX, _parent.view.frame.size.height, cardWidth, cardHeight);
	
	_cardView.frame = cardRect;
	[_cardView setBackgroundColor:[UIColor whiteColor]];
	_cardView.layer.cornerRadius = 5.0;
	_cardView.layer.masksToBounds = YES;
	
	CGFloat cardCenterX = cardWidth/2;
	CGFloat imageWidth = cardWidth * 0.35;
	
	CGFloat labelPadding = cardWidth*0.10;
	currentY += 20;
	self.label = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, currentY, cardWidth-(2*labelPadding), 60)];
	[self.label setNumberOfLines:0];
	[self.label setFont:_viewModel.labelFont];
	[self.label setTextColor:_viewModel.labelColor];
	[self.label setText:_viewModel.labelText];
	[self.label setTextAlignment:NSTextAlignmentCenter];
	[self.label sizeToFit];
	CGSize labelSize = [_label sizeThatFits:_label.bounds.size];
	[self.label setFrame:CGRectMake(_label.frame.origin.x, currentY , _label.frame.size.width, labelSize.height)];
	[_cardView addSubview:_label];
	
	currentY += 40 + labelSize.height;
	
	self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cardCenterX-(imageWidth/2), currentY, imageWidth, imageWidth)];
	[self.imageView setImage:_viewModel.logoImage];
	_imageView.layer.cornerRadius = 2.0;
	_imageView.layer.masksToBounds = YES;
	[_cardView addSubview:_imageView];
	currentY += imageWidth + 40;
	
	CGRect buttonFrame = CGRectMake(10, currentY, cardWidth-20, 40);
	
	self.actionButton = [[UIButton alloc] initWithFrame:buttonFrame];
	[_actionButton setBackgroundColor:_viewModel.buttonColor];
	[_actionButton.titleLabel setFont:_viewModel.buttonLabelFont];
	[_actionButton setTitle:_viewModel.buttonText forState:UIControlStateNormal];
	[_actionButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
	[_actionButton setTag:0];
	[_actionButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[_cardView addSubview:_actionButton];
	currentY += 40;
	
	CGFloat totalCardHeight = currentY + 20;
	_cardX = cardX;
	_cardY = (_parent.view.frame.size.height - totalCardHeight)/2;
	[_cardView setFrame:CGRectMake(_cardX, _cardY, cardWidth, totalCardHeight)];

	[self.view setNeedsDisplay];
}

- (void) buttonPressed:(UIButton*)button {
	if (!_connected) {
		switch (_viewModel.loginType) {
			case PDFacebookLoginTypeRead:
			[self connectRead];
    break;
		case PDFacebookLoginTypePublish:
			[self connectRead];
		break;
		default:
    break;
		}
	}
}

- (void) connectRead {
	[_actionButton setUserInteractionEnabled:NO];
    __weak __typeof(self) weakSelf = self;
	__block UIAlertView *av;
	__block PDUIModalLoadingView *loadingView = [[PDUIModalLoadingView alloc] initForView:self.view
    titleText: translationForKey(@"popdeem.loading.loggingInText", @"Logging in")
    descriptionText: translationForKey(@"popdeem.loading.pleaseWaitText", @"Please wait while we log you in")];
	[loadingView showAnimated:YES];
	PDSocialMediaManager *manager = [[PDSocialMediaManager alloc] initForViewController:self];
	[manager loginWithFacebookReadPermissions:FACEBOOK_PERMISSIONS

																							 registerWithPopdeem:YES
																													 success:^{
		[[PDUser sharedInstance] refreshFacebookFriendsCallback:^(BOOL response){
		}];
																														 [loadingView hideAnimated:YES];
																														 [self dismissViewControllerAnimated:YES completion:^{
																															 [[NSNotificationCenter defaultCenter] postNotificationName:FacebookLoginSuccess object:nil];
																														 }];
	} failure:^(NSError *err) {
		if ([err.domain isEqualToString:@"Popdeem.Facebook.Cancelled"]) {
			av = [[UIAlertView alloc] initWithTitle:translationForKey(@"popdeem.common.facebookLoginCancelledTitle",@"Login Cancelled")
																			message:translationForKey(@"popdeem.common.facebookLoginCancelledBody",@"You must log in with Facebook to avail of social rewards")
																		 delegate:self
														cancelButtonTitle:@"OK"
														otherButtonTitles: nil];
      weakSelf.success = NO;
      dispatch_async(dispatch_get_main_queue(), ^{
        [av show];
      });
			AbraLogEvent(ABRA_EVENT_CANCELLED_FACEBOOK_LOGIN, nil);
    } else if ([[err.userInfo objectForKey:@"NSLocalizedDescription"] rangeOfString:@"already _connected"].location != NSNotFound) {
      dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry - Wrong Account" message:@"This social account has been linked to another user." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        weakSelf.success = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
          [av show];
        });
      });
    } else  {
			av = [[UIAlertView alloc] initWithTitle:@"Something went wrong"
																			message:@"Please try again later"
																		 delegate:self
														cancelButtonTitle:@"OK"
														otherButtonTitles: nil];
      weakSelf.success = NO;
      dispatch_async(dispatch_get_main_queue(), ^{
        [av show];
      });
			PDLogError(@"Error: %@", err.localizedDescription);
		}
	}];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	__weak typeof(self) weakSelf = self;
  [self dismissViewControllerAnimated:YES completion:^{
    if (self.viewModel.loginType == PDFacebookLoginTypeRead) {
      if (_success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FacebookLoginSuccess object:nil];
      } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:FacebookLoginFailure object:nil];
      }
    } else {
      if (weakSelf.success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FacebookPublishSuccess object:nil];
      } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:FacebookPublishFailure object:nil];
      }
    }
	}];
}

- (void) dismiss {
	switch (_viewModel.loginType) {
			case PDFacebookLoginTypeRead:
			if (_connected) {
				[[NSNotificationCenter defaultCenter] postNotificationName:FacebookLoginSuccess object:nil];
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:FacebookLoginFailure object:nil];
			}
			break;
		case PDFacebookLoginTypePublish:
			if (_connected) {
				[[NSNotificationCenter defaultCenter] postNotificationName:FacebookPublishSuccess object:nil];
			} else {
				[[NSNotificationCenter defaultCenter] postNotificationName:FacebookPublishFailure object:nil];
			}
			break;
	}
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
