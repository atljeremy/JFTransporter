![JFTransporter](http://imageshack.com/a/img538/2803/BgNRqc.png)
=============

An Objective-C Networking abstraction to help make setting up a service layer in an iOS app much quicker and easier 

### Build/Tests Status: ![build status](https://travis-ci.org/atljeremy/JFTransporter.svg?branch=master)

Installation:
-------------

### CocoaPods

```ruby
pod "JFTransporter", "~> 0.0.1"
```

### Static Library

Instructions on using static libraries in your iOS applications: https://developer.apple.com/library/ios/technotes/iOSStaticLibraries/iOSStaticLibraries.pdf

How To Use It:
-------------

### Note
There is a complete example project in the /Example/JFTransporterExample directory of this repository. I highly encourage you to clone and open this example project which shows `JFTransporter` in action.

### Basic Example

#### Step One

Create your model classes and make sure they conform to the `JFTransportable` Protocol.

```objective-c
#import <JFTransporter/JFTransportable.h>

@interface Forecast : NSObject <JFTransportable>
  
// Forecast model properties
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, strong) Current* current;
@property (nonatomic, strong) Daily* daily;

// JFTransportable Required Properties
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

- (id)initWithWithLatitude:(double)latitude andLongitude:(double)longitude NS_DESIGNATED_INITIALIZER;

@end
  
```

#### Step Two

In your model's implementation, implement any of the @optional `JFTransportable` methods that are appropriate for your model. For example, if your model will only be cretaed from a GET request to an API you'll only need to implement the `- (NSURL*)GETURL` method. However, if your model will also need to be POSTed, DELETEed, etc., you'll also need to implement the corresponding `JFTransportable` methods.

In each method implementation you will need to return the full and complete URL that will be used for the corresponding HTTP request. See the example below.

```objective-c
#import "Forecast.h"

static NSString* const kForecastAPIURLString = @"https://api.forecast.io/forecast/018524e6ba1870dc2c7356d98d9b9b40";

@implementation Forecast

...

- (NSURL*)GETURL
{
    NSURL* URL = [NSURL URLWithString:kForecastAPIURLString];
    URL = [URL URLByAppendingPathComponent:[NSString stringWithFormat:@"%f,%f", self.latitude, self.longitude]];
    return URL;
}

...

```

#### Step Three

Implement the `- (NSDictionary*)responseToObjectModelMapping` method from the `JFTransportable` Protocol. This is used to tell `JFTransporter` how to map the API's response object KVP's to your model.

There are two helper macros that you should use to tell `JFTransporter` how to map response sub dictionarys/arrays to specific model classes/collections. These macros are `JFObjectModelMappingObjectDictionary(_CLASS_, _PROPERTY_)` and `JFObjectModelMappingObjectArray(_CLASS_, _PROPERTY_)`. Both take a Class as the first argument and an NSString representing the model's property to map the Class instance to. See the examples below.

```objective-c
#import "Forecast.h"

@implementation Forecast

...

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"currently": JFObjectModelMappingObjectDictionary([Current class], @"current"),
             @"daily": JFObjectModelMappingObjectDictionary([Daily class], @"daily")};
}

...

```

Here is an exmaple of the `Daily` model which is using the `JFObjectModelMappingObjectArray` macro.

```objective-c
#import <JFTransporter/JFTransportable.h>

@interface Daily : NSObject <JFTransportable>

@property (nonatomic, strong) NSArray/*<Day>*/* days;

// JFTransportable Required Properties
@property (nonatomic, strong) NSURL* URL;
@property (nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, strong) NSData* HTTPBody;
@property (nonatomic, strong) NSDictionary* HTTPHeaderFields;

@end
```

```objective-c
#import "Daily.h"
#import "Day.h"

@implementation Daily

- (NSDictionary*)responseToObjectModelMapping
{
    return @{@"data": JFObjectModelMappingObjectArray([Day class], @"days")};
}

@end
```

#### Step Four (Final Step)

Create an instance of your model and pass it into the appropriate `JFTransporter` request method. `JSTransporter` will then create and execute an HTTP request based on what your model tells it via the `JFTransportable` Protocol implementations. It will then map the response using your object mapping NSDictionaries implemented in each of your models. The result is that your newely created model will have all of it's properties automagically set appropriately and returned to you in the completion block. See example below.

```objective-c
@interface ViewController ()
@property (nonatomic, strong) Forecast* forecast;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Forecast* forecast = [[Forecast alloc] initWithWithLatitude:33.7550 andLongitude:-84.3900];
    [[JFTransporter defaultTransporter] GETTransportable:forecast withCompletionHandler:^(id<JFTransportable> transportable, NSError *error) {
        if (transportable && !error) {
            self.forecast = transportable;
            [self.tableView reloadData];
        }
    }];
}

// Other code to fill tableView with forecast data goes here

```

License
-------
Copyright (c) 2012 Jeremy Fox ([jeremyfox.me](http://www.jeremyfox.me)). All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
