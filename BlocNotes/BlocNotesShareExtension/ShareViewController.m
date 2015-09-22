//
//  ShareViewController.m
//  BlocNotesShareExtension
//
//  Created by Weinan Qiu on 2015-09-22.
//  Copyright © 2015 Kumiq. All rights reserved.
//

#import "ShareViewController.h"
#import "NotesManager.h"
#import "Note.h"
#import <MagicalRecord.h>

@interface ShareViewController ()

@property (nonatomic, strong) NSString *urlString;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *containerDirectory = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.kumiq.BlocNotes"];
    NSURL *databaseFileURL = [containerDirectory URLByAppendingPathComponent:kMagicalRecordDefaultStoreFileName];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreAtURL:databaseFileURL];
    
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:^(NSURL *url, NSError *error){
            self.urlString = url.absoluteString;
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [MagicalRecord cleanUp];
}

- (BOOL)isContentValid {
    return YES;
}

- (void)didSelectPost {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:^(BOOL expired) {
        if (self.textView.text || self.urlString) {
            Note *newNote = [[NotesManager datasource] initializeNewNote];
            newNote.title = self.textView.text;
            newNote.content = self.urlString;
            [[NotesManager datasource] insertNote:newNote];
        }
    }];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
