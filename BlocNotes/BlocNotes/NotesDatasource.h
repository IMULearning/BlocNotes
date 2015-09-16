//
//  NotesDatasource.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#define NO_MORE_NOTES @"NoMoreNotesNotification";

@protocol NotesDatasource <NSObject>

- (NSArray *)loadAllNotes;

- (Note *)noteAtIndex:(NSUInteger)index;

- (NSInteger)indexForNote:(Note *)note;

- (Note *)initializeNewNote;

- (BOOL)insertNote:(Note *)newNote;

- (BOOL)updateNote:(Note *)noteToUpdate;

- (BOOL)removeNote:(Note *)noteToRemove;

- (NSUInteger)countNotes;

@end
