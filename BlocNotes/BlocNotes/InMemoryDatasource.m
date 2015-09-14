//
//  InMemoryDatasource.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "InMemoryDatasource.h"

@interface InMemoryDatasource () {
    NSMutableArray *_notes;
}

@property (nonatomic, strong) NSArray *notes;

@end

@implementation InMemoryDatasource

#pragma mark - Initialization

+ (instancetype) sharedInstnace {
    static dispatch_once_t once_token;
    static id instance;
    
    dispatch_once(&once_token, ^{
        instance = [[InMemoryDatasource alloc] init];
    });
    
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _notes = [NSMutableArray array];
        NSDictionary *parsedJson = [self loadBundledNotes];
        NSArray *allNotesJson = parsedJson[@"data"];
        if (allNotesJson && allNotesJson.count > 0) {
            for (int i = 0; i < allNotesJson.count; i++) {
                NSDictionary *json = [allNotesJson objectAtIndex:i];
                Note *newNote = [[Note alloc] initWithDictionary:json];
                [self insertNote:newNote];
            }
        }
    }
    return self;
}

/*
 Load notes.json into NSDictionary
 */
- (NSDictionary *) loadBundledNotes {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"notes" ofType:@"json"];
    NSError *fileReadingError;
    NSData *fileData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&fileReadingError];
    
    if (fileReadingError) {
        NSLog(@"Loading file content at [%@] encountered error [%@]", filePath, fileReadingError);
        return @{};
    }
    
    NSError *jsonParseError;
    id parseJson = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:&jsonParseError];
    if (jsonParseError) {
        NSLog(@"Error parsing json at [%@]: [%@]", filePath, jsonParseError);
        return @{};
    } else if (![parseJson isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parse didn't result in expected NSDictionary class. [%@]", [parseJson class]);
        return @{};
    }
    
    return (NSDictionary *)parseJson;
}

#pragma mark - NotesDatasource

- (NSArray *)loadAllNotes {
    return _notes;
}

- (Note *)noteAtIndex:(NSUInteger)index {
    return [_notes objectAtIndex:index];
}

- (BOOL)insertNote:(Note *)newNote {
    if (!newNote) {
        return NO;
    }
    [_notes addObject:newNote];
    return YES;
}

- (BOOL)updateNote:(Note *)noteToUpdate {
    if (!noteToUpdate) {
        return NO;
    }
    NSUInteger index = [_notes indexOfObject:noteToUpdate];
    if (index == NSNotFound) {
        return NO;
    }
    [_notes replaceObjectAtIndex:index withObject:noteToUpdate];
    return YES;
}

- (BOOL)removeNote:(Note *)noteToRemove {
    if (!noteToRemove) {
        return NO;
    }
    [_notes removeObject:noteToRemove];
    return YES;
}

- (NSUInteger)countNotes {
    return _notes.count;
}

@end
