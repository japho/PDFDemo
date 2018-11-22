//
//  JFOutlineCell.m
//  PDFDemo
//
//  Created by Japho on 2018/11/13.
//  Copyright © 2018 Japho. All rights reserved.
//

#import "JFOutlineCell.h"

@implementation JFOutlineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.indentationLevel == 0)
    {
        self.lblTitle.font = [UIFont systemFontOfSize:17];
    }
    else
    {
        self.lblTitle.font = [UIFont systemFontOfSize:15];
    }
    
    self.leftOffset.constant = self.indentationWidth * self.indentationLevel;
}

- (IBAction)btnArrowAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;

    if (self.outlineBlock)
    {
        self.outlineBlock(button);
    }
}

@end
