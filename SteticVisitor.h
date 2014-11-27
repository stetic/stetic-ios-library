//
//  Stetic iOS
//  iOS tracking library for Stetic Mobile Analytics
//
//  Copyright (c) 2014 Stetic (http://www.stetic.com/)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SteticVisitor : NSObject

@property (atomic, readonly, strong) NSMutableDictionary *properties;
@property (nonatomic, copy) NSString *uuid;


- (void)addProperty:(NSString*)key value:(NSString*)value;
- (void)addProperties:(NSDictionary*)properties;
- (NSString*)getSessionId;
- (NSString*)getUuid;

@end
