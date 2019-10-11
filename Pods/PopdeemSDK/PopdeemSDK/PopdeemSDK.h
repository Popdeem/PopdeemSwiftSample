//
//
//
//                        /\
//      \`               /##\               ´/
//       \   `          /####\          ´   /
//        \     `      /######\      ´     /
//         \       `  /########\  ´       /
//          \        /##########\        /
//           \      /############\      /
//            \    /##############\    /
//             \  /################\  /
//              \/##################\/
// _____   ____  _____  _____  ______ ______ __  __
//|  __ \ / __ \|  __ \|  __ \|  ____|  ____|  \/  |
//| |__) | |  | | |__) | |  | | |__  | |__  |      |
//|  ___/| |  | |  ___/| |  | |  __| |  __| | |\/| |
//| |    | |__| | |    | |__| | |____| |____| |  | |
//|_|     \____/|_|    |_____/|______|______|_|  |_|
//
//
//
//  PopdeemSDK.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 27/08/2015.
//  Copyright (c) 2015 Popdeem. All rights reserved.
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
#import "UIKit/UIKit.h"
#import "PDLogger.h"
#import "PDAbraClient.h"
#import "PDConstants.h"
#import "PDUtils.h"
#import "PDTheme.h"
#import "PDBrand.h"
#import "PDHomeSegueDelegate.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDEnv) {
  PDEnvProduction = 0,
  PDEnvStaging
};

@interface PopdeemSDK : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic) BOOL debug;
@property (nonatomic) PDEnv env;
@property (nonatomic) id<PDHomeSegueDelegate> segueDelegate;
@property (nonatomic, retain) CLLocationManager *locationManager;

+ (id) sharedInstance;
- (NSString*) apiURL;
+ (void) setEnv:(PDEnv)env;

+ (void) setDebug:(BOOL)debug;
+ (BOOL) debugMode;

+ (void) withAPIKey:(NSString*)apiKey;
+ (void) withAPIKey:(NSString*)apiKey env:(PDEnv)env;
+ (void) testingWithAPIKey:(NSString*)apiKey;
+ (void) startupBrands;
+ (void) setTwitterOAuthToken:(NSString*)token verifier:(NSString*)verifier;

+ (void) enableSocialLoginWithNumberOfPrompts:(NSInteger) noOfPrompts;

+ (void) setUpThemeFile:(NSString*)themeName;

+ (void) presentRewardFlow;
+ (void) directToSocialHome;
+ (void) presentRewardsForBrand:(PDBrand*)b inNavigationController:(UINavigationController*)navController;
+ (void) presentHomeFlowInNavigationController:(UINavigationController*)navController;
+ (void) presentBrandFlowInNavigationController:(UINavigationController*)navController;
+ (void) pushRewardsToNavigationController:(UINavigationController*)navController animated:(BOOL)animated;

+ (void) registerForPushNotificationsApplication:(UIApplication *)application;
+ (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

+ (void) handleRemoteNotification:(NSDictionary*)userInfo;

+ (BOOL) canOpenUrl:(NSURL*)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(nullable id)annotation;

+ (BOOL) application:(UIApplication*)application canOpenUrl:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(nullable id)annotation;



+ (BOOL) application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(nullable id)annotation;


+ (BOOL) application:(UIApplication*)application canOpenUrl:(NSURL *)url options:(NSDictionary*)options;

+ (BOOL) application:(UIApplication*)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;
//+ (BOOL) application:(UIApplication*)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options;

+ (void) logMoment:(NSString*)momentString;

+ (void) setThirdPartyUserToken:(NSString*)userToken;

+ (void) logout;

- (void) nonSocialRegister;

+ (void) setFacebookCredentials:(NSString*)facebookAccessToken facebookId:(NSString*)facebookId;

+ (NSString*) instagramClientId;
+ (NSString*) instagramClientSecret;
+ (NSString*) instagramCallback;
@end
NS_ASSUME_NONNULL_END
