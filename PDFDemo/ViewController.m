//
//  ViewController.m
//  PDFDemo
//
//  Created by Japho on 2018/11/12.
//  Copyright © 2018 Japho. All rights reserved.
//

#import "ViewController.h"
#import <PDFKit/PDFKit.h>
#import "JFThumbnailViewController.h"
#import "JFOutlineViewController.h"
#import "JFSearchViewController.h"

@interface ViewController () <JFThumbnailViewControllerDelegate,JFOutlineViewControllerDelegate,JFSearchViewControllerDelegate>

@property (nonatomic, strong) PDFView *pdfView;
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, strong) UIView *zoomBaseView;
@property (nonatomic, strong) UIButton *btnZoomIn;
@property (nonatomic, strong) UIButton *btnZoomOut;
@property (nonatomic, assign) BOOL hasDisplay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"PDFDemo";
        
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(menuAction)];
    UIBarButtonItem *changeItem = [[UIBarButtonItem alloc] initWithTitle:@"Change PDF File" style:UIBarButtonItemStylePlain target:self action:@selector(changeAction)];
    
    self.navigationItem.leftBarButtonItem = changeItem;
    self.navigationItem.rightBarButtonItem = menuItem;
    
    [self setupPDFView];
}

- (void)setupPDFView
{
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"swift" ofType:@"pdf"];
    NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath];
    PDFDocument *docunment = [[PDFDocument alloc] initWithURL:pdfUrl];
    
    self.document = docunment;
    
    self.pdfView = [[PDFView alloc] initWithFrame:self.view.bounds];
    self.pdfView.document = docunment;
    self.pdfView.autoScales = YES;
    self.pdfView.userInteractionEnabled = YES;
    self.pdfView.backgroundColor = [UIColor grayColor];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired = 1;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [self.pdfView addGestureRecognizer:singleTapGesture];
    [self.pdfView addGestureRecognizer:doubleTapGesture];
    
    [self.view addSubview:self.pdfView];
    [self.view addSubview:self.zoomBaseView];
    
    self.hasDisplay = YES;
}

#pragma mark - --- JFThumbnailViewController Delegate ---

- (void)thumbnailViewController:(JFThumbnailViewController *)controller didSelectAtIndex:(NSIndexPath *)indexPath
{
    PDFPage *page = [self.document pageAtIndex:indexPath.item];
    [self.pdfView goToPage:page];
}

#pragma mark - --- JFOutlineViewController Delegate ---

- (void)outlineViewController:(JFOutlineViewController *)controller didSelectOutline:(PDFOutline *)outline
{
    NSLog(@"%s",__func__);
    PDFAction *action = outline.action;
    PDFActionGoTo *goToAction = (PDFActionGoTo *)action;
    
    if (goToAction)
    {
        [self.pdfView goToDestination:goToAction.destination];
    }
}

#pragma mark - --- JFSearchViewController Delegate ---

- (void)searchViewController:(JFSearchViewController *)controller didSelectSearchResult:(PDFSelection *)selection
{
    selection.color = [UIColor yellowColor];
    self.pdfView.currentSelection = selection;
    [self.pdfView goToSelection:selection];
}

#pragma mark - --- Customed Action ---

- (void)thumbnailAction
{
    NSLog(@"%s",__func__);
    
    JFThumbnailViewController *thumbnailViewController = [[JFThumbnailViewController alloc] init];
    thumbnailViewController.pdfDocument = self.document;
    thumbnailViewController.delegate = self;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:thumbnailViewController] animated:YES completion:nil];
}

- (void)outlineAction
{
    NSLog(@"%s",__func__);
    
    PDFOutline *outline = self.document.outlineRoot;
    
    if (outline)
    {
        JFOutlineViewController *outlineViewController = [[JFOutlineViewController alloc] init];
        outlineViewController.outlineRoot = outline;
        outlineViewController.delegate = self;
        
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:outlineViewController] animated:YES completion:nil];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Attention" message:@"This pdf do not have outline!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)searchAction
{
    NSLog(@"%s",__func__);
    
    JFSearchViewController *searchViewController = [[JFSearchViewController alloc] init];
    searchViewController.pdfDocment = self.document;
    searchViewController.delegate = self;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:searchViewController] animated:YES completion:nil];
}

- (void)changeAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change a file." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *searchAction = [UIAlertAction actionWithTitle:@"Sample" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"pdf"];
        NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath];
        PDFDocument *docunment = [[PDFDocument alloc] initWithURL:pdfUrl];
        
        self.document = docunment;
        self.pdfView.document = docunment;
        self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit;
    }];
    UIAlertAction *outlineAction = [UIAlertAction actionWithTitle:@"Japanese" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"japanese" ofType:@"pdf"];
        NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath];
        PDFDocument *docunment = [[PDFDocument alloc] initWithURL:pdfUrl];
        
        self.document = docunment;
        self.pdfView.document = docunment;
        self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit;
    }];
    UIAlertAction *thumbAction = [UIAlertAction actionWithTitle:@"Swift" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"swift" ofType:@"pdf"];
        NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath];
        PDFDocument *docunment = [[PDFDocument alloc] initWithURL:pdfUrl];
        
        self.document = docunment;
        self.pdfView.document = docunment;
        self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit;
    }];
    
    [alertController addAction:searchAction];
    [alertController addAction:outlineAction];
    [alertController addAction:thumbAction];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)menuAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Menu" message:@"Select an action." preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *searchAction = [UIAlertAction actionWithTitle:@"Search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self searchAction];
    }];
    UIAlertAction *outlineAction = [UIAlertAction actionWithTitle:@"Outline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self outlineAction];
    }];
    UIAlertAction *thumbAction = [UIAlertAction actionWithTitle:@"Thumbnail" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self thumbnailAction];
    }];
    
    [alertController addAction:searchAction];
    [alertController addAction:outlineAction];
    [alertController addAction:thumbAction];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)singleTapAction
{
    NSLog(@"%s",__func__);

    if (self.hasDisplay)
    {
        self.zoomBaseView.hidden = NO;
        self.zoomBaseView.alpha = 1.0;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomBaseView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.zoomBaseView.hidden = YES;
        }];
    }
    else
    {
        self.zoomBaseView.hidden = NO;
        self.zoomBaseView.alpha = 0.0;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.zoomBaseView.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.zoomBaseView.hidden = NO;
        }];
    }
    
    self.hasDisplay = !self.hasDisplay;
}

- (void)doubleTapAction
{
    NSLog(@"%s",__func__);
    
    NSLog(@"%f",self.pdfView.scaleFactorForSizeToFit);
    
    if (self.pdfView.scaleFactor == self.pdfView.scaleFactorForSizeToFit)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit * 4;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit;
        }];
    }
}

- (void)zoomInAction
{
    NSLog(@"%s",__func__);
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.pdfView zoomIn:nil];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)zoomOutAction
{
    NSLog(@"%s",__func__);
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.pdfView zoomOut:nil];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - --- setter & getter ---

- (UIView *)zoomBaseView
{
    if (!_zoomBaseView)
    {
        UIColor *blueColor = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:251/255.0 alpha:1.0];
        
        _zoomBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 100)];
        _zoomBaseView.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.height - [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom - 80);
        _zoomBaseView.backgroundColor = [UIColor whiteColor];
        
        _btnZoomIn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnZoomIn.frame = CGRectMake(0, 0, 40, 50);
        _btnZoomIn.layer.borderWidth = 1;
        _btnZoomIn.layer.borderColor = blueColor.CGColor;
        [_btnZoomIn setTitle:@"+" forState:UIControlStateNormal];
        [_btnZoomIn setTitleColor:blueColor forState:UIControlStateNormal];
        [_btnZoomIn.titleLabel setFont:[UIFont systemFontOfSize:25]];
        [_btnZoomIn addTarget:self action:@selector(zoomInAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_zoomBaseView addSubview:_btnZoomIn];
        
        _btnZoomOut = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnZoomOut.frame = CGRectMake(0, 50, 40, 50);
        _btnZoomOut.layer.borderWidth = 1;
        _btnZoomOut.layer.borderColor = blueColor.CGColor;
        [_btnZoomOut setTitle:@"-" forState:UIControlStateNormal];
        [_btnZoomOut setTitleColor:blueColor forState:UIControlStateNormal];
        [_btnZoomOut.titleLabel setFont:[UIFont systemFontOfSize:25]];
        [_btnZoomOut addTarget:self action:@selector(zoomOutAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_zoomBaseView addSubview:_btnZoomOut];
    }
    
    return _zoomBaseView;
}

@end
