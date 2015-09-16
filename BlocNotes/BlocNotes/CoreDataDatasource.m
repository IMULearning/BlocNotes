//
//  CoreDataDatasource.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "CoreDataDatasource.h"
#import <ObjectiveRecord.h>

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
        self.cache = [Note allWithOrder:@"createdTime"];
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
    self.cache = [Note allWithOrder:@"createdTime"];
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    [noteToUpdate save];
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    [noteToRemove delete];
    self.cache = [Note allWithOrder:@"createdTime"];
    return YES;
}

- (NSUInteger)countNotes {
    return self.cache.count;
}

- (void)setCache:(NSArray *)cache {
    _cache = cache;
}

@end
