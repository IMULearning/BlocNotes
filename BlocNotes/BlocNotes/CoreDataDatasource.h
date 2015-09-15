//
//  CoreDataDatasource.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotesDatasource.h"

@interface CoreDataDatasource : NSObject <NotesDatasource>

+ (instancetype) sharedInstnace;

@end
