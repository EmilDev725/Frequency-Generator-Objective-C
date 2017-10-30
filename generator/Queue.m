//
//  Queue.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "Queue.h"
#import "QueueNode.h"

@implementation Queue
{
    @private
    QueueNode* _firstNode;
    QueueNode* _lastNode;
    
    dispatch_queue_t _queue;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create("concurrencyQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

-(void) enqueueObject:(NSObject *)object
{
    dispatch_barrier_async(_queue,
    ^{
        QueueNode *node = [[QueueNode alloc]initWithObject:object];
        
        if(_count == 0)
        {
            _firstNode = node;
        }
        else
        {
            _lastNode.next = node;
        }
        
        _lastNode = node;
        _count++;
            
    });
}

-(id)dequeueObject
{
    if(_count == 0)
    {
        return nil;
    }
    
    __block QueueNode* node = nil;
    
    dispatch_sync(_queue,
    ^{
        node = _firstNode;
        
        if(_count == 1)
        {
            _firstNode = nil;
            _lastNode = nil;
        }
        else if(_count == 2)
        {
            _firstNode = _lastNode;
        }
        else
        {
            _firstNode = node.next;
        }
        
        _count--;
    });
    
    return node.object;
}
@end
