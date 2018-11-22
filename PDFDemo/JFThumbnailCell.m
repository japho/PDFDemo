//
//  JFThumbnailCell.m
//  PDFDemo
//
//  Created by Japho on 2018/11/12.
//  Copyright © 2018 Japho. All rights reserved.
//

#import "JFThumbnailCell.h"

@interface JFThumbnailCell ()

@end

@implementation JFThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    CGFloat cellWidth = floor(([UIScreen mainScreen].bounds.size.width - 10 * 4) / 3.0);
    CGFloat cellHeight = cellWidth * 1.5;
    
    _imgViewThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
    _imgViewThumb.userInteractionEnabled = YES;
    
    [self addSubview:_imgViewThumb];
    
    _lblPage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    _lblPage.center = CGPointMake(cellWidth / 2, cellHeight - 20);
    _lblPage.textColor = [UIColor whiteColor];
    _lblPage.textAlignment = NSTextAlignmentCenter;
    _lblPage.layer.cornerRadius = 2;
    _lblPage.layer.masksToBounds = YES;
    _lblPage.backgroundColor = [UIColor blackColor];
    
    [self addSubview:_lblPage];
}


@end
