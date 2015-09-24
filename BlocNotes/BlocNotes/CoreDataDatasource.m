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
#import <ReactiveCocoa.h>
#import "CoreDataController.h"

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

        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MANAGED_CONTEXT_DID_RECEIVE_ICLOUD_CHANGES object:nil] subscribeNext:^(id x) {
            [self reloadCache];
            [[NSNotificationCenter defaultCenter] postNotificationName:DATASOURCE_DID_RECEIVE_ICLOUD_UPDATE object:nil];
        }];
    }
    return self;
}

- (void)reloadCache {
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    NSSortDescriptor *sortByCreatedTime = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(createdTime))
                                                                        ascending:YES];
    [request setSortDescriptors:@[sortByCreatedTime]];
    
    if (self.filter.length > 0) {
        NSString *titleFilter = [NSString stringWithFormat:@"(title like \"*%@*\")", self.filter];
        NSString *contentFilter = [NSString stringWithFormat:@"(content like \"*%@*\")", self.filter];
        NSString *allFilter = [NSString stringWithFormat:@"%@ OR %@", titleFilter, contentFilter];
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:titleFilter];
        NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:contentFilter];
        NSPredicate *allPredicate = [NSPredicate predicateWithFormat:allFilter];
        
        if ([self.scope isEqualToString:@"Title"]) {
            [request setPredicate:titlePredicate];
        } else if ([self.scope isEqualToString:@"Content"]) {
            [request setPredicate:contentPredicate];
        } else {
            [request setPredicate:allPredicate];
        }
    }
    
    self.cache = [[CoreDataController controller].managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error loading cache! %@, %@", [error localizedDescription], [error userInfo]);
    }
    
    [self.cache enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Cache entry: %@", [obj valueForKey:@"title"]);
    }];
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
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                  inManagedObjectContext:[CoreDataController controller].managedObjectContext];
    newNote.createdTime = [NSDate date];
    return newNote;
}

- (BOOL)insertNote:(Note *)newNote {
    NSError *error = nil;
    if ([[CoreDataController controller].managedObjectContext save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    [self reloadCache];
    [self sendNotificationWithName:DATASOURCE_DID_INSERT userInfo:[self dictionaryForEventNote:newNote]];
    
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    NSError *error = nil;
    if ([noteToUpdate.managedObjectContext save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    [self sendNotificationWithName:DATASOURCE_DID_UPDATE userInfo:[self dictionaryForEventNote:noteToUpdate]];
    
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    [[CoreDataController controller].managedObjectContext deleteObject:noteToRemove];
    [[CoreDataController controller].managedObjectContext save:nil];
    
    if ([self indexForNote:noteToRemove] != NSNotFound) {
        NSDictionary *eventUserInfo = [self dictionaryForEventNote:noteToRemove];
        [self reloadCache];
        [self sendNotificationWithName:DATASOURCE_DID_REMOVE userInfo:eventUserInfo];
    }
    
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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Note"];
    if ([[CoreDataController controller].managedObjectContext countForFetchRequest:request error:nil] == 0) {
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
