//
//  PDUIInstagramShareViewModel.m
//  PopdeemSDK
//
//  Created by Niall Quinn on 04/07/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import "PDUIInstagramShareViewModel.h"
#import "PDTheme.h"
#import "PDUtils.h"
#import "PDUIInstagramShareViewController.h"

@implementation PDUIInstagramShareViewModel

- (instancetype) initWithController:(PDUIInstagramShareViewController*)controller {
	if (self = [super init]) {
        self.controller = controller;
		[self setup];
		return self;
	}
	return nil;
}

- (void) setup {
    
    if (_controller.parent.reward.forcedTag) {
        self.viewOneLabelOneText = [NSString stringWithFormat:translationForKey(@"popdeem.instagram.share.stepOne.label1", @"%@ has been copied to the clipboard."), _controller.parent.reward.forcedTag];
        self.viewOneLabelTwoText = [NSString stringWithFormat:translationForKey(@"popdeem.instagram.share.stepOne.label2", @"You will now be directed to Instagram where you can paste %@. Tap and hold to paste."), _controller.parent.reward.forcedTag];
    } else {
        self.viewOneLabelOneText = translationForKey(@"popdeem.instagram.share.stepOne.label1", @"The hashtag has been copied to the clipboard.");
        self.viewOneLabelTwoText = translationForKey(@"popdeem.instagram.share.stepOne.label2", @"You will now be directed to Instagram where you can paste the hashtag. Tap and hold to paste.");
    }

	self.viewOneActionButtonText = translationForKey(@"popdeem.instagram.share.stepOne.buttonText", @"Next");
	
	self.viewTwoLabelOneText = translationForKey(@"popdeem.instagram.share.stepTwo.label1", @"Make sure you are logged into the correct account on Instagram.");
	self.viewTwoLabelTwoText = translationForKey(@"popdeem.instagram.share.stepTwo.label2", @"Your post will publish to whichever account you are currently logged into on the Instagram app.");
	self.viewTwoActionButtonText = translationForKey(@"popdeem.instagram.share.stepTwo.buttonText", @"Next");
  
  self.viewThreeLabelOneText = translationForKey(@"popdeem.instagram.share.stepThree.label1", @"Be sure to select 'Feed' in the Instagram App.");
  self.viewThreeLabelTwoText = translationForKey(@"popdeem.instagram.share.stepThree.label2", @"If you publish to your story, we will be unable to detect your post, and you will be unable to claim your reward.");
  self.viewThreeActionButtonText = translationForKey(@"popdeem.instagram.share.stepThree.buttonText", @"Okay, Gotcha");
	
	self.viewOneLabelOneFont = PopdeemFont(PDThemeFontBold, 14);
	self.viewOneLabelTwoFont = PopdeemFont(PDThemeFontPrimary, 14);
	self.viewTwoLabelOneFont = PopdeemFont(PDThemeFontBold, 14);
	self.viewTwoLabelTwoFont = PopdeemFont(PDThemeFontPrimary, 14);
  self.viewThreeLabelOneFont = PopdeemFont(PDThemeFontBold, 14);
  self.viewThreeLabelTwoFont = PopdeemFont(PDThemeFontPrimary, 14);
	self.viewOneActionButtonFont = PopdeemFont(PDThemeFontBold, 14);
	self.viewTwoActionButtonFont = PopdeemFont(PDThemeFontBold, 14);
  self.viewThreeActionButtonFont = PopdeemFont(PDThemeFontBold, 14);
	
	self.viewOneLabelOneColor = PopdeemColor(PDThemeColorPrimaryFont);
	self.viewOneLabelTwoColor = PopdeemColor(PDThemeColorPrimaryFont);
	self.viewTwoLabelOneColor = PopdeemColor(PDThemeColorPrimaryFont);
	self.viewTwoLabelTwoColor = PopdeemColor(PDThemeColorPrimaryFont);
  self.viewThreeLabelOneColor = PopdeemColor(PDThemeColorPrimaryFont);
  self.viewThreeLabelTwoColor = PopdeemColor(PDThemeColorPrimaryFont);

	self.viewOneActionButtonColor = [UIColor whiteColor];
	self.viewOneActionButtonBorderColor = PopdeemColor(PDThemeColorButtons);
	self.viewTwoActionButtonColor = [UIColor whiteColor];
	self.viewOneActionButtonTextColor= PopdeemColor(PDThemeColorButtons);
	self.viewTwoActionButtonTextColor= PopdeemColor(PDThemeColorButtons);
  self.viewThreeActionButtonColor = PopdeemColor(PDThemeColorButtons);
  self.viewThreeActionButtonTextColor = [UIColor whiteColor];
	
	self.viewOneImage = PopdeemImage(@"pduikit_instagramstep1");
	self.viewTwoImage = PopdeemImage(@"pduikit_instagramstep2");
  self.viewThreeImage = PopdeemImage(@"pduikit_instagramstep3");
}
@end
