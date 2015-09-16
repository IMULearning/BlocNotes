//
//  NotesStartViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesStartViewController.h"

@interface NotesStartViewController ()

@property (nonatomic, strong) UIButton *startButton;

@end

@implementation NotesStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startButton setTitle:@"Let's write some notes!" forState:UIControlStateNormal];
    [self.view addSubview:self.startButton];
    
    [self.startButton addTarget:self action:@selector(startButtonFired:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.startButton sizeToFit];
    
    CGFloat x = (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.startButton.frame)) / 2;
    CGFloat y = (CGRectGetHeight(self.view.frame)) / 3;
    self.startButton.frame = CGRectMake(x, y, CGRectGetWidth(self.startButton.frame), CGRectGetHeight(self.startButton.frame));
}

- (void)startButtonFired:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate didRequestNewNoteFromNotesStartViewController:self];
    }
}

@end
