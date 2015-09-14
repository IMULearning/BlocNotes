//
//  NotesSplitViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesSplitViewController.h"

@interface NotesSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation NotesSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return YES;
}

@end
