# Stetic iOS Tracking Library

With this iOS Tracking Library you can track users on your iPhone or iPad application.
 
## Documentation

1. Add the files from this repository to your iOS project. If you're using XCode, just drag and drop the files to your XCode Project Workspace.
2. Import the Stetic Header file in your Application Delegate (AppDelegate.m):

	```objective-c
	#import "Stetic.h"
	```

3. Initialize the library with the startSession method in your Application Delegate inside didFinishLaunchingWithOptions:

	```objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

      [[Stetic sharedInstance] startSession:@"YOUR_SITE_TOKEN"];
    }
	```

	Replace YOUR_SITE_TOKEN with your site token.

4. Start tracking events in your app. 

	The best way is to track an event in every view inside viewDidLoad.
    Hint: Use the appview event here to use our pre-configured events.

	```objective-c
    - (void)viewDidLoad
    {
        [super viewDidLoad];

        [[Stetic sharedInstance] track:@"appview" properties:@{@"view": @"MyView"}];
    }
	```

	You can add more properties for better segmentation:

	```objective-c
	[[Stetic sharedInstance] track:@"appview" properties:@{@"view": @"MyView", @"property": @"value"}];
	```

    Track any event you like:


	```objective-c
	[[Stetic sharedInstance] track:@"video play" properties:@{@"title": @"My awesome video", @"author": @"Jimmy Schmidt"}];
	```

5. Identify users. Call the identify method BEFORE the track method:

	```objective-c
	[[Stetic sharedInstance] identify:@"id" value: user.id]; // Key value 
	[[Stetic sharedInstance] identify:@{@"id": user.id, @"email": user.email, @"name": user.name}]; // NSDictionary
	
	[[Stetic sharedInstance] track:@"appview" properties:@{@"view": @"MyView"}];
	```
