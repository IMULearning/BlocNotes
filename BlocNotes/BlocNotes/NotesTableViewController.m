//
//  NotesTableViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesTableViewController.h"
#import "NotesStartViewController.h"
#import "NotesTableViewCell.h"
#import "NotesManager.h"
#import "Note.h"

#define CELL_ID @"cell"

@interface NotesTableViewController ()

@property (nonatomic, strong) UIBarButtonItem *createNoteButton;

@end

@implementation NotesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView registerClass:[NotesTableViewCell class] forCellReuseIdentifier:CELL_ID];
    
    [self configureNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [self selectFirstItem];
    [super viewWillAppear:animated];
}

- (void)configureNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"BlocNotes", @"BlocNotes");
    self.createNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(createNoteButtonFired:)];
    self.navigationItem.rightBarButtonItem = self.createNoteButton;
}

- (void)selectFirstItem {
    if ([[NotesManager datasource] countNotes] > 0) {
        NSIndexPath *first = [NSIndexPath indexPathForItem:0 inSection:0];
        Note *note = [[NotesManager datasource] noteAtIndex:0];
        [self.tableView selectRowAtIndexPath:first animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (self.delegate) {
            [self.delegate notesTableViewController:self didFocusOnNote:note];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NotesManager datasource] countNotes];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = [[NotesManager datasource] noteAtIndex:indexPath.row];
    if (self.delegate) {
        [self.delegate notesTableViewController:self requestToEditNote:note];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    cell.note = [[NotesManager datasource] noteAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    Note *note = [[NotesManager datasource] noteAtIndex:indexPath.row];
    if ([[NotesManager datasource] removeNote:note]) {
        [self deleteRowsAtIndexPaths:@[indexPath] forTableView:tableView];
        
        if (indexPath.row > 0) {
            NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
            Note *newNote = [[NotesManager datasource] noteAtIndex:newPath.row];
            [self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            if (self.delegate) {
                [self.delegate notesTableViewController:self didFocusOnNote:newNote];
            }
        } else {
            if ([[NotesManager datasource] countNotes] > 0) {
                Note *newNote = [[NotesManager datasource] noteAtIndex:indexPath.row];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                if (self.delegate) {
                    [self.delegate notesTableViewController:self didFocusOnNote:newNote];
                }
            }
        }
    }
    
    if ([[NotesManager datasource] countNotes] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EmptyNotesNotification" object:nil];
    }
}

#pragma mark - NotesEditViewControllerDelegate

- (void)notesEditViewController:(NotesEditViewController *)notesEditViewController didFinishWithNote:(Note *)note {
    if (note.title.length > 0 || note.content.length > 0) {
        NSUInteger index = [[NotesManager datasource] indexForNote:note];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self reloadRowsAtIndexPaths:@[indexPath] forTableView:self.tableView];
    } else {
        [self removeNoteIfEmptyAndUpdateView:note];
    }
}

- (void)notesEditViewController:(NotesEditViewController *)notesEditViewController
                receivedNewNote:(Note *)newNote
               toReplaceOldNote:(Note *)oldNote {
    NSUInteger index = [[NotesManager datasource] indexForNote:oldNote];
    if (index != NSNotFound) {
        [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] forTableView:self.tableView];
    }
    
    if (newNote == oldNote) {
        return;
    }
    [self removeNoteIfEmptyAndUpdateView:oldNote];
}

- (void)removeNoteIfEmptyAndUpdateView:(Note *)note {
    if (note.title.length > 0 || note.content.length > 0) {
        return;
    }
    
    NSUInteger index = [[NotesManager datasource] indexForNote:note];
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([[NotesManager datasource] removeNote:note]) {
            [self deleteRowsAtIndexPaths:@[indexPath] forTableView:self.tableView];
            NSInteger count = [[NotesManager datasource] countNotes];
            if (count > 0) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
                [self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                if (self.delegate) {
                    Note *newNote = [[NotesManager datasource] noteAtIndex:newIndexPath.row];
                    [self.delegate notesTableViewController:self didFocusOnNote:newNote];
                }
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EmptyNotesNotification" object:nil];
            }
        }
    }
}

#pragma mark - NotesStartViewControllerDelegate

- (void)didRequestNewNoteFromNotesStartViewController:(NotesStartViewController *)notesStartViewController {
    Note *note = [self createNewNoteAndInsertToView];
    NSLog(@"%@", self.delegate);
    if (self.delegate) {
        [self.delegate notesTableViewController:self requestToEditNote:note];
    }
}


#pragma mark - Button targets

- (void)createNoteButtonFired:(UIBarButtonItem *)sender {
    Note *note = [self createNewNoteAndInsertToView];
    if (self.delegate) {
        [self.delegate notesTableViewController:self requestToEditNote:note];
    }
}

#pragma mark - Misc

- (Note *)createNewNoteAndInsertToView {
    Note *note = [[NotesManager datasource] initializeNewNote];
    if ([[NotesManager datasource] insertNote:note]) {
        NSUInteger index = [[NotesManager datasource] indexForNote:note];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self insertRowsAtIndexPaths:@[indexPath] forTableView:self.tableView];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (self.delegate) {
            [self.delegate notesTableViewController:self didFocusOnNote:note];
        }
    }
    return note;
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths forTableView:(UITableView *)tableView {
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths forTableView:(UITableView *)tableView {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths forTableView:(UITableView *)tableView {
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

@end
