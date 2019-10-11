//
//  PDUINoActionRewardView.m
//  PopdeemSDK
//
//  Created by Popdeem on 27/11/2018.
//

#import "PDUINoActionRewardView.h"
#import "PDUIHomeViewController.h"
#import "PDUtils.h"
#import "PDTheme.h"
#import "PDReward.h"

@implementation PDUINoActionRewardView

- (PDUINoActionRewardView*) initForView:(UIView *)parent reward:(PDReward *)reward homeVC:(PDUIHomeViewController *)homeVC
                           {
    if (self = [super init]) {

        self.homeViewController = homeVC;
        self.parent = parent;
        
        // self.view is a backing view which has 0.5 opacity and will fill the parent
        self.frame = CGRectMake(0,0,parent.frame.size.width,parent.frame.size.height);
        
        float width = parent.frame.size.width;
        float height = parent.frame.size.height;
        
        _backingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _backingView.alpha = 0.8;
        [_backingView setBackgroundColor:UIColor.lightGrayColor];
 
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width/1.2, height/1.5)];
        _contentView.center = self.backingView.center;
        _contentView.layer.cornerRadius = 5.0;
        [_contentView setBackgroundColor:UIColor.whiteColor];

        float framecenter = _contentView.center.x;
        float bottom = _contentView.frame.size.height;
        
        UIImage *rewardImage;
        if(reward.coverImage == nil) {
            rewardImage = PopdeemImage(@"pduikit_starG");
        } else {
            rewardImage = reward.coverImage;
        }
        
        // Center Image View
        CGRect rewardImageRect = CGRectMake(framecenter -60, framecenter -150, 60, 60);
        _rewardImageView = [[UIImageView alloc] initWithFrame:rewardImageRect];
        _rewardImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rewardImageView.layer.masksToBounds = YES;
        [_rewardImageView setImage:rewardImage];
        
        CGRect titleRect = CGRectMake(5, framecenter -50, _contentView.frame.size.width -10, 60);
        _titleLabel = [[UILabel alloc] initWithFrame:titleRect];
        [self.titleLabel setText:reward.rewardDescription];
        [_titleLabel setNumberOfLines:3];
        [_titleLabel setFont:PopdeemFont(PDThemeFontBold, 16)];
        [_titleLabel setTextColor:[UIColor colorWithRed:0.166 green:0.166 blue:0.166 alpha:1.000]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        CGRect descriptionRect = CGRectMake(5, framecenter + 20, _contentView.frame.size.width -10, 120);
        _descriptionLabel = [[UILabel alloc] initWithFrame:descriptionRect];
        [self.descriptionLabel setText:reward.rewardRules];
        [_descriptionLabel setNumberOfLines:7];
        [_descriptionLabel setFont:PopdeemFont(PDThemeFontPrimary, 16)];
        [_descriptionLabel setTextColor:[UIColor colorWithRed:0.274 green:0.274 blue:0.274 alpha:1.000]];
        [_descriptionLabel setTextAlignment:NSTextAlignmentCenter];

        CGRect cancelButtonRect = CGRectMake(0, bottom-50, _contentView.frame.size.width/2, 50);
        _cancelButton = [[UIButton alloc] initWithFrame:cancelButtonRect];
        
        NSString *cancelButtonTitle = translationForKey(@"popdeem.noaction.cancelText", @"Cancel");
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        
        [self.cancelButton setTitleColor:PopdeemColor(PDThemeColorButtons) forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor: [UIColor whiteColor]];
        [_cancelButton setFont:PopdeemFont(PDThemeFontPrimary, 18)];
        [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = 5.0f;
        
        CGRect claimButtonRect = CGRectMake(_contentView.frame.size.width/2, bottom-50, _contentView.frame.size.width/2, 50);
        _claimButton = [[UIButton alloc] initWithFrame:claimButtonRect];
       
        NSString *claimButtonTitle = translationForKey(@"popdeem.noaction.claimText", @"Claim");
        [self.claimButton setTitle:claimButtonTitle forState:UIControlStateNormal];
        
        [self.claimButton setTitleColor:PopdeemColor(PDThemeColorButtons) forState:UIControlStateNormal];
        [_claimButton setBackgroundColor: [UIColor whiteColor]];
        [_claimButton setFont:PopdeemFont(PDThemeFontBold, 18)];
        [_claimButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        _claimButton.layer.masksToBounds = YES;
        _claimButton.layer.cornerRadius = 5.0f;

        PDReward *rewardToPass = reward;
        [_claimButton.layer setValue:rewardToPass forKey:@"rewardKey"];
    
        //IBAction for Dismiss & Claim No Action
        [_cancelButton addTarget:self action:@selector(dismissAction)forControlEvents:UIControlEventTouchUpInside];
        [_claimButton addTarget:self action:@selector(claimButtonClicked:)forControlEvents:UIControlEventTouchUpInside];
    
    
        _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, bottom - 50 + 0.2f, _contentView.frame.size.width, 1)];
        _topBorder.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
        [_contentView addSubview:_topBorder];
        
        _middleBorder = [[UIView alloc] initWithFrame:CGRectMake(_cancelButton.frame.size.width, bottom - 50 + 0.2f, 1, _claimButton.frame.size.height)];
        _middleBorder.backgroundColor = [UIColor colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
        [_contentView addSubview:_topBorder];

    }
    return self;
}

- (void) didMoveToSuperview {
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_descriptionLabel];
    [self.contentView addSubview:_claimButton];
    [self.contentView addSubview:_cancelButton];
    [self.contentView addSubview:_rewardImageView];
    [self.contentView addSubview:_topBorder];
    [self.contentView addSubview:_middleBorder];

    [self addSubview:_backingView];
    [self addSubview:_contentView];
}

-(void)claimButtonClicked:(UIButton*)sender{
    [self dismissAction];
    PDReward *rewardThatWasPassed = (PDReward *)[sender.layer valueForKey:@"rewardKey"];
    [_homeViewController claimNoActionReward:rewardThatWasPassed];
}

- (void) dismissAction {
    [self hideAnimated:YES];
}

- (void) hideAnimated:(BOOL)animated {
    if (animated) {
        [self.layer removeAllAnimations];
        CATransition *loaderOut =[CATransition animation];
        [loaderOut setDuration:0.5];
        [loaderOut setType:kCATransitionReveal];
        [loaderOut setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[self layer] addAnimation:loaderOut forKey:kCATransitionReveal];
    }
    [self removeFromSuperview];
}

- (void) showAnimated:(BOOL)animated {
    if (animated) {
        CATransition *loaderIn =[CATransition animation];
        [loaderIn setDuration:0.5];
        [loaderIn setType:kCATransitionReveal];
        [loaderIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [[self layer] addAnimation:loaderIn forKey:kCATransitionReveal];
    }
    [self setHidden:NO];
    [_parent addSubview:self];
    [_parent bringSubviewToFront:self];
}

@end
