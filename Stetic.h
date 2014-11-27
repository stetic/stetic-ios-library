//
//  Stetic iOS
//  iOS tracking library for Stetic Mobile Analytics
//
//  Copyright (c) 2014 Stetic (http://www.stetic.com/)
//

#import "SteticVisitor.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define trackingEndpoint @"https://www.stetic.com/track/event"


@interface Stetic : NSObject


@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString* sessionId;
@property (nonatomic, retain) SteticVisitor* visitor;

+ (Stetic*)sharedInstance;

- (void)resetSession;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *deviceModel;
- (void)track:(NSString *)event;
- (void)track:(NSString *)event properties:(NSDictionary *)properties;

@end
