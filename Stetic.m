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

@interface Stetic()

@property (nonatomic, strong) NSMutableDictionary *userProperties;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation Stetic

@synthesize token, uuid, userProperties, timer;

static Stetic* gSingleton = nil;

+ (Stetic*)sharedInstance
{
    if (nil == gSingleton)
    {
        gSingleton = [[Stetic alloc] init];
    }

    return gSingleton;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    if (self)
    {
        NSString* unique_user_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"stetic_uuid"];
        if (nil == unique_user_id || NULL == unique_user_id || [unique_user_id length] == 0)
        {
            unique_user_id = [self getUuid];
            [[NSUserDefaults standardUserDefaults] setObject:unique_user_id forKey:@"stetic_uuid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.uuid = unique_user_id;
        self.userProperties = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc
{
    self.token = nil;
    self.uuid = nil;
    self.userProperties = nil;
    
    [timer invalidate];
    
    [super dealloc];
}

- (NSString*) getSessionId
{
    NSString *chars = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *sessionId = [NSMutableString stringWithCapacity: 32];
    
    for (int i=0; i<32; i++) {
        [sessionId appendFormat: @"%C", [chars characterAtIndex: arc4random() % [chars length]]];
    }
    return sessionId;
    
}

- (NSString*)getUuid
{
    int counter = rand() & 0xffffff;
    NSUUID *udid = [[UIDevice currentDevice] identifierForVendor];
    unsigned char data[16];
    
    [udid getUUIDBytes:data];
    int d = 0xffffff;
    for(int i = 0; i < 16; i += 3) {
        int x = data[i%16] + (data[(i+1) % 16] << 8) + (data[(i + 2) % 16] << 16);
        d = (d ^ x) & 0xffffff;
    }
    int mid = d;
    
    UInt16 pid = getpid();
    UInt8 pidHigh = pid >> 8;
    UInt8 pidLow = pid & 0xff;
    
    counter++;
    if (counter >= 0xffffff) {
        counter = 0;
    }
    
    typedef struct {
        UInt32 m[3];
    } ObjectID;
    
    ObjectID _id;
    _id.m[2] = (UInt32)time(0);
    _id.m[1] = pidLow + (mid << 8);
    _id.m[0] = counter + (pidHigh << 24);
    
    return [NSString stringWithFormat:@"%08x%08x%08x", (unsigned int)_id.m[2], (unsigned int)_id.m[1], (unsigned int)_id.m[0]];
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
        sessionId = [self getSessionId];
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
                                   self.token, self.sessionId, self.uuid, event, (long)((NSInteger)size.width), (long)((NSInteger)size.height), deviceModel];

    // Add identify properties
	NSDictionary* prop = self.userProperties;
	for (NSString* k in prop)
    {
        [parameters appendFormat:@"&ucm[%@]=%@", k, prop[k]];
    }
    
    // Add Event Properties
    for (NSString* k in event_properties)
    {
        [parameters appendFormat:@"&ctm[%@]=%@", k, event_properties[k]];
    }

    int timestamp = [[NSDate date] timeIntervalSince1970];
    [parameters appendFormat:@"&r=%d", timestamp];
    
    NSString *url = [trackingEndpoint stringByAppendingString:parameters];
    
    //NSLog(@"Stetic tracking request: %@", url);

    // Tracking request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringCacheData
                                        timeoutInterval:60.0];


    [NSURLConnection connectionWithRequest:request delegate:self];
    
    // (Re)start ping timer
    [timer invalidate];
    timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(pinger) userInfo:nil repeats:YES];
}

- (void)identify:(NSString *)key value:(NSString *)value
{
    if (key && value)
    {
        [self.userProperties setObject: [value copy] forKey:key];
    }
}

- (void)identify:(NSDictionary *)properties
{
    if (properties)
    {
        [self.userProperties addEntriesFromDictionary:properties];
    }
}

-(void)pinger
{
    // Only ping when app is active
    if( [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive )
    {
        return;
    }

    NSMutableString* parameters = [NSMutableString stringWithFormat:@"?id=%@&s=%@&u=%@&lib=ios",
                                   self.token, self.sessionId, self.uuid];

    // Add identify properties
    NSDictionary* prop = self.userProperties;
    for (NSString* k in prop)
    {
        [parameters appendFormat:@"&ctm[%@]=%@", k, prop[k]];
    }
    
    int timestamp = [[NSDate date] timeIntervalSince1970];
    [parameters appendFormat:@"&r=%d", timestamp];
    
    NSString *url = [pingEndpoint stringByAppendingString:parameters];
    
    //NSLog(@"Stetic PING request: %@", url);
    
    // Ping request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];


    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

@end
