//
//  PDUIInstagramVerifyViewModel.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 23/06/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import "PDUIInstagramVerifyViewModel.h"
#import "PDTheme.h"
#import "PDUtils.h"
#import "PDUIInstagramVerifyViewController.h"
#import "UIColor+ColorOperations.h"

@interface PDUIInstagramVerifyViewModel()
@property (nonatomic, assign) PDUIInstagramVerifyViewController *viewController;
@end

@implementation PDUIInstagramVerifyViewModel

- (instancetype) initForViewController:(PDUIInstagramVerifyViewController*)viewController {
	if (self = [super init]){
		_viewController = viewController;
		return self;
	}
	return nil;
}

- (void) setup {
	_headerColor = PopdeemColor(PDThemeColorPrimaryApp);
	_headerFontColor = PopdeemColor(PDThemeColorPrimaryInverse);
	_headerFont = PopdeemFont(PDThemeFontPrimary, 17);
	
	_messageFontColor = PopdeemColor(PDThemeColorPrimaryFont);
	_messageFont = PopdeemFont(PDThemeFontPrimary, 14);
	
	_buttonColor = [PopdeemColor(PDThemeColorPrimaryApp) lighterColor];
	_buttonFontColorNormal = PopdeemColor(PDThemeColorPrimaryInverse);
	_buttonFontColorSelected = PopdeemColor(PDThemeColorSecondaryFont);
	_buttonFont = PopdeemFont(PDThemeFontBold, 17);
	_buttonBorderColor = PopdeemColor(PDThemeColorPrimaryApp);
	
	_headerText = translationForKey(@"popdeem.instagram.verify.headerText",@"Verify");
	[self setupForMustVerify];
}

- (void) setViewModelState:(PDInstagramVerifyViewState)state {
	self.state = state;
	switch (state) {
			case PDInstagramVerifyViewStateMustVerify:
			[self setupForMustVerify];
			break;
			case PDInstagramVerifyViewStateVerifySuccess:
			[self setupForVerifySuccess];
			break;
			case PDInstagramVerifyViewStateVerifyFailure:
			[self setupForVerifyFailure];
			break;
  default:
			[self setupForMustVerify];
			break;
	}
	[_viewController updateForViewModelState];
}

- (void) setupForMustVerify {
	_headerText = translationForKey(@"popdeem.instagram.verify.mustVerify.headerText", @"Verify Post");
	_messageText = translationForKey(@"popdeem.instagram.verify.mustVerify.messageText", @"Have you completed your post on Instagram? If yes, tap 'Verify' below, so we can check it out! If not, tap anywhere outside this card, and you will be brought back to the claim screen, where you can make the post again.\n");
	_buttonText = translationForKey(@"popdeem.instagram.verify.mustVerify.buttonText", @"Verify Now");
}

- (void) setupForVerifySuccess {
	_headerText = translationForKey(@"popdeem.instagram.verify.verifySuccess.headerText", @"Verify Succeeded!");
	_messageText = translationForKey(@"popdeem.instagram.verify.verifySuccess.messageText", @"We have found your post! You can go to the Wallet now to see your reward.\n");
	_buttonText = translationForKey(@"popdeem.instagram.verify.verifySuccess.buttonText", @"Go");
}

- (void) setupForVerifyFailure {
	_headerText = translationForKey(@"popdeem.instagram.verify.verifyFailure.headerText", @"Verify Failure");
	_messageText = [NSString stringWithFormat:translationForKey(@"popdeem.instagram.verify.verifyFailure.messageText", @"We could not find your post. Please go to Instagram and ensure that your post includes the hashtag %@ and try verify again. You can also verify this post at a later date in the Wallet."),_viewController.reward.forcedTag];
	_buttonText = translationForKey(@"popdeem.instagram.verify.verifySuccess.buttonText", @"Go");
}

@end
