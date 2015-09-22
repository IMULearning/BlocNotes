//
//  CoreDataDatasource.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "CoreDataDatasource.h"
#import "NotificationNames.h"
#import <MagicalRecord.h>

@interface CoreDataDatasource ()

@property (nonatomic, strong) NSArray *cache;
@property (nonatomic, strong) NSString *filter;
@property (nonatomic, strong) NSString *scope;

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
        [self reloadCache];
    }
    return self;
}

- (void)reloadCache {
    if (!self.filter || self.filter.length == 0) {
        self.cache = [Note MR_findAllSortedBy:NSStringFromSelector(@selector(createdTime)) ascending:YES];
    } else {
        NSString *titleFilter = [NSString stringWithFormat:@"(title like \"*%@*\")", self.filter];
        NSString *contentFilter = [NSString stringWithFormat:@"(content like \"*%@*\")", self.filter];
        
        if ([self.scope isEqualToString:@"Title"]) {
            self.cache = [Note MR_findAllSortedBy:NSStringFromSelector(@selector(createdTime))
                                        ascending:YES
                                    withPredicate:[NSPredicate predicateWithFormat:titleFilter]];
        } else if ([self.scope isEqualToString:@"Content"]) {
            self.cache = [Note MR_findAllSortedBy:NSStringFromSelector(@selector(createdTime))
                                        ascending:YES
                                    withPredicate:[NSPredicate predicateWithFormat:contentFilter]];
        } else {
            NSString *allFilter = [NSString stringWithFormat:@"%@ OR %@", titleFilter, contentFilter];
            self.cache = [Note MR_findAllSortedBy:NSStringFromSelector(@selector(createdTime))
                                        ascending:YES
                                    withPredicate:[NSPredicate predicateWithFormat:allFilter]];
        }
    }
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
    Note *newNote = [Note MR_createEntity];
    newNote.createdTime = [NSDate date];
    return newNote;
}

- (BOOL)insertNote:(Note *)newNote {
    [newNote.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        [self reloadCache];
        [self sendNotificationWithName:DATASOURCE_DID_INSERT userInfo:[self dictionaryForEventNote:newNote]];
    }];
    
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    [noteToUpdate.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        [self sendNotificationWithName:DATASOURCE_DID_UPDATE userInfo:[self dictionaryForEventNote:noteToUpdate]];
    }];
    
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    if ([self indexForNote:noteToRemove] == NSNotFound) {
        return NO;
    }
    
    NSDictionary *eventUserInfo = [self dictionaryForEventNote:noteToRemove];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        Note *note = [noteToRemove MR_inContext:localContext];
        [note MR_deleteEntity];
    }];
    [self reloadCache];
    [self sendNotificationWithName:DATASOURCE_DID_REMOVE userInfo:eventUserInfo];
    
    return YES;
}

- (NSUInteger)countNotes {
    return self.cache.count;
}

- (NSArray *)loadNotesContainingText:(NSString *)text {
    self.filter = text;
    [self reloadCache];
    return self.cache;
}

- (NSArray *)loadNotesContainingText:(NSString *)text inScope:(NSString *)scope {
    self.filter = text;
    self.scope = scope;
    [self reloadCache];
    return self.cache;
}

- (void)setCache:(NSArray *)cache {
    _cache = cache;
    if ([Note MR_countOfEntities] == 0) {
        [self sendNotificationWithName:DATASOURCE_IS_EMPTY userInfo:nil];
    } else if (_cache.count == 0) {
        [self sendNotificationWithName:DATASOURCE_CACHE_IS_EMPTY userInfo:nil];
    }
    
    [self sendNotificationWithName:DATASOURCE_CACHE_REFRESHED_WITH_RESULTS userInfo:@{@"count": [NSNumber numberWithInteger:[self countNotes]]}];
}

- (void)sendNotificationWithName:(NSString *)notificationName userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
}

- (NSDictionary *)dictionaryForEventNote:(Note *) note {
    return @{@"index": [NSNumber numberWithInteger:[self indexForNote:note]], @"note": note};
}

@end
