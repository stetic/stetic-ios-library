# Stetic iOS Tracking Library

With this Library you can add Mobile Analytics from Stetic to your iOS app.
 
## Documentation

1. Add the files from this repository to your iOS project.
2. Import the Stetic Header file:

```objective-c
#import "Stetic.h"
```

3. Initialize the library with your site token when the app loads. Typically in `AppDelegate.m` `didFinishLaunchingWithOptions`:

```objective-c
[Stetic sharedInstance].token = @"XXXX-XXXXXXXXXXXX-XXXXXXXX";
```

Replace XXXX-XXXXXXXXXXXX-XXXXXXXX with your site token.

4. Start tracking events in your app. 

To track an event when your app opens, add the following line after the line specified above:

```objective-c
[[Stetic sharedInstance] track:@"appopen"];
```

Track a view:

```objective-c
[[Stetic sharedInstance] track:@"appview" properties:@{@"view": @"Dashboard"}];
```

You can add any properties you like:

```objective-c
[[Stetic sharedInstance] track:@"appview" properties:@{@"view": @"Dashboard", @"property": @"value"}];
```

5. Identify users:


```objective-c
[[Stetic sharedInstance].visitor addProperty:@"id" value: user.id]; // With the user id 
[[Stetic sharedInstance].visitor addProperty:@"email" value: user.email]; // With the user email
```
