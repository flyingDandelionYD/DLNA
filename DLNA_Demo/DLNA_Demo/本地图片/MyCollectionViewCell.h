//
//  MyCollectionViewCell.h
//  DLNA_Demo
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PHAsset;
@interface MyCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong)UIImageView  *imageV;
-(void)makeAsset:(PHAsset*)asset withSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
