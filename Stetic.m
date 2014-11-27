//
//  Stetic iOS
//  iOS tracking library for Stetic Mobile Analytics
//
//  Copyright (c) 2014 Stetic (http://www.stetic.com/)
//

#include <arpa/inet.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIDevice.h>

#import "Stetic.h"

@implementation Stetic

@synthesize token, visitor;

static Stetic* gSingleton = nil;

+ (Stetic*)sharedInstance
{
	if (nil == gSingleton)
	{
		gSingleton = [[Stetic alloc] init];
		gSingleton.visitor = [[SteticVisitor alloc] init];
	}
    
	return gSingleton;
}

- (instancetype)init
{
	self = [super init];
	if (!self) return nil;
    
	return self;
}

- (void)dealloc
{
	self.token = nil;
	self.visitor = nil;
    
	[super dealloc];
}

- (void)resetSession
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"stetic_sid"];

}

- (NSString *)deviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
    return results;
}

- (void)track:(NSString *)event
{
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties
{
	// check parameters
	if (nil == self.token)
	{
        NSLog(@"Stetic.token not set.");
        return;
	}
    
	if (nil == self.visitor)
	{
        NSLog(@"Stetic.visitor not set.");
        return;
	}
    
    if (event == nil || [event length] == 0)
    {
        NSLog(@"Stetic: empty event given.");
        return;
    }
    
    properties = [properties copy];
    
    NSString* sessionId = [[NSUserDefaults standardUserDefaults] stringForKey:@"stetic_sid"];
    NSDate* sessionLastAccess = [[NSUserDefaults standardUserDefaults] objectForKey:@"stetic_last"];
    NSDate *sessionExpired = [[[NSDate alloc] initWithTimeIntervalSinceNow:-(3600*2)] autorelease];

    if (nil == sessionId || NULL == sessionId || [sessionId length] == 0 ||
        [sessionLastAccess compare:sessionExpired] == NSOrderedAscending)
    {
        sessionId = [self.visitor getSessionId];
        [[NSUserDefaults standardUserDefaults] setObject:sessionId forKey:@"stetic_sid"];
    }
    
    NSDate *now = [[NSDate alloc] init];
    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"stetic_last"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.sessionId = sessionId;
    
    // Get informations from device
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceModel = [self deviceModel];
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    NSMutableDictionary *event_properties = [NSMutableDictionary dictionary];

    if (properties)
    {
        [event_properties addEntriesFromDictionary:properties];
    }
    
    [event_properties setValue: @"ios" forKey: @"fs_lib"];
    [event_properties setValue: [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"] forKey: @"app"];
    [event_properties setValue: [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"] forKey: @"app_version"];
    [event_properties setValue: [device systemName] forKey: @"os"];
    [event_properties setValue: [device systemVersion] forKey: @"os_version"];
    [event_properties setValue: deviceModel forKey: @"device_model"];
    [event_properties setValue: carrier.carrierName forKey: @"carrier"];
    
    
	NSMutableString* parameters = [NSMutableString stringWithFormat:@"?id=%@&s=%@&u=%@&e=%@&sw=%ld&sh=%ld&os=iOS&lib=ios&device=%@",
                                   self.token, self.sessionId, self.visitor.uuid, event, (long)((NSInteger)size.width), (long)((NSInteger)size.height), deviceModel];

    // Add visitors properties
	NSDictionary* prop = self.visitor.properties;
	for (NSString* k in prop)
    {
        [parameters appendFormat:@"&ucm[%@]=%@", k, prop[k]];
    }
    
	// Add Event Properties
	for (NSString* k in event_properties)
    {
        [parameters appendFormat:@"&ctm[%@]=%@", k, event_properties[k]];
    }
    
    NSString *url = [trackingEndpoint stringByAppendingString:parameters];
    
    //NSLog(@"Stetic tracking request: %@", url);
    
	// Tracking request
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
    
	[NSURLConnection connectionWithRequest:request delegate:self];
    
}

@end
