//
//  PDCustomerAPIService.h
//  Bolts
//
//  Created by Niall Quinn on 14/02/2018.
//

#import "PDAPIService.h"

@interface PDCustomerAPIService : PDAPIService

- (void) getCustomerWithCompletion:(void (^)(NSError *error))completion;

@end
