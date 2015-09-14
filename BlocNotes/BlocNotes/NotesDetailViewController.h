//
//  NotesDetailViewController.h
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NotesDetailViewController : UIViewController

@property (nonatomic, strong, readonly) Note *note;

- (instancetype)initWithNote:(Note *)note;

@end
