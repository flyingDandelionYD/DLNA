//
//  LocalPicturesVC.m
//  DLNA_Demo
//


#import "LocalPicturesVC.h"
#import <Photos/Photos.h>
#import "MyCollectionViewCell.h"
#import "LocalShowPicVC.h"

@interface LocalPicturesVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    UICollectionView *mainCollectionView;
}
@property (nonatomic,strong)NSArray *localPicsArr;
@end

@implementation LocalPicturesVC

-(NSArray*)localPicsArr{
    if(_localPicsArr==nil){
        _localPicsArr = [NSArray  array];
    }
    return _localPicsArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地图片的投屏";
    self.view.backgroundColor =[UIColor whiteColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getAllPicturesForLocalShow];
        [self->mainCollectionView reloadData];
    });
    [self makeColV];
}

//获取所有图片
- (void)getAllPicturesForLocalShow {
    PHFetchOptions *allOptions = [[PHFetchOptions alloc]init];
    allOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allPics= [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allOptions];
    NSMutableArray *tempArr = [NSMutableArray array];
    for(PHAsset *asset in allPics){
        [tempArr addObject:asset];
    }
    self.localPicsArr = tempArr.copy;
}

-(void)makeColV{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize =CGSizeMake(([UIScreen mainScreen].bounds.size.width-3)*0.25,([UIScreen mainScreen].bounds.size.width-3)*0.25);
    mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    mainCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mainCollectionView];
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    [mainCollectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"LocalPicturesVC"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
     return self.localPicsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionViewCell *cell =(MyCollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"LocalPicturesVC" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(MyCollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell makeAsset:self.localPicsArr[indexPath.row] withSize:CGSizeMake(128, 128)];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LocalShowPicVC *vc = [[LocalShowPicVC alloc]init];
    vc.currentIndex = indexPath.item;
    vc.assetsArr = self.localPicsArr;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
