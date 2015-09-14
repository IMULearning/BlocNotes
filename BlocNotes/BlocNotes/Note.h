//
//  Note.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NEW_NOTE NSLocalizedString(@"New Note", @"New Note")

@interface Note : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

- (instancetype) initWithDictionary:(NSDictionary *)json;

- (NSString *)description;

@end
