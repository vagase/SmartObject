//
//  SmartObjectAppDelegate.h
//  Test31
//
//  Created by Near on 10-8-15.
//  Copyright Near 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestClass;

@interface SmartObjectAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  
  TestClass *_myObject;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;

- (IBAction)print:(id)sender;

@end

