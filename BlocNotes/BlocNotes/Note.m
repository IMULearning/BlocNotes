//
//  Note.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "Note.h"

@implementation Note

<<<<<<< HEAD
@synthesize title;
@synthesize content;
@synthesize created;
=======
@dynamic title;
@dynamic content;
@dynamic createdTime;
>>>>>>> origin/feature/crud

- (instancetype) initWithDictionary:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.title = json[@"title"];
        self.content = json[@"content"];
        self.createdTime = [NSDate date];
    }
    return self;
}

@end
