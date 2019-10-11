//
//  PDModalTransitionHandler.h
//  PopdeemSDK
//
//  Created by John Doran Home on 26/11/2015.
//  Copyright © 2015 Popdeem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PDUIModalTransitionHandler : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign, getter = isTapDismissEnabled) BOOL tapDismissEnabled;
@property (nonatomic, assign) NSTimeInterval animationSpeed;
@property (nonatomic, strong) UIColor *backgroundShadeColor;
@property (nonatomic, assign) CGAffineTransform scaleTransform;
@property (nonatomic, assign) CGFloat springDamping;
@property (nonatomic, assign) CGFloat springVelocity;
@property (nonatomic, assign) CGFloat backgroundShadeAlpha;

@end
