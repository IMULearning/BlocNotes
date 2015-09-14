//
//  NotesListViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesListViewController.h"

@interface NotesListViewController () //<UISplitViewControllerDelegate>

@end

@implementation NotesListViewController

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.splitViewController.delegate = self;
    }
    return self;
}

#pragma mark - View intialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.title = NSLocalizedString(@"BlocNotes", @"BlocNotes");
}

#pragma mark - UISplitViewControllerDelegate

//- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
//    return YES;
//}

@end
