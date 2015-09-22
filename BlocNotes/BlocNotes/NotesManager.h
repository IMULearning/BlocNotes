//
//  NotesManager.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotesDatasource.h"

@interface NotesManager : NSObject

+ (id <NotesDatasource>) datasource;

+ (NSArray *) searchScopes;

@end
