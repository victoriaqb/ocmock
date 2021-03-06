/*
 *  Copyright (c) 2009-2016 Erik Doernenburg and contributors
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

#import "NSMethodSignature+OCMAdditions.h"
#import "OCMReturnValueProvider.h"
#import "OCMFunctions.h"

@interface OCMReturnValueProvider()

@property (nonatomic, assign) BOOL valueRetained;

@end


@implementation OCMReturnValueProvider

- (instancetype)initWithValue:(id)aValue
{
    if ((self = [super init]))
    {
        returnValue = [aValue retain];
        _valueRetained = YES;
    }
    
    return self;
}

- (instancetype)initWithValue:(id)aValue shouldRetain:(BOOL)shouldRetain
{
    if ((self = [super init]))
    {
        if (shouldRetain)
        {
            returnValue = [aValue retain];
        }
        else
        {
            returnValue = aValue;
            
        }
        _valueRetained = shouldRetain;
    }
	
	return self;
}

- (void)dealloc
{
    if (_valueRetained)
    {
        [returnValue release];
    }
    [super dealloc];
}

- (void)handleInvocation:(NSInvocation *)anInvocation
{
    if(!OCMIsObjectType([[anInvocation methodSignature] methodReturnType]))
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Expected invocation with object return type. Did you mean to use andReturnValue: instead?" userInfo:nil];
    }
    NSString *sel = NSStringFromSelector([anInvocation selector]);
    if([sel hasPrefix:@"alloc"] || [sel hasPrefix:@"new"] || [sel hasPrefix:@"copy"] || [sel hasPrefix:@"mutableCopy"])
    {
        // methods that "create" an object return it with an extra retain count
        [returnValue retain];
    }
	[anInvocation setReturnValue:&returnValue];
}

@end
