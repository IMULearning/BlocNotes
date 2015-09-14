//
//  NotesTableViewCell.m
//  BlocNotes
//
//  Created by Weinan Qiu on 2015-09-14.
//  Copyright (c) 2015 Kumiq. All rights reserved.
//

#import "NotesTableViewCell.h"

@interface NotesTableViewCell ()

@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation NotesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createAndConfigureDescriptionLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.descriptionLabel.frame = self.contentView.bounds;
}

- (void)createAndConfigureDescriptionLabel {
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.numberOfLines = 2;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.descriptionLabel];
}

- (void)setNote:(Note *)note {
    _note = note;
    _descriptionLabel.text = _note.description;
}

@end
