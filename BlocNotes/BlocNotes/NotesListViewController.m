//
//  NotesListViewController.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesListViewController.h"
#import "NotesManager.h"
#import "NotesTableViewCell.h"
#import "NotesDetailViewController.h"

#define CELL_ID @"cell"

@interface NotesListViewController () <NotesDetailViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *createNoteButton;

@end

@implementation NotesListViewController

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - View intialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.tableView registerClass:[NotesTableViewCell class] forCellReuseIdentifier:CELL_ID];
    
    [self configureNavigationBar];
}

- (void)configureNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"BlocNotes", @"BlocNotes");
    
    self.createNoteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNoteButtonFired:)];
    self.navigationItem.rightBarButtonItem = self.createNoteButton;
}

#pragma mark - UITableViewController DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NotesManager datasource] countNotes];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = [[NotesManager datasource] noteAtIndex:indexPath.row];
    [self presentDetailViewControllerWithNote:note];
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
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *note = [[NotesManager datasource] noteAtIndex:indexPath.row];
        if ([[NotesManager datasource] removeNote:note]) {
            [self deleteRowsAtIndexPaths:@[indexPath] forTableView:tableView];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - NotesDetailViewControllerDelegate

- (void)notesDetailViewController:(NotesDetailViewController *)detailViewController didFinishWithNote:(Note *)note {
    NSUInteger index = [[NotesManager datasource] indexForNote:note];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (note.title.length > 0 || note.content.length > 0) {
        [self reloadRowsAtIndexPaths:@[indexPath] forTableView:self.tableView];
    } else {
        if ([[NotesManager datasource] removeNote:note]) {
            [self deleteRowsAtIndexPaths:@[indexPath] forTableView:self.tableView];
        }
    }
}

#pragma mark - Button Targets

- (void)createNoteButtonFired:(UIBarButtonItem *)sender {
    Note *note = [[NotesManager datasource] initializeNewNote];
    if ([[NotesManager datasource] insertNote:note]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self insertRowsAtIndexPaths:@[indexPath] forTableView:self.tableView];
        [self presentDetailViewControllerWithNote:note];
    }
}

#pragma mark - Misc

- (void)presentDetailViewControllerWithNote:(Note *)note {
    NotesDetailViewController *detailVC = [[NotesDetailViewController alloc] initWithNote:note];
    detailVC.delegate = self;
    [self.splitViewController showDetailViewController:detailVC sender:self];
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
