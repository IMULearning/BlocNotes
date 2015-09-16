//
//  NotesSplitViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesSplitViewController.h"
#import <ReactiveCocoa.h>
#import "NotesManager.h"

@interface NotesSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation NotesSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"EmptyNotesNotification" object:nil] subscribeNext:^(id x) {
        [self displayEmptyStateViewController];
    }];
}

#pragma mark - NotesTableViewControllerDelegate

- (void)notesTableViewController:(NotesTableViewController *)notesTableViewController didFocusOnNote:(Note *)note {
    self.detailVC.note = note;
}

- (void)notesTableViewController:(NotesTableViewController *)notesTableViewController requestToEditNote:(Note *)note {
    self.detailVC.note = note;
    self.detailNavVC = [[UINavigationController alloc] initWithRootViewController:self.detailVC];
    [self showDetailViewController:self.detailNavVC sender:self];
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

#pragma mark - Misc

- (void) displayEmptyStateViewController {
    self.detailNavVC = [[UINavigationController alloc] initWithRootViewController:self.emptyStateVC];
    [self showDetailViewController:self.detailNavVC sender:self];
}

@end
