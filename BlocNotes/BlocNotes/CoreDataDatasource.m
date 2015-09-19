//
//  CoreDataDatasource.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "CoreDataDatasource.h"
#import <ObjectiveRecord.h>
#import "NotificationNames.h"

@interface CoreDataDatasource ()

@property (nonatomic, strong) NSArray *cache;

@end

@implementation CoreDataDatasource

+ (instancetype) sharedInstnace {
    static dispatch_once_t once_token;
    static id instance;
    
    dispatch_once(&once_token, ^{
        instance = [[CoreDataDatasource alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [Note allWithOrder:NSStringFromSelector(@selector(createdTime))];
    }
    return self;
}

- (NSArray *)loadAllNotes {
    return self.cache;
}

- (Note *)noteAtIndex:(NSUInteger)index {
    return [self.cache objectAtIndex:index];
}

- (NSInteger)indexForNote:(Note *)note {
    return [self.cache indexOfObject:note];
}

- (Note *)initializeNewNote {
    Note *newNote = [Note create];
    newNote.createdTime = [NSDate date];
    return newNote;
}

- (BOOL)insertNote:(Note *)newNote {
    [newNote save];
    self.cache = [Note allWithOrder:NSStringFromSelector(@selector(createdTime))];
    [self sendNotificationWithName:DATASOURCE_DID_INSERT
                          userInfo:[self dictionaryForEventNote:newNote]];
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    [noteToUpdate save];
    [self sendNotificationWithName:DATASOURCE_DID_UPDATE
                          userInfo:[self dictionaryForEventNote:noteToUpdate]];
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    if ([self indexForNote:noteToRemove] == NSNotFound) {
        return NO;
    }
    
    NSDictionary *eventUserInfo = [self dictionaryForEventNote:noteToRemove];
    [noteToRemove delete];
    self.cache = [Note allWithOrder:NSStringFromSelector(@selector(createdTime))];
    [self sendNotificationWithName:DATASOURCE_DID_REMOVE userInfo:eventUserInfo];
    
    return YES;
}

- (NSUInteger)countNotes {
    return self.cache.count;
}

- (void)setCache:(NSArray *)cache {
    _cache = cache;
    if (_cache.count == 0) {
        [self sendNotificationWithName:DATASOURCE_IS_EMPTY userInfo:nil];
    }
}

- (void)sendNotificationWithName:(NSString *)notificationName userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
}

- (NSDictionary *)dictionaryForEventNote:(Note *) note {
    return @{@"index": [NSNumber numberWithInteger:[self indexForNote:note]], @"note": note};
}

@end
