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

- (NSArray *)loadAllNotes {
    return [Note all];
}

- (Note *)noteAtIndex:(NSUInteger)index {
    return [[Note all] objectAtIndex:index];
}

- (NSInteger)indexForNote:(Note *)note {
    return [[Note all] indexOfObject:note];
}

- (Note *)initializeNewNote {
    return [Note create];
}

- (BOOL)insertNote:(Note *)newNote {
    [newNote save];
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    [noteToUpdate save];
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    [noteToRemove delete];
    return YES;
}

- (NSUInteger)countNotes {
    return [Note count];
}

@end
