//
//  NotesManager.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesManager.h"
#import "InMemoryDatasource.h"
#import "CoreDataDatasource.h"

@implementation NotesManager

+ (id <NotesDatasource>) datasource {
    //return [InMemoryDatasource sharedInstnace];
    return [CoreDataDatasource sharedInstnace];
}

+ (NSArray *) searchScopes {
    return @[@"All", @"Title", @"Content"];
}

@end
