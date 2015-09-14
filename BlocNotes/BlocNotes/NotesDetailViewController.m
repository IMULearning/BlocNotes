//
//  NotesDetailViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesDetailViewController.h"

#define TITLE_PLACEHOLDER NSLocalizedString(@"Title of this note", @"Title of this note")
#define CONTENT_PLACEHOLDER NSLocalizedString(@"Write your note...", @"Write your note...")

@interface NotesDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) Note *note;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UITextView *contentTextView;

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
    self.navigationItem.title = NEW_NOTE;
    
    [self createUIControls];
    NSLog(@"called!");
}

- (void)createUIControls {
    self.titleTextField = [UITextField new];
    self.titleTextField.placeholder = TITLE_PLACEHOLDER;
    self.titleTextField.delegate = self;
    
    self.separator = [UIView new];
    self.separator.backgroundColor = [UIColor lightGrayColor];
    
    self.contentTextView = [UITextView new];
    [self.contentTextView setFont:[UIFont systemFontOfSize:17]];
    [self.contentTextView setText:CONTENT_PLACEHOLDER];
    [self.contentTextView setTextColor:[UIColor lightGrayColor]];
    self.contentTextView.delegate = self;
    
    for (UIView *view in @[self.titleTextField, self.separator, self.contentTextView]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
    }
    
    [self registerAutoLayoutRules];
}

- (void)registerAutoLayoutRules {
    NSDictionary *uiControls = NSDictionaryOfVariableBindings(_titleTextField, _separator, _contentTextView);
    
    NSArray *titleTextHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_titleTextField]-|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:uiControls];
    NSArray *separatorHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_separator]|"
                                                                                      options:kNilOptions
                                                                                      metrics:nil
                                                                                        views:uiControls];
    NSArray *contentTextHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_contentTextView]-|"
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
    NSString *format = [NSString stringWithFormat:@"V:|-(%f)-[_titleTextField]-[_separator(==1.5)]-[_contentTextView]-|", self.topLayoutGuide.length + 10];
    NSArray *verticalRelationConstraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                                   options:kNilOptions
                                                                                   metrics:nil
                                                                                     views:uiControls];
    [self.view addConstraints:verticalRelationConstraints];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:CONTENT_PLACEHOLDER]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    if ([textView.text isEqualToString:@""]) {
        [textView setText:CONTENT_PLACEHOLDER];
        [textView setTextColor:[UIColor lightGrayColor]];
    }
}

@end
