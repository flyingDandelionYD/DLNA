//
//  MyCollectionViewCell.m
//  DLNA_Demo
//


#import "MyCollectionViewCell.h"
#import <Photos/Photos.h>


@implementation MyCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageV = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        self.imageV.contentMode = UIViewContentModeScaleAspectFill;
        self.imageV.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageV];
    }
    return self;
}
-(void)makeAsset:(PHAsset*)asset withSize:(CGSize)size{
    if(CGSizeEqualToSize(size,CGSizeZero)){
        size =  PHImageManagerMaximumSize;
//        size = CGSizeMake(512, 512);
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
    }

    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:size
                                              contentMode:PHImageContentModeDefault
                                                  options:options
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                weakSelf.imageV.image = result;
                                            }];
}
@end
