//
//  Note.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "Note.h"

@implementation Note

- (instancetype) initWithDictionary:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.title = json[@"title"];
        self.content = json[@"content"];
    }
    return self;
}

- (NSString *)title {
    return [_title ? _title : @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)content {
    return [_content ? _content : @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)description {
    if (self.title && self.title.length > 0) {
        return self.title;
    } else if (self.content && self.content.length > 0) {
        return self.content;
    } else {
        return NEW_NOTE;
    }
}

- (BOOL)hasText {
    return self.title.length > 0 || self.content.length > 0;
}

@end
