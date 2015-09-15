//
//  NotesDetailViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesDetailViewController.h"
#import <UITextView+Placeholder.h>
#import "NotesManager.h"

#define TITLE_PLACEHOLDER NSLocalizedString(@"Title of this note", @"Title of this note")
#define CONTENT_PLACEHOLDER NSLocalizedString(@"Write your note...", @"Write your note...")

@interface NotesDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) Note *note;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;

@end

@implementation NotesDetailViewController

- (instancetype)initWithNote:(Note *)note {
    self = [super init];
    if (self) {
        _note = note;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setupNavigationBar];
    [self createUIControls];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.delegate) {
        [self.delegate notesDetailViewController:self didFinishWithNote:self.note];
    }
    [super viewWillDisappear:animated];
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
    
    [self registerAutoLayoutRules];
}

- (void)registerAutoLayoutRules {
    NSDictionary *uiControls = NSDictionaryOfVariableBindings(_titleTextField, _separator, _contentTextView);
    
    NSArray *titleTextHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[_titleTextField]-|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:uiControls];
    NSArray *separatorHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[_separator]|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:uiControls];
    NSArray *contentTextHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_contentTextView]-|"
                                                                                        options:kNilOptions
                                                                                        metrics:nil
                                                                                          views:uiControls];
    
    [self.view addConstraints:titleTextHorizontalConstraints];
    [self.view addConstraints:separatorHorizontalConstraints];
    [self.view addConstraints:contentTextHorizontalConstraints];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    NSDictionary *uiControls = NSDictionaryOfVariableBindings(_titleTextField, _separator, _contentTextView);
    NSString *format = [NSString stringWithFormat:@"V:|-(%f)-[_titleTextField(==35)]-[_separator(==1.5)]-[_contentTextView]-|", self.topLayoutGuide.length + 15];
    NSArray *verticalRelationConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                                   options:kNilOptions
                                                                                   metrics:nil
                                                                                     views:uiControls];
    [self.view addConstraints:verticalRelationConstraints];
}

#pragma mark - Button Target

- (void)doneFired:(UIBarButtonItem *)sender {
    self.note.title = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.note.content = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [self.navigationController.navigationController popToRootViewControllerAnimated:YES];
}

- (void)shareButtonFired:(UIBarButtonItem *)sender {
    NSString *formatted = [NSString stringWithFormat:@"%@\n\n%@", self.note.title, self.note.content];
    NSString *shareText = [formatted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (shareText.length > 0) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

@end
