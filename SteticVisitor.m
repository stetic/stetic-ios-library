//
//  Stetic iOS
//  iOS tracking library for Stetic Mobile Analytics
//
//  Copyright (c) 2014 Stetic (http://www.stetic.com/)
//

#import "SteticVisitor.h"

@interface SteticVisitor()

@property (atomic, strong) NSMutableDictionary *properties;

@end

@implementation SteticVisitor

@synthesize uuid, properties;


- (id)init
{
    self = [super init];
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
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addProperty:(NSString *)key value:(NSString *)value
{
    if (key && value)
    {
        [self.properties setObject: [value copy] forKey:key];
    }
}

- (void)addProperties:(NSDictionary *)props
{
    if (props)
    {
        [self.properties addEntriesFromDictionary:props];
    }
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


- (void)dealloc
{
	self.uuid = nil;
	[super dealloc];
}

@end
