//
//  JFSearchViewController.h
//  PDFDemo
//
//  Created by Japho on 2018/11/14.
//  Copyright © 2018 Japho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JFSearchViewController;

@protocol JFSearchViewControllerDelegate <NSObject>


/**
 did select search result delegate

 @param controller controller
 @param selection selection
 */
- (void)searchViewController:(JFSearchViewController *)controller didSelectSearchResult:(PDFSelection *)selection;

@end

@interface JFSearchViewController : UIViewController

@property (nonatomic, strong) PDFDocument *pdfDocment;
@property (nonatomic, weak) id<JFSearchViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
