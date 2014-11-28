//
//  Stetic iOS
//  iOS tracking library for Stetic Mobile Analytics
//
//  Copyright (c) 2014 Stetic (http://www.stetic.com/)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define trackingEndpoint @"https://www.stetic.com/track/event"
#define pingEndpoint @"https://www.stetic.com/de/ping"

@interface Stetic : NSObject


@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString* sessionId;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, readonly, strong) NSMutableDictionary *userProperties;
@property (nonatomic, readonly, strong) NSTimer *timer;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *deviceModel;

+ (Stetic*)sharedInstance;

- (NSString*)getSessionId;
- (NSString*)getUuid;
- (void)resetSession;
- (void)track:(NSString *)event;
- (void)track:(NSString *)event properties:(NSDictionary *)properties;
- (void)identify:(NSString*)key value:(NSString*)value;
- (void)identify:(NSDictionary*)properties;
- (void)pinger;
    
@end
