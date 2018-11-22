## 前言

2017年夏天，在苹果全球开发者大会（WWDC）上，苹果公司终于推出了针对于 iOS 的 PDFKit 支持。PDFKit 自从 MacOS 10.4 以来一直在 AppKit for MacOS 中。但 UIKit 却迟迟得不到支持，尽管苹果公司之前在 iBooks 和 Mail 中使用过 PDFKit ， 但是该框架并未向开发人员开房。

PDFKit 包含了大量关于 PDF 相关的功能，例如，打开，修改，绘图和保存 PDF ，也包含了搜索文本。在 iOS 11 后，苹果终于开放了 PDFKit 。目前（虽然离 PDFKit 发布已经过了一年多），但是目前中文资料和 Demo 确实比较少，下面笔者就带着大家简单的了解一下 PDFKit。

![](https://ws1.sinaimg.cn/large/006tNbRwly1fxfu2iy4ydj30m80ct43b.jpg)

## 核心功能

主要核心功能如下：

**PDFView**

- 用于显示 PDF ，包括选择的内容，导航，缩放等功能。

**PDFDocument**

- 表示允许您写入、搜索和选择PDF数据的PDF数据或文件。

**PDFPage**

- 呈现PDF数据，添加注释，获取页面文本等等。

**PDFAnnotation**

- PDF 中的附加内容，包括注释、链接、表单等。

## 实现一个简单的 PDF 阅读器

让我看到你们的双手， put your hands up!

### 创建 PDFView

引入 `#import <PDFKit/PDFKit.h>` ，创建 PDFView ，创建之前，首先要创建 PDFDocument ，这里通过文件路径 URl 进行创建。

```swift
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"swift" ofType:@"pdf"];
    NSURL *pdfUrl = [NSURL fileURLWithPath:pdfPath];
    PDFDocument *docunment = [[PDFDocument alloc] initWithURL:pdfUrl];
```

创建 PDFView ，将 PDFDucument 对象赋给 PDFView。

```swift
    self.pdfView = [[PDFView alloc] initWithFrame:self.view.bounds];
    self.pdfView.document = docunment;
    self.pdfView.autoScales = YES;
    self.pdfView.userInteractionEnabled = YES;
    self.pdfView.backgroundColor = [UIColor grayColor];
```

至此，就实现了 PDF 的读取及显示。

![](https://ws4.sinaimg.cn/large/006tNbRwly1fxglxqxk7mj30ak0kw0vz.jpg)

### 创建 PDFThumbnail

- PDF 缩略图的创建

首先获取 PDFDocument 的属性 PDFPage ：

```swift
// Returns a PDFPage object representing the page at index. Will raise an exception if index is out of bounds. Indices
// are zero-based.
- (nullable PDFPage *)pageAtIndex:(NSUInteger)index;
```

通过 PDFPage 的对象方法，可以获取 PDF 的缩略图，这里需传入图片的 size：

```swift
// Convenience function that returns an image of this page, with annotations, that fits the given size.
// Note that the produced image is "size to fit": it retains the original page geometry. The size you give
// may not match the size of the returned image, but the returned image is guaranteed to be equal or less.
- (PDFKitPlatformImage *)thumbnailOfSize:(PDFSize)size forBox:(PDFDisplayBox)box PDFKIT_AVAILABLE(10_13, 11_0);
```
创建 collectionViewCell ，通过 collectionView 就可以实现一个大致的功能。

![](https://ws1.sinaimg.cn/large/006tNbRwly1fxgm7307rfj30ak0kw40z.jpg)

**点击跳转**

获取 cell 的点击事件，取出所点击的 PDFPage 对象，用下述方法进行跳转：

```swift
// Scrolls to page.
- (void)goToPage:(PDFPage *)page;
```

### 获取 PDF 的大纲 PDFOutline

PDFOutline 是一个层级关系的对象，他表示 PDF 的大纲（也就是我们常用的书签）。每个 PDFOutline 对象都可通过 `childAtIndex:` 方法获取出他的孩子对象，`注意`，这里需要先判断 `numberOfChildren`，以确定该 outline 对象存在多少个孩子节点，避免下标超界引发的崩溃。

**实现大纲功能**

从 PDFDocument 中获取 PDFOutline

```swift
PDFOutline *outline = self.document.outlineRoot;
```

遍历 outline 孩子节点（默认只遍历一层）

```swift
- (void)setOutlineRoot:(PDFOutline *)outlineRoot
{
    _outlineRoot = outlineRoot;
    
    for (int i = 0; i < outlineRoot.numberOfChildren; i++)
    {
        PDFOutline *outline = [outlineRoot childAtIndex:i];
        outline.isOpen = NO;
        [self.arrData addObject:outline];
    }
    
    [self.tableView reloadData];
}
```
当点击节点时，判断有无孩子节点，进行当前数组的新增或删除。

>**插入节点**
>
>这里只添加孩子节点中一层，不进行递归操作。

```swift
- (void)insertOulineWithParentOutline:(PDFOutline *)parentOutline
{
    NSInteger baseIndex = [self.arrData indexOfObject:parentOutline];
    
    for (int i = 0; i < parentOutline.numberOfChildren; i++)
    {
        PDFOutline *tempOuline = [parentOutline childAtIndex:i];
        tempOuline.isOpen = NO;
        [self.arrData insertObject:tempOuline atIndex:baseIndex + i + 1];
    }
}
```

>**删除节点**
>
>首先判断该节点下有无孩子节点，若无直接返回；
>
>判断每个孩子节点是否还存在孩子节点，若有，则进行递归操作逐一进行删除。
>
>`注意`：此处是为了点击回收父节点时将该父节点下的所有子节点（不论层级）全部删除。

```swift
- (void)removeOutlineWithParentOuline:(PDFOutline *)parentOutline
{
    if (parentOutline.numberOfChildren <= 0)
    {
        return;
    }
    
    for (int i = 0; i < parentOutline.numberOfChildren; i++)
    {
        PDFOutline *node = [parentOutline childAtIndex:i];
        
        if (node.numberOfChildren > 0 && node.isOpen)
        {
            [self removeOutlineWithParentOuline:node];
            
            NSInteger index = [self.arrData indexOfObject:node];
            
            if (index)
            {
                [self.arrData removeObjectAtIndex:index];
            }
        }
        else
        {
            if ([self.arrData containsObject:node])
            {
                NSInteger index = [self.arrData indexOfObject:node];
                
                if (index)
                {
                    [self.arrData removeObjectAtIndex:index];
                }
            }
        }
    }
}
```

>**判断节点深度，一遍设置显示偏移量**

```swift
- (NSInteger)findDepthWithOutline:(PDFOutline *)outline
{
    NSInteger depth = -1;
    PDFOutline *tempOutline = outline;
    
    while (tempOutline.parent != nil)
    {
        depth++;
        tempOutline = tempOutline.parent;
    }
    
    return depth;
}
```

![](https://ws1.sinaimg.cn/large/006tNbRwly1fxgo40qbtnj30ak0kw3zy.jpg)

### 实现 PDF 搜索功能

这里搜索功能主要靠下述方法实现

```swift
// Begins a find, searching the document for string.  Search results are handled via a 
// PDFDocumentDidFindMatchNotification or if the delegate implements -[didMatchString:]. Supported options are: 
// NSCaseInsensitiveSearch, NSLiteralSearch, and NSBackwardsSearch.
- (void)beginFindString:(NSString *)string withOptions:(NSStringCompareOptions)options;
```
调用此方法之前，首先需将 PDFDocument 设置代理，通过 PDFDocument 的代理进行回调。获取 PDFSelection 对象，

```swift
#pragma mark - --- PDFDocument Delegate ---

- (void)didMatchString:(PDFSelection *)instance
{
    [self.arrData addObject:instance];
    [self.tableView reloadData];
}
```

再根据 selection 对象显示搜索内容。

![](https://ws2.sinaimg.cn/large/006tNbRwly1fxgoiwncwuj30ak0kwgpp.jpg)

### PDF 缩放功能

调用下述方法即可对 PDFView 进行缩放，

```swift
// Zooming changes the scaling by root-2.
- (IBAction)zoomIn:(nullable id)sender;
@property (nonatomic, readonly) BOOL canZoomIn;

- (IBAction)zoomOut:(nullable id)sender;
@property (nonatomic, readonly) BOOL canZoomOut;
```

**实现双击缩放或还原：**

这里通过设置 pdfView 的 scaleFactor 属性即可实现，`注意`：`scaleFactorForSizeToFit`属性是当前 PDF 充满屏幕的比例。

```swift
- (void)doubleTapAction
{   
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
```

## Demo

GitHub : [https://github.com/japho/PDFDemo](https://github.com/japho/PDFDemo)

本文作者：[Japho](https://japho.top)

本文原地址：[https://japho.top/2018/11/21/guideline-of-pdfkit/](https://japho.top/2018/11/21/guideline-of-pdfkit/)

**未经本人同意请勿擅自转载，转载请注明出处。**
