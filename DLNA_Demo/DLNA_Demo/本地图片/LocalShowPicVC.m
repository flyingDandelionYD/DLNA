//
//  LocalShowPicVC.m
//  DLNA_Demo
//


#import "LocalShowPicVC.h"
#import "MyCollectionViewCell.h"

#import <GCDWebServer/GCDWebDAVServer.h>
#import "GCDWebServerDataResponse.h"
#import  <GCDWebServer/GCDWebServerFileResponse.h>
#import "MRDLNA.h"
#import <Photos/Photos.h>
#import "UIImage+Compress.h"

@interface LocalShowPicVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,GCDWebDAVServerDelegate>{
    UICollectionView *mainCollectionView;
}
@property (nonatomic, strong) GCDWebDAVServer* davServer;
@property(nonatomic,strong) MRDLNA *dlnaManager;
@property (nonatomic,strong)NSData  *imageData;
@property (nonatomic,assign)NSUInteger  limitLength;
@end

@implementation LocalShowPicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.limitLength = 1024*1024*10;
    self.title = @"本地图片投屏";
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeColV];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self makeServer];
}

-(void)makeColV{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing =  0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize =CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-88);
    mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    mainCollectionView.backgroundColor = [UIColor whiteColor];
    mainCollectionView.pagingEnabled = YES;
    mainCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:mainCollectionView];
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    [mainCollectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"LocalPicturesVC"];
    [mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assetsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *cell =(MyCollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalPicturesVC" forIndexPath:indexPath];
    [cell makeAsset:self.assetsArr[indexPath.row] withSize:CGSizeZero];
    return cell;
}
//===============================
//开启服务器
-(void)makeServer{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.davServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:documentsPath];
    self.davServer.delegate =  self;
    __weak typeof (self) weakSelf = self;
    [self.davServer  addHandlerForMethod:@"GET" pathRegex:@"myImage" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithData:weakSelf.imageData contentType:@"image/jpeg"];
        completionBlock(response);
    }];
    [self.davServer start];
}

-(void)webServerDidStart:(GCDWebServer *)server{
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.typeStr = @"1";
    self.dlnaManager.playUrl = [NSString stringWithFormat:@"%@myImage",self.davServer.serverURL.absoluteString];
    [self scrollViewDidEndScroll];
    [self.dlnaManager startDLNA];
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll];
        }
    }
}


#pragma mark - scrollView 滚动停止
- (void)scrollViewDidEndScroll {
    MyCollectionViewCell *cell  = [mainCollectionView visibleCells].firstObject;
    self.imageData  = [cell.imageV.image compressWithMaxLength:self.limitLength];
    [self.dlnaManager playTheURL:self.dlnaManager.playUrl];
}

-(void)dealloc{
    [self.davServer stop];
    self.davServer = nil;
    [self.dlnaManager endDLNA];
    NSLog(@"%s",__FUNCTION__);
}
@end
