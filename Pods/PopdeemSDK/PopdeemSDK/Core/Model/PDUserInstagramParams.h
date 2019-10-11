//
//  PDUserInstagramParams.h
//  PopdeemSDK
//
//  Created by Niall Quinn on 20/06/2016.
//  Copyright © 2016 Popdeem. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "PDScores.h"

@interface PDUserInstagramParams : JSONModel

@property (nonatomic) NSInteger socialAccountId;
@property (nonatomic, retain) NSString<Optional> *instagramId;
@property (nonatomic, retain) NSString<Optional> *screenName;
@property (nonatomic) BOOL isTester;
@property (nonatomic, retain) NSString<Optional> *accessToken;
@property (nonatomic, retain) NSString<Optional> *accessSecret;
@property (nonatomic, retain) NSString<Optional> *profilePictureUrl;
@property (nonatomic, retain) PDScores<Optional> *score;
@property (nonatomic, retain) NSArray<Optional> *favBrands;

- (id) initWithJSON:(NSString*)json;
- (id) initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err;

@end
