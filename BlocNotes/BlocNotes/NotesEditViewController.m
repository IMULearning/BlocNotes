//
//  NotesEditViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesEditViewController.h"
#import <UITextView+Placeholder.h>
#import "NotesManager.h"
#import <ReactiveCocoa.h>
#import <Masonry.h>

#define TITLE_PLACEHOLDER NSLocalizedString(@"Title of this note", @"Title of this note")
#define CONTENT_PLACEHOLDER NSLocalizedString(@"Write your note...", @"Write your note...")

@interface NotesEditViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;

@end

@implementation NotesEditViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setupNavigationBar];
    [self createUIControls];
    [self registerInitialAutoLayoutRules];
    [self setupTextSignals];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateTopPositionAutoLayoutRules];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.delegate) {
        [self.delegate notesEditViewController:self didFinishWithNote:self.note];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Setup

- (void)setupTextSignals {
    [[self.titleTextField.rac_textSignal throttle:0.2] subscribeNext:^(id x) {
        if (!self.note.title) {
            self.note.title = @"";
        }
        self.note.title = x;
        [[NotesManager datasource] updateNote:self.note];
    }];
    
    [[self.contentTextView.rac_textSignal throttle:0.2] subscribeNext:^(id x) {
        self.note.content = x;
        [[NotesManager datasource] updateNote:self.note];
    }];
}

- (void)setupNavigationBar {
    self.navigationItem.title = NEW_NOTE;
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(doneFired:)];
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonFired:)];
    
    self.navigationItem.rightBarButtonItems = @[self.doneButton, self.shareButton];
}

- (void)createUIControls {
    self.titleTextField = [UITextField new];
    self.titleTextField.placeholder = TITLE_PLACEHOLDER;
    if (self.note.title) {
        self.titleTextField.text = self.note.title;
    }
    self.titleTextField.delegate = self;
    
    
    self.separator = [UIView new];
    self.separator.backgroundColor = [UIColor lightGrayColor];
    
    self.contentTextView = [UITextView new];
    self.contentTextView.placeholder = CONTENT_PLACEHOLDER;
    [self.contentTextView setFont:[UIFont systemFontOfSize:17]];
    if (self.note.content) {
        self.contentTextView.text = self.note.content;
    }
    self.contentTextView.delegate = self;
    
    for (UIView *view in @[self.titleTextField, self.separator, self.contentTextView]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
    }
}

#pragma mark - Auto layout

- (void)registerInitialAutoLayoutRules {
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(self.topLayoutGuide.length + 15);
        make.left.equalTo(self.view.mas_left).with.offset(24);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.height.equalTo(@35);
    }];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleTextField.mas_bottom).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(24);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@1.5);
    }];
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separator.mas_bottom).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(20);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
}

- (void)updateTopPositionAutoLayoutRules {
    [self.titleTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(self.topLayoutGuide.length + 15);
    }];
    [self.separator mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleTextField.mas_bottom).with.offset(20);
    }];
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separator.mas_bottom).with.offset(20);
    }];
}

#pragma mark - Button Target

- (void)doneFired:(UIBarButtonItem *)sender {
    [self.navigationController.navigationController popToRootViewControllerAnimated:YES];
    if (self.delegate) {
        [self.delegate notesEditViewController:self didFinishWithNote:self.note];
    }
}

- (void)shareButtonFired:(UIBarButtonItem *)sender {
    NSString *formatted = [NSString stringWithFormat:@"%@\n\n%@", self.note.title, self.note.content];
    NSString *shareText = [formatted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (shareText.length > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - Note

- (void)setNote:(Note *)note {
    if (self.delegate) {
        [self.delegate notesEditViewController:self receivedNewNote:note toReplaceOldNote:_note];
    }
    _note = note;
    _titleTextField.text = _note.title;
    _contentTextView.text = _note.content;
}

@end
