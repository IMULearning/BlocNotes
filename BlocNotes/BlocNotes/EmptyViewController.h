//
//  EmptyViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-15.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotesListViewController;

@interface EmptyViewController : UIViewController

@property (nonatomic, weak) NotesListViewController *owner;

@end
