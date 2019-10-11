//
//  PDUIInstagramWebViewController.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 17/06/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDUIModalLoadingView.h"
#import <WebKit/WKWebView.h>
@import WebKit;

@interface PDUIInstagramWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet WKWebView *wkNewWebView;


@property (nonatomic, retain) PDUIModalLoadingView *loadingView;
- (instancetype) initFromNib;
@end
