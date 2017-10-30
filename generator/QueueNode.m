//
//  QueueNode.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "QueueNode.h"

@implementation QueueNode
{
    @private
    NSObject* _object;
}

-(instancetype) initWithObject:(NSObject *)object
{
    self = [super init];
    
    if(self)
    {
        _object = object;
    }
    
    return self;
}

-(NSObject*)object
{
    return _object;
}

@end
