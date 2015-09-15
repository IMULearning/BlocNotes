//
//  Note.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "Note.h"

@implementation Note

@synthesize title;
@synthesize content;

- (instancetype) initWithDictionary:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.title = json[@"title"];
        self.content = json[@"content"];
    }
    return self;
}

- (NSString *)title {
    return [title ? title : @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)content {
    return [content ? content : @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
