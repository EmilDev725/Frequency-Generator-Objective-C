//
//  Queue.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject

@property (readonly) NSUInteger count;

-(void) enqueueObject: (NSObject*) object;
-(id) dequeueObject;

@end
