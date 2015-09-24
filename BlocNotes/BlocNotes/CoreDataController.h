//
//  CoreDataController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-24.
//  Copyright © 2015 Kumiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const kBlocNotesApplicationGroupName;
extern NSString * const kBlocNotesDataStoreFileName;
extern NSString * const kBlocNotesModelResourceName;
extern NSString * const kBlocNotesUbiquityIdentityTokenName;
extern NSString * const kBlocNotesiCloudContainerID;

@interface CoreDataController : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype) controller;

@end
