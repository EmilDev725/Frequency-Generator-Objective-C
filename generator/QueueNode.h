//
//  QueueNode.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueueNode : NSObject

@property (nonatomic, strong) NSObject* object;
@property (nonatomic, strong) QueueNode* next;

-(instancetype) initWithObject:(NSObject*) object;

@end
