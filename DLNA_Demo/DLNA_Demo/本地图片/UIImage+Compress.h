//
//  UIImage+Compress.h
//  DLNA_Demo
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Compress)
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength;
+(UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;
@end

NS_ASSUME_NONNULL_END
