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
#import <BOString.h>
#import "URLAwareMenuItem.h"

#define TITLE_PLACEHOLDER NSLocalizedString(@"Title of this note", @"Title of this note")
#define CONTENT_PLACEHOLDER NSLocalizedString(@"Write your note...", @"Write your note...")

@interface NotesEditViewController () <UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;
@property (nonatomic, strong) NSDataDetector *detector;
@property (nonatomic, strong) NSMutableArray *checkResults;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation NotesEditViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setupNavigationBar];
    [self createUIControls];
    [self setupTextSignals];
    [self registerInitialAutoLayoutRules];
    [self setupDataDetector];
    [self setupGesture];
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
        self.note.title = x;
        [[NotesManager datasource] updateNote:self.note];
    }];
    
    [[self.contentTextView.rac_textSignal throttle:0.2] subscribeNext:^(id x) {
        self.note.content = x;
        [[NotesManager datasource] updateNote:self.note];
    }];
    
    [[self.contentTextView.rac_textSignal throttle:0.1] subscribeNext:^(id x) {
        [self detectDataAndRenderText];
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

- (void)setupDataDetector {
    self.detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink error:nil];
}

- (void)setupGesture {
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
    self.tapRecognizer.delegate = self;
    [self.contentTextView addGestureRecognizer:self.tapRecognizer];
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
    
    [self detectDataAndRenderText];
}

#pragma mark - Data Detection

- (void)detectDataAndRenderText {
    self.checkResults = [NSMutableArray array];
    [self.detector enumerateMatchesInString:self.contentTextView.text
                                    options:kNilOptions
                                      range:NSMakeRange(0, self.contentTextView.text.length)
                                 usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                     [self.checkResults addObject:result];
    }];
    
    NSAttributedString *result = [self.contentTextView.text bos_makeString:^(BOStringMaker *make) {
        make.font([UIFont systemFontOfSize:17]);
        [self.checkResults enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSTextCheckingResult *result = obj;
            make.with.range(result.range, ^{
                make.foregroundColor([UIColor blueColor]);
                make.underlineColor([UIColor blueColor]);
                make.underlineStyle(@(NSUnderlineStyleSingle));
            });
        }];
    }];
 
    UITextRange *cursorPosition = self.contentTextView.selectedTextRange;
    self.contentTextView.attributedText = result;
    self.contentTextView.selectedTextRange = cursorPosition;
}

#pragma mark - Gesture

- (void)tapFired:(UITapGestureRecognizer *)sender {
    CGPoint position = [sender locationInView:self.contentTextView];
    
    position.y += self.contentTextView.contentOffset.y;
    position.x += self.contentTextView.contentOffset.x;
    
    UITextPosition *tapPosition = [self.contentTextView closestPositionToPoint:position];
    UITextRange *textRange = [self.contentTextView.tokenizer rangeEnclosingPosition:tapPosition withGranularity:UITextGranularitySentence inDirection:UITextLayoutDirectionRight];
    
    for (NSTextCheckingResult *result in self.checkResults) {
        NSRange intersection = NSIntersectionRange(result.range, [self convertTextRange:textRange]);
        if (intersection.length > 0) {
            NSURL *urlToOpen;
            NSString *menuTitle = @"Open";
            if (result.resultType == NSTextCheckingTypeLink) {
                urlToOpen = result.URL;
                if ([result.URL.absoluteString rangeOfString:@"mailto:"].location != NSNotFound) {
                    menuTitle = [@"Email " stringByAppendingString:[result.URL.absoluteString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""]];
                } else {
                    menuTitle = [@"Visit " stringByAppendingString:result.URL.absoluteString];;
                }
            } else if (result.resultType == NSTextCheckingTypePhoneNumber) {
                urlToOpen = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [result.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]]];
                menuTitle = [@"Call " stringByAppendingString:result.phoneNumber];
            }
            
            if (urlToOpen) {
                URLAwareMenuItem *menuItem = [[URLAwareMenuItem alloc] initWithTitle:menuTitle action:@selector(openMenuUrl:)];
                menuItem.URL = urlToOpen;
                [[UIMenuController sharedMenuController] setMenuItems:@[menuItem]];
                break;
            }
        } else {
            [[UIMenuController sharedMenuController] setMenuItems:@[]];
        }
    }
}

- (void)openMenuUrl:(UIMenuController *)sender {
    URLAwareMenuItem *menuItem = (URLAwareMenuItem *)[sender.menuItems firstObject];
    [[UIApplication sharedApplication] openURL:menuItem.URL];
}

- (NSRange)convertTextRange:(UITextRange *)textRange {
    UITextPosition* beginning = self.contentTextView.beginningOfDocument;
    UITextPosition* selectionStart = textRange.start;
    UITextPosition* selectionEnd = textRange.end;
    const NSInteger location = [self.contentTextView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self.contentTextView offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
