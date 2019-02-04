//
//  LocalShowVideoVC.h
//  DLNA_Demo
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalShowVideoVC : UIViewController
@property (nonatomic, strong) NSArray *localFiles;
@property (nonatomic, assign) NSInteger fileIndex;
@end

NS_ASSUME_NONNULL_END
