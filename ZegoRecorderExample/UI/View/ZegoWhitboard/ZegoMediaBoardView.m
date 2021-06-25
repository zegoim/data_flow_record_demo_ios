//
//  ZegoMediaBoardView.m
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/27.
//

#import "ZegoMediaBoardView.h"

@interface ZegoMediaBoardView()<ZegoWhiteboardViewDelegate>

@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation ZegoMediaBoardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if(CGRectEqualToRect(frame, self.frame)) return;
    [super setFrame:frame];
    [self addWhiteboardView:_whiteboardView];
}

#pragma mark - public

- (void)setWhiteboardView:(ZegoWhiteboardView *)whiteboardView
{
    _whiteboardView = whiteboardView;
    [self addWhiteboardView:whiteboardView];
}

//添加白板view。开始加载
- (void)addWhiteboardView:(ZegoWhiteboardView *)whiteboardView {
    if (!whiteboardView || self.frame.size.width <= 0 || self.frame.size.height <= 0 || self.isLoaded) return;
    
    whiteboardView.whiteboardViewDelegate = self;
    //加载文件视图
    @weakify(self)
    [self loadDocsViewWithComplement:^{
        @strongify(self)
        [whiteboardView setWhiteboardOperationMode:ZegoWhiteboardOperationModeDraw|ZegoWhiteboardOperationModeZoom];
        //文件视图需要展示在白板视图下方，所以要在文件视图装载完成后再添加白板视图
        [self addSubview:whiteboardView];
        // 是由 设定的白板宽高比，根据给定的父视图 计算出白板视图的实际frame
        [self layoutWhiteboardView:whiteboardView docsView:self.docsView];
        self.isLoaded = YES;
    }];
}

- (void)removeFromSuperview{
  
    [self removeWhiteboardViewAndDocsView];
    [super removeFromSuperview];
}

- (void)removeWhiteboardViewAndDocsView
{
    if (_whiteboardView) {
        [_whiteboardView removeLaser];
        [_whiteboardView removeFromSuperview];
        _whiteboardView.whiteboardViewDelegate = nil;
        _whiteboardView = nil;
    }
    if (_docsView) {
        [_docsView removeFromSuperview];
        _docsView.delegate = nil;
        _docsView = nil;
    }
}

#pragma mark - private
- (void)loadDocsViewWithComplement:(void(^)(void))complement {
    
    if(self.docsView) return;
    
    self.whiteboardView.backgroundColor = [UIColor whiteColor];

    if (self.whiteboardView.whiteboardModel.fileInfo.fileID.length > 0) {
        DLog(@"正在加载文件ID  %@",self.whiteboardView.whiteboardModel.fileInfo.fileID);
        [ZegoProgessHUD showIndicatorHUDText:@"正在加载文件中" onView:self];
        ZegoDocsView * docsView = [[ZegoDocsView alloc] initWithFrame:self.bounds];
        self.docsView = docsView;
        __weak ZegoDocsView *weakDocsView = docsView;
        __weak typeof(self) weakSelf = self;
        self. whiteboardView.backgroundColor = [UIColor clearColor];

        [docsView loadFileWithFileID:self.whiteboardView.whiteboardModel.fileInfo.fileID authKey:@"" completionBlock:^(ZegoDocsViewError errorCode) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (errorCode == ZegoDocsViewSuccess) {
                weakDocsView.associatedWhiteboardID = strongSelf.whiteboardView.whiteboardModel.whiteboardID;
                if (weakDocsView && weakDocsView.pageCount > 0) {
                    if (strongSelf.docsView == weakDocsView) {
                        [strongSelf insertSubview:weakDocsView aboveSubview:strongSelf.whiteboardView];
                    }
                }
                //如果登陆房间存在ppt同步信息需要执行同步动画方法
                if (weakDocsView && strongSelf.whiteboardView.whiteboardModel.h5_extra) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakDocsView playAnimation:strongSelf.whiteboardView.whiteboardModel.h5_extra];
                    });
                }
                
                if(weakDocsView){
                    if (weakDocsView.fileType == ZegoDocsViewFileTypeELS) {
                        //切换Excel
                        NSInteger index = [self.docsView.sheetNameList indexOfObject:self.whiteboardView.whiteboardModel.fileInfo.fileName];
                        [weakDocsView switchSheet:(int)index];
                    }
                    [weakSelf onScrollWithHorizontalPercent:weakSelf.whiteboardView.whiteboardModel.horizontalScrollPercent verticalPercent:weakSelf.whiteboardView.whiteboardModel.verticalScrollPercent whiteboardView:weakSelf.whiteboardView];
                }
                [ZegoProgessHUD dismissOnView:weakSelf];
            } else {
                [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"加载文件失败：%lu",(unsigned long)errorCode] onView:self];
                DLog(@"%@", [NSString stringWithFormat:@"加载文件失败：%lu",(unsigned long)errorCode]);
            }
            if (complement) {
                complement();
            }
        }];
    } else {
        if (complement) {
            complement();
        }
    }
}

- (CGRect)rectToAspectFitContainer {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGSize aspectSize = CGSizeMake(16, 9);
    CGFloat aspectWidth = aspectSize.width;
    CGFloat aspectHeight = aspectSize.height;
    
    if (width / height > aspectWidth / aspectHeight) {
        CGFloat viewWidth = aspectWidth * height / aspectHeight;
        return CGRectMake((width - viewWidth) * 0.5, 0, viewWidth, height);
    } else {
        CGFloat viewHeight = aspectHeight * width / aspectWidth;
        return CGRectMake(0, (height - viewHeight) * 0.5, width, viewHeight);
    }
}

- (void)layoutWhiteboardView:(ZegoWhiteboardView *)whiteboardView docsView:(ZegoDocsView *)docsView {
    if (self.isLoaded == NO) {
        return;
    }
    if (docsView) {
        [self layoutWhiteboardView:whiteboardView withDocsView:docsView frame:[self rectToAspectFitContainer]];
    } else {
        whiteboardView.frame = [self rectToAspectFitContainer];
    }
}

- (void)layoutWhiteboardView:(ZegoWhiteboardView *)whiteboardView withDocsView:(ZegoDocsView *)docsView frame:(CGRect)docsViewFrame {
    docsView.frame = docsViewFrame;
    [docsView layoutIfNeeded];  //更新 visibleSize
    CGSize visibleSize = docsView.visibleSize;
    whiteboardView.frame = [self frameWithSize:visibleSize docsViewFrame:docsViewFrame];
    whiteboardView.contentSize = CGSizeMake(roundf(docsView.contentSize.width), roundf(docsView.contentSize.height));
}

// 根据 docsView 的 frame 计算白板的 frame
- (CGRect)frameWithSize:(CGSize)visibleSize docsViewFrame:(CGRect)frame {
    CGFloat x = frame.origin.x + (frame.size.width - visibleSize.width) / 2;
    CGFloat y = frame.origin.y + (frame.size.height - visibleSize.height) / 2;
    return CGRectMake(x, y, visibleSize.width, visibleSize.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutWhiteboardView:self.whiteboardView docsView:self.docsView];
    DLog(@"ZegoMediaBoardView %@",NSStringFromCGRect(self.frame));
}


#pragma mark - ZegoWhiteboardViewDelegate
//本地白板滚动完成回调
- (void)onScrollWithHorizontalPercent:(CGFloat)horizontalPercent
                      verticalPercent:(CGFloat)verticalPercent
                       whiteboardView:(ZegoWhiteboardView *)whiteboardView {
    
    if (isnan(horizontalPercent) || isinf(horizontalPercent) ||
        isnan(verticalPercent) || isinf(verticalPercent)) {
        DLog(@"无效数据，忽略......");
        return;
    }
    
    if (self.docsView) {
        //判断是否是动态PPT,动态PPT 与静态PPT 是不同的加载方式，所以需要区别处理
        if (self.whiteboardView.whiteboardModel.fileInfo.fileType == ZegoDocsViewFileTypeDynamicPPTH5
            || self.whiteboardView.whiteboardModel.fileInfo.fileType == ZegoDocsViewFileTypeCustomH5) {
            if (self.whiteboardView.whiteboardModel.pptStep < 1) {
                return;
            }
            CGFloat yPercent = self.whiteboardView.contentOffset.y / self.whiteboardView.contentSize.height;
            NSInteger pageNo = round(yPercent * self.docsView.pageCount) + 1;
            //同步文件视图内容
            DLog(@"flipPage page %ld step %ld",pageNo,MAX(self.whiteboardView.whiteboardModel.pptStep, 1));
            [self.docsView flipPage:pageNo step:MAX(self.whiteboardView.whiteboardModel.pptStep, 1) completionBlock:^(BOOL isScrollSuccess) {

            }];
        } else {
            [self.docsView scrollTo:verticalPercent completionBlock:^(BOOL isScrollSuccess) {

            }];
        }
    }
}

//白板放大操作回调
- (void)onScaleChangedWithScaleFactor:(CGFloat)scaleFactor
                         scaleOffsetX:(CGFloat)scaleOffsetX
                         scaleOffsetY:(CGFloat)scaleOffsetY
                       whiteboardView:(ZegoWhiteboardView *)whiteboardView {
    //同步文件放大比例
    [self.docsView scaleDocsViewWithScaleFactor:scaleFactor scaleOffsetX:scaleOffsetX scaleOffsetY:scaleOffsetY];
    
}

- (void)dealloc {
    DLog(@" %@ dealloc",self.class);
}
@end
