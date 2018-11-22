//
//  JFOutlineViewController.h
//  PDFDemo
//
//  Created by Japho on 2018/11/13.
//  Copyright © 2018 Japho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JFOutlineViewController;

@protocol JFOutlineViewControllerDelegate <NSObject>


/**
 did select outline delegate

 @param controller controller
 @param outline outline
 */
- (void)outlineViewController:(JFOutlineViewController *)controller didSelectOutline:(PDFOutline *)outline;

@end

@interface JFOutlineViewController : UIViewController

@property (nonatomic, strong) PDFOutline *outlineRoot;
@property (nonatomic, weak) id<JFOutlineViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
