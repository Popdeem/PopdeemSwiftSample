//
//  PDUIFBLoginWithWritePermsViewModel.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 26/07/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PDFacebookLoginType) {
	PDFacebookLoginTypeRead,
	PDFacebookLoginTypePublish
};

@interface PDUIFBLoginWithWritePermsViewModel : NSObject

@property (nonatomic, retain) NSString *labelText;
@property (nonatomic, retain) UIColor *labelColor;
@property (nonatomic, retain) UIFont *labelFont;
@property (nonatomic, retain) UIImage *logoImage;
@property (nonatomic, retain) NSString *buttonText;
@property (nonatomic, retain) UIColor *buttonColor;
@property (nonatomic, retain) UIColor *buttonTextColor;
@property (nonatomic, retain) UIFont *buttonLabelFont;
@property (nonatomic) PDFacebookLoginType loginType;

- (instancetype) initForParent:(UIViewController*)parent loginType:(PDFacebookLoginType)loginType;
- (void) setup;
@end
