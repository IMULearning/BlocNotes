//
//  AppDelegate.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "AppDelegate.h"
#import "NotesSplitViewController.h"
#import "NotesStartViewController.h"
#import "NotesTableViewController.h"
#import "NotesEditViewController.h"
#import "NotesManager.h"
#import <MagicalRecord.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    NSURL *containerDirectory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.kumiq.BlocNotes"];
    NSURL *databaseFileURL = [containerDirectory URLByAppendingPathComponent:kMagicalRecordDefaultStoreFileName];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:databaseFileURL];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [self.window setRootViewController:[self createRootViewController]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
}

#pragma mark - View Initialization

- (UIViewController *)createRootViewController {
    NotesSplitViewController *splitVC = [NotesSplitViewController new];
    splitVC.masterVC = [NotesTableViewController new];
    splitVC.detailVC = [NotesEditViewController new];
    splitVC.emptyStateVC = [NotesStartViewController new];

    splitVC.emptyStateVC.delegate = splitVC.masterVC;
    splitVC.masterVC.delegate = splitVC;
    splitVC.detailVC.delegate = splitVC.masterVC;
    
    UINavigationController *masterNavVC = [[UINavigationController alloc] initWithRootViewController:splitVC.masterVC];
    splitVC.detailNavVC = [[UINavigationController alloc] initWithRootViewController:([[NotesManager datasource] countNotes] == 0) ? splitVC.emptyStateVC : splitVC.detailVC];
    
    [splitVC setViewControllers:@[masterNavVC, splitVC.detailNavVC]];
    [splitVC setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    
    return splitVC;
}

@end
