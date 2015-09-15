//
//  Note.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define NEW_NOTE NSLocalizedString(@"New Note", @"New Note")

@interface Note : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *created;

- (instancetype) initWithDictionary:(NSDictionary *)json;

@end
