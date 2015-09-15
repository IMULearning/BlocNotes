//
//  NotesListViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmptyViewController.h"

@interface NotesListViewController : UITableViewController

@property (nonatomic, strong) EmptyViewController *emptyVC;

- (void)createNoteButtonFired:(id)sender;

@end
