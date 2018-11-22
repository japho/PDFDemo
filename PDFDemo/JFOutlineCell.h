//
//  JFOutlineCell.h
//  PDFDemo
//
//  Created by Japho on 2018/11/13.
//  Copyright © 2018 Japho. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JFOutlineButtonBlock)(UIButton *button);

@interface JFOutlineCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffset;
@property (weak, nonatomic) IBOutlet UIButton *btnArrow;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPage;
@property (nonatomic, copy) JFOutlineButtonBlock outlineBlock;

@end

NS_ASSUME_NONNULL_END
