//
//  CoreDataController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-24.
//  Copyright © 2015 Kumiq. All rights reserved.
//

#import "CoreDataController.h"
#import <ReactiveCocoa.h>
#import "NotificationNames.h"

NSString * const kBlocNotesApplicationGroupName = @"group.com.kumiq.BlocNotes";
NSString * const kBlocNotesDataStoreFileName = @"BlocNotesDataStore.sqlite";
NSString * const kBlocNotesModelResourceName = @"BlocNotes";
NSString * const kBlocNotesUbiquityIdentityTokenName = @"com.kumiq.BlocNotes.UbiquityIdentityToken";
NSString * const kBlocNotesiCloudContainerID = @"iCloud.com.kumiq.BlocNotes";

@interface CoreDataController ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistenceStoreCoordinator;

@property (nonatomic, strong) NSTimer *mergedEventTimer;
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
        [self setupiCloud];
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
    [bootstrap addEntriesFromDictionary:[self iCloudOptions]];
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

- (NSDictionary *) iCloudOptions {
    return @{NSPersistentStoreUbiquitousContentNameKey: @"BlocNotesCloudStore"};
}

#pragma mark - Setup iCloud

- (void) setupiCloud {
    [self archivingiCloudToken];
    [self registerForPersistentStoreCoordinatorStoresWillChangeNotification];
    [self registerForPersistentStoreCoordinatorStoreChangedNotification];
    [self registerForiCloudAvailabilityNotification];
    [self registerForPersistentStoreDidImportContentChangeNotification];
}

- (void) registerForPersistentStoreDidImportContentChangeNotification {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"Did import change!");
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:x];
        if (self.mergedEventTimer != nil) {
            [self.mergedEventTimer invalidate];
            self.mergedEventTimer = nil;
        }
        self.mergedEventTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(sendContextMergedNotification) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.mergedEventTimer forMode:NSDefaultRunLoopMode];
    }];
}

- (void) sendContextMergedNotification {
    [self.mergedEventTimer invalidate];
    self.mergedEventTimer = nil;
    NSLog(@"Did fire change event!");
    [[NSNotificationCenter defaultCenter] postNotificationName:MANAGED_CONTEXT_DID_RECEIVE_ICLOUD_CHANGES object:nil];
}

- (void) registerForPersistentStoreCoordinatorStoresWillChangeNotification {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NSPersistentStoreCoordinatorStoresWillChangeNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"Persistent Store Coordinator Store will changed");
        [self.managedObjectContext performBlock:^{
            if ([self.managedObjectContext hasChanges]) {
                [self.managedObjectContext save:nil];
            } else {
                [self.managedObjectContext reset];
            }
        }];
    }];
}

- (void) registerForPersistentStoreCoordinatorStoreChangedNotification {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"Persistent Store Coordinator Store changed.");
    }];
}

- (void) registerForiCloudAvailabilityNotification {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NSUbiquityIdentityDidChangeNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"iCloud availability changed: \n%@\n", x);
    }];
}

- (void) archivingiCloudToken {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    id currentiCloudToken = fileManager.ubiquityIdentityToken;
    NSLog(@"Ubuquity Token: %@", currentiCloudToken);
    if (currentiCloudToken) {
        NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults] setObject: newTokenData
                                                  forKey: kBlocNotesUbiquityIdentityTokenName];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: kBlocNotesUbiquityIdentityTokenName];
    }
}

// TODO register NSUbiquityIdentityDidChangeNotification for iCloud availability

@end
