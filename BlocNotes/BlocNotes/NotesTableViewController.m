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
#import <ReactiveCocoa.h>
#import "NotificationNames.h"

#define CELL_ID @"cell"

@interface NotesTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UIBarButtonItem *createNoteButton;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation NotesTableViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView registerClass:[NotesTableViewCell class] forCellReuseIdentifier:CELL_ID];
    
    [self configureSearchBar];
    [self configureNavigationBar];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![self.tableView indexPathForSelectedRow]) {
        [self selectFirstItem];
    }
    
    [super viewWillAppear:animated];
}

#pragma mark - Setup

- (void)configureNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"BlocNotes", @"BlocNotes");
    self.createNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(createNoteButtonFired:)];
    self.navigationItem.rightBarButtonItem = self.createNoteButton;
}

- (void)configureSearchBar {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.scopeButtonTitles = [NotesManager searchScopes];
    self.searchController.searchBar.delegate = self;
    
    UITextField *searchTextField = [self.searchController.searchBar valueForKey:@"_searchField"];
    [[[searchTextField rac_textSignal] throttle:0.2] subscribeNext:^(id x) {
        NSString *scope = [NotesManager searchScopes][self.searchController.searchBar.selectedScopeButtonIndex];
        [self searchNotesWithText:x forScope:scope];
    }];
}

- (void) registerNotifications {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DATASOURCE_DID_INSERT object:nil] subscribeNext:^(id x) {
        [self didReceiveNotificationOnNoteCreation:x];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DATASOURCE_DID_UPDATE object:nil] subscribeNext:^(id x) {
        [self didReceiveNotificationOnNoteUpdate:x];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DATASOURCE_DID_REMOVE object:nil] subscribeNext:^(id x) {
        [self didReceiveNotificationOnNoteRemoval:x];
    }];
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
    if (self.delegate) {
        Note *note = [[NotesManager datasource] noteAtIndex:indexPath.row];
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
    if (note) {
        [[NotesManager datasource] removeNote:note];
    }
}

#pragma mark - NotesEditViewControllerDelegate

- (void)notesEditViewController:(NotesEditViewController *)notesEditViewController didFinishWithNote:(Note *)note {
    [self removeNoteIfEmpty:note];
}

/* Deprecated */
- (void)notesEditViewController:(NotesEditViewController *)notesEditViewController
                receivedNewNote:(Note *)newNote
               toReplaceOldNote:(Note *)oldNote {
    if (newNote == oldNote) {
        return;
    }
}

- (void)removeNoteIfEmpty:(Note *)note {
    if (note.title.length > 0 || note.content.length > 0) {
        return;
    }
    
    [[NotesManager datasource] removeNote:note];
}

#pragma mark - Note creation (NotesStartViewControllerDelegate, Button targets)

- (void)didRequestNewNoteFromNotesStartViewController:(NotesStartViewController *)notesStartViewController {
    Note *newNote = [[NotesManager datasource] initializeNewNote];
    if ([[NotesManager datasource] insertNote:newNote] && self.delegate) {
        [self.delegate notesTableViewController:self requestToEditNote:newNote];
    }
}

- (void)createNoteButtonFired:(UIBarButtonItem *)sender {
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    if (selectedPath) {
        Note *currentlySelected = [[NotesManager datasource] noteAtIndex:selectedPath.row];
        if (currentlySelected && currentlySelected.title.length == 0 && currentlySelected.content.length == 0) {
            return;
        }
    }
    
    Note *newNote = [[NotesManager datasource] initializeNewNote];
    if ([[NotesManager datasource] insertNote:newNote] && self.delegate) {
        [self.delegate notesTableViewController:self requestToEditNote:newNote];
    }
}

#pragma mark - Datasource notification responders

- (void)didReceiveNotificationOnNoteCreation:(NSNotification *)notification {
    NSNumber *indexNumber = notification.userInfo[@"index"];
    Note *newNote = notification.userInfo[@"note"];
    [self insertTableRowForNote:newNote atIndex:[indexNumber integerValue]];
    [self.tableView selectRowAtIndexPath:[self indexPathForIndex:[indexNumber integerValue]]
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
    if (self.delegate) {
        [self.delegate notesTableViewController:self didFocusOnNote:newNote];
    }
}

- (void)didReceiveNotificationOnNoteUpdate:(NSNotification *)notification {
    NSNumber *indexNumber = notification.userInfo[@"index"];
    Note *note = notification.userInfo[@"note"];
    [self reloadTableRowForNote:note atIndex:[indexNumber integerValue]];
}

- (void)didReceiveNotificationOnNoteRemoval:(NSNotification *)notification {
    NSNumber *indexNumber = notification.userInfo[@"index"];
    Note *noteRemoved = notification.userInfo[@"note"];
    [self deleteTableRowForNote:noteRemoved atIndex:[indexNumber integerValue]];
    
    NSIndexPath *newSelectionPath = [self indexPathForNextSelectionFromRemovalOfRowAtIndex:[indexNumber integerValue]];
    if (newSelectionPath.row != NSNotFound) {
        [self.tableView selectRowAtIndexPath:newSelectionPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (self.delegate) {
            Note *selectedNote = [[NotesManager datasource] noteAtIndex:newSelectionPath.row];
            [self.delegate notesTableViewController:self didFocusOnNote:selectedNote];
        }
    }
}

- (NSIndexPath *)indexPathForNextSelectionFromRemovalOfRowAtIndex:(NSUInteger)removedRowIndex {
    if (removedRowIndex > 0) {
        return [NSIndexPath indexPathForRow:removedRowIndex - 1 inSection:0];
    } else {
        if ([[NotesManager datasource] countNotes] > 0) {
            return [NSIndexPath indexPathForRow:removedRowIndex inSection:0];
        } else {
            return [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        }
    }
}

#pragma mark - Table view cells CRUD

- (void)insertTableRowForNote:(Note *)note atIndex:(NSUInteger)index {
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[self indexPathForIndex:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)reloadTableRowForNote:(Note *)note atIndex:(NSUInteger)index {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForIndex:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)deleteTableRowForNote:(Note *)note atIndex:(NSUInteger)index {
    if ([self.tableView numberOfRowsInSection:0] == 0) {
        return;
    }
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[self indexPathForIndex:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (NSIndexPath *)indexPathForIndex:(NSUInteger) index {
    return [NSIndexPath indexPathForRow:index inSection:0];
}

#pragma mark - Search / UISearchBarDelegate

- (void)searchNotesWithText:(NSString *)text forScope:(NSString *)scope {
    [[NotesManager datasource] loadNotesContainingText:text inScope:scope];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    [self searchNotesWithText:searchTextField.text forScope:[NotesManager searchScopes][selectedScope]];
}

@end
