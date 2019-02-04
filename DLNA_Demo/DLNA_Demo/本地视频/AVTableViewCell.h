//
//  AVTableViewCell.h
//  DLNA_Demo
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class AVAsset;
@interface AVTableViewCell : UITableViewCell
+(instancetype)cellWithTableView:(UITableView*)tableView;
-(void) setVideoThumbImage: (AVAsset *)  asset;
@end

NS_ASSUME_NONNULL_END
