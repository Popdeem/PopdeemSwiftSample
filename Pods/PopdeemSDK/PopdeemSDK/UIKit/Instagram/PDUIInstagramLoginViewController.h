//
//  PDUIInstagramLoginViewController.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 16/06/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDUICardViewController.h"
#import "PDTheme.h"
#import "PDUIInstagramWebViewController.h"
#import "NSURL+OAuthAdditions.h"
#import "PDUIInstagramLoginViewModel.h"
#import "InstagramLoginDelegate.h"
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>
@import WebKit;

@class PDUIClaimViewModel;

@interface PDUIInstagramLoginViewController : UIViewController <WKNavigationDelegate, WKUIDelegate> {
	NSMutableData *receivedData;
	BOOL connected;
}
@property (nonatomic, retain) PDUIInstagramLoginViewModel *viewModel;
@property (nonatomic, assign) UIViewController *parent;
@property (nonatomic, assign) id<InstagramLoginDelegate> delegate;
@property (nonatomic, retain) UIView *backingView;
@property (nonatomic, retain) UIView *cardView;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIButton *actionButton;

@property (nonatomic, retain) PDUIInstagramWebViewController *webViewController;

- (instancetype) initForParent:(UIViewController*)parent delegate:(id<InstagramLoginDelegate>)delegate connectMode:(BOOL)connectMode;
- (instancetype) initForParent:(UIViewController*)parent connectMode:(BOOL)connectMode;
- (instancetype) initForParent:(UIViewController*)parent delegate:(id<InstagramLoginDelegate>)delegate connectMode:(BOOL)connectMode directConnect:(BOOL)directConnect;
- (void) connectInstagram;

@end
