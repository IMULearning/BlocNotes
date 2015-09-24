//
//  CoreDataController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-24.
//  Copyright © 2015 Kumiq. All rights reserved.
//

#import "CoreDataController.h"

NSString * const kBlocNotesApplicationGroupName = @"group.com.kumiq.BlocNotes";
NSString * const kBlocNotesDataStoreFileName = @"BlocNotesDataStore.sqlite";
NSString * const kBlocNotesModelResourceName = @"BlocNotes";

@interface CoreDataController ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistenceStoreCoordinator;

@end

@implementation CoreDataController

#pragma mark - Initialization

+ (instancetype) controller {
    static dispatch_once_t token;
    static id instance;
    
    dispatch_once(&token, ^{
        instance = [[CoreDataController alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupCoreData];
    }
    return self;
}

#pragma mark - Setup Core Data

- (void) setupCoreData {
    [self setupManagedModel];
    [self setupPersistenceStoreCoordinator];
    [self setupManagedObjectContext];
    [self setupDataStore];
}

- (void) setupManagedModel {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kBlocNotesModelResourceName withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

- (void) setupPersistenceStoreCoordinator {
    NSAssert(self.managedObjectModel != nil, @"Error initializing Managed Object Model");
    self.persistenceStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
}

- (void) setupManagedObjectContext {
    NSAssert(self.persistenceStoreCoordinator != nil, @"Error initializing Persistent Store Coordinator");
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = self.persistenceStoreCoordinator;
}

- (void) setupDataStore {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = self.managedObjectContext.persistentStoreCoordinator;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                     configuration:nil
                                                               URL:[self localDataStoreFileURL]
                                                           options:[self optionsBootstrap]
                                                             error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}

- (NSURL *) localDataStoreFileURL {
    NSURL *containerDirectory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kBlocNotesApplicationGroupName];
    return [containerDirectory URLByAppendingPathComponent:kBlocNotesDataStoreFileName];
}

- (NSDictionary *) optionsBootstrap {
    NSMutableDictionary *bootstrap = [@{} mutableCopy];
    [bootstrap addEntriesFromDictionary:[self sqlLiteOptions]];
    [bootstrap addEntriesFromDictionary:[self autoMigratingOptions]];
    return bootstrap;
}

- (NSDictionary *) sqlLiteOptions {
    return @{
             @"journal_mode": @"WAL"
             };
}

- (NSDictionary *) autoMigratingOptions {
    return @{
             NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
             NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES]
             };
}

@end
