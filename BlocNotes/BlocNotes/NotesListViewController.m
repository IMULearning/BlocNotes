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

@interface NotesListViewController () //<UISplitViewControllerDelegate>

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
    
    self.navigationItem.title = NSLocalizedString(@"BlocNotes", @"BlocNotes");
}

#pragma mark - UITableViewController DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NotesManager datasource] countNotes];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = [[NotesManager datasource] noteAtIndex:indexPath.row];
    NotesDetailViewController *detailVC = [[NotesDetailViewController alloc] initWithNote:note];
    [self.splitViewController showDetailViewController:detailVC sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    cell.note = [[NotesManager datasource] noteAtIndex:indexPath.row];
    return cell;
}

@end
