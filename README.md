# Stetic iOS Tracking Library

With this iOS Tracking Library you can track users on your iPhone or iPad application.
 
## Documentation

<ol>
<li>Add the files from this repository to your iOS project.</li>
<li>Import the Stetic Header file:

```objective-c
#import "Stetic.h"
```
</li>
<li>Initialize the library with your site token when the app loads. Typically in `AppDelegate.m` `didFinishLaunchingWithOptions`:

```objective-c
[Stetic sharedInstance].token = @"XXXX-XXXXXXXXXXXX-XXXXXXXX";
```

Replace XXXX-XXXXXXXXXXXX-XXXXXXXX with your site token.
</li>
<li>Start tracking events in your app. 

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
</li>
<li>Identify users:


```objective-c
[[Stetic sharedInstance].visitor identify:@"id" value: user.id]; // Key value 
[[Stetic sharedInstance].visitor identify:{@"id" value: user.id, "email" value: user.email, "name" value: user.name}]; // NSDictionary
```
</li>
</ol>