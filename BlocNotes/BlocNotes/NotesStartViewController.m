//
//  NotesStartViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesStartViewController.h"
#import "NotificationNames.h"
#import <ReactiveCocoa.h>

#define NO_RESULTS NSLocalizedString(@"No Results", @"No Results")
#define SINGLE_RESULTS NSLocalizedString(@"1 Result", @"1 Result")

@interface NotesStartViewController ()

@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UILabel *noResultsLabel;

@end

@implementation NotesStartViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.startButton setTitle:@"Let's write some notes!" forState:UIControlStateNormal];
        [self.view addSubview:self.startButton];
        [self.startButton addTarget:self action:@selector(startButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        
        self.noResultsLabel = [UILabel new];
        self.noResultsLabel.text = NO_RESULTS;
        self.noResultsLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:self.noResultsLabel];
        
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DATASOURCE_IS_EMPTY object:nil] subscribeNext:^(id x) {
            self.startButton.hidden = NO;
            self.noResultsLabel.hidden = YES;
        }];
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DATASOURCE_CACHE_IS_EMPTY object:nil] subscribeNext:^(id x) {
            self.startButton.hidden = YES;
            self.noResultsLabel.hidden = NO;
        }];
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DATASOURCE_CACHE_REFRESHED_WITH_RESULTS object:nil] subscribeNext:^(id x) {
            NSNotification *notification = x;
            NSNumber *countNumber = notification.userInfo[@"count"];
            if ([countNumber integerValue] == 0) {
                self.noResultsLabel.text = NO_RESULTS;
            } else if ([countNumber integerValue] == 1) {
                self.noResultsLabel.text = SINGLE_RESULTS;
            } else {
                self.noResultsLabel.text = [[NSString stringWithFormat:@"%@", countNumber] stringByAppendingString:NSLocalizedString(@" Results", @" Results")];
            }
        }];
        
        self.startButton.hidden = YES;
        self.noResultsLabel.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.startButton sizeToFit];
    [self.noResultsLabel sizeToFit];
    
    CGFloat x1 = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.startButton.frame)) / 2;
    CGFloat y1 = (CGRectGetHeight(self.view.frame)) / 3;
    self.startButton.frame = CGRectMake(x1, y1, CGRectGetWidth(self.startButton.frame), CGRectGetHeight(self.startButton.frame));
    
    CGFloat x2 = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.noResultsLabel.frame)) / 2;
    CGFloat y2 = (CGRectGetHeight(self.view.frame)) / 3;
    self.noResultsLabel.frame = CGRectMake(x2, y2, CGRectGetWidth(self.noResultsLabel.frame), CGRectGetHeight(self.noResultsLabel.frame));
}

- (void)startButtonFired:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate didRequestNewNoteFromNotesStartViewController:self];
    }
}

@end
