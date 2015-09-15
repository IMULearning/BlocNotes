//
//  Note.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "Note.h"

@implementation Note

@dynamic title;
@dynamic content;

- (instancetype) initWithDictionary:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.title = json[@"title"];
        self.content = json[@"content"];
    }
    return self;
}

@end
