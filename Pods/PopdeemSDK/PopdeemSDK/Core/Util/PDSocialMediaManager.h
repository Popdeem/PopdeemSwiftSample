//
//  PDSocialMediaManager.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 28/09/2015.
//  Copyright © 2015 Popdeem. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define FACEBOOK_PERMISSIONS @[@"public_profile",@"email",@"user_birthday",@"user_posts"]

@interface PDSocialMediaManager : NSObject <UIAlertViewDelegate>

@property (nonatomic, assign) UIViewController *holderViewController;

+ (id) manager;

- (id) initForViewController:(UIViewController*)viewController;

- (void) loginWithFacebookReadPermissions:(NSArray*)permissions
                      registerWithPopdeem:(BOOL)reg
                                  success:(void (^)(void))success
                                  failure:(void (^)(NSError *err))failure;

- (void) registerWithTwitter:(void (^)(void))success
										 failure:(void (^)(NSError *error))failure;

- (void) logoutFacebook;

- (void) logOut;

- (BOOL) isLoggedIn;

- (BOOL) isLoggedInWithFacebook;

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error completion:(void (^)(NSError *error))completion;

- (void) nextStepForFacebookLoggedInUser:(void (^)(NSError *error))completion;

- (void) checkFacebookTokenIsValid:(void (^)(BOOL valid))completion;

- (void) loginWithTwitter:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure;
- (void) verifyTwitterCredentialsCompletion:(void (^)(BOOL connected, NSError *error))completion;

- (BOOL) isLoggedInWithTwitter;

- (void) userCancelledTwitterLogin;
- (void) twitterLoginSuccessfulToken:(NSString *)token oauthVerifier:(NSString *)verifier;

- (void) isLoggedInWithInstagram:(void (^)(BOOL isLoggedIn))completion;

- (BOOL) isLoggedInWithAnyNetwork;

@end
