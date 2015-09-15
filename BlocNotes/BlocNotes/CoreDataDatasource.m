//
//  CoreDataDatasource.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "CoreDataDatasource.h"
#import <ObjectiveRecord.h>

@interface CoreDataDatasource () {
    NSMutableArray *_cache;
}

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
        self.cache = [Note all];
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
    return [Note create];
}

- (BOOL)insertNote:(Note *)newNote {
    [newNote save];
    self.cache = [Note all];
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    [noteToUpdate save];
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    [noteToRemove delete];
    self.cache = [Note all];
    return YES;
}

- (NSUInteger)countNotes {
    return [Note count];
}

@end
