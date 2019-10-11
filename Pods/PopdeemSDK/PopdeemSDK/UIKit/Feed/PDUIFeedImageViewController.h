//
//  FeedImageViewController.h
//  Popdeem
//
//  Created by Niall Quinn on 06/07/2015.
//  Copyright (c) 2015 Niall Quinn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDRFeedItem.h"

@interface PDUIFeedImageViewController : UIViewController

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PDRFeedItem *item;
@property (nonatomic, assign) UITableViewController *parent;

@end
