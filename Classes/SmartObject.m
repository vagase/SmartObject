//
//  SmartObject.m
//  Test31
//
//  Created by Near on 10-8-15.
//  Copyright 2010 Near. All rights reserved.
//

#import "SmartObject.h"
#import <Foundation/NSObjCRuntime.h> 
#import <objc/runtime.h>

#pragma mark -
#pragma mark Global Instance
static NSArray *_gs_properties = nil;

#pragma mark -
#pragma mark c methods declare
id getMethod(SmartObject *self, SEL _cmd);
void setMethod(SmartObject *self, SEL _cmd, id object);

#pragma mark -

@interface SmartObject(PrivateMethods)

- (NSMutableDictionary *)_variableDict;

// Whether |aSEL| is a getter selector.
+ (BOOL)_getterSelector:(SEL)aSEL;
// Whether |aSEL| is a setter selector.
+ (BOOL)_setterSelector:(SEL)aSEL;

@end
@implementation SmartObject(PrivateMethods)

- (NSMutableDictionary *)_variableDict{
  if (!_rawData) {
    _rawData = [[NSMutableDictionary alloc] initWithCapacity:128];
  }
  return (NSMutableDictionary *)_rawData;
}

+ (BOOL)_getterSelector:(SEL)aSEL{
  BOOL result = NO;
  
  NSString *selectorName = NSStringFromSelector(aSEL);
  if (![selectorName hasPrefix:@"set"] && ![selectorName hasSuffix:@":"]) {
    NSString *propertyName = selectorName;
    if ([selectorName hasPrefix:@"is"]) {
      propertyName = [selectorName substringFromIndex:2];
    }
    propertyName = [propertyName lowercaseString];
    result = [_gs_properties containsObject:propertyName];
  }
  
  
  return result;
}
+ (BOOL)_setterSelector:(SEL)aSEL{
  BOOL result = NO;
  
  NSString *selectorName = NSStringFromSelector(aSEL);
  if ([selectorName hasPrefix:@"set"] && [selectorName hasSuffix:@":"]) {
    NSRange subStringRange;
    subStringRange.location = 3;
    subStringRange.length = selectorName.length - 4;
    NSString *propertyName = [selectorName substringWithRange:subStringRange];
    propertyName = [propertyName lowercaseString];
    result = [_gs_properties containsObject:propertyName];
  }
  
  return result;
}

@end

#pragma mark -

@implementation SmartObject

+ (void)initialize{
  
  unsigned int propertyCount = 0;
  objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
  if (!propertyCount)return;
  
  NSMutableArray *tempProperties = [[NSMutableArray alloc] initWithCapacity:propertyCount];
  for (int index = 0; index < propertyCount; ++index) {
    NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertyList[index])];
    [tempProperties addObject:propertyName];
  }
  free(propertyList);
  
  _gs_properties = [[NSArray alloc] initWithArray:tempProperties];
  [tempProperties release];
}



+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
  
  BOOL result = NO;
  
  if ([self _getterSelector:aSEL]) {
    result = class_addMethod([self class], aSEL, (IMP) getMethod, "@@:");
  }
  else if([self _setterSelector:aSEL]){
    result = class_addMethod([self class], aSEL, (IMP) setMethod, "v@:@");
  }
  
  if (!result) {
    result = [super resolveInstanceMethod:aSEL];
  }
  
  return result;
}

@end

#pragma mark -
#pragma mark c methods implementation

id getMethod(SmartObject *self, SEL _cmd){
  
  id result = nil;
  
  if ([[self class] _getterSelector:_cmd]) {
    result = [[self _variableDict] objectForKey:NSStringFromSelector(_cmd)]; 
  }
  
  return result;
}

void setMethod(SmartObject *self, SEL _cmd, id object){
  if ([[self class] _setterSelector:_cmd]) {
    //Extract varaible name from setter's name
    NSString *setterName = NSStringFromSelector(_cmd);
    NSRange range;
    range.location = 3;
    range.length = setterName.length - 4;
    NSString *varaibleName = [[setterName substringWithRange:range] lowercaseString];
    [[self _variableDict] setValue:object forKey:varaibleName];
  }
}
