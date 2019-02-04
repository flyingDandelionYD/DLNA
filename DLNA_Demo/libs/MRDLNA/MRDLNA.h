//
//  MRDLNA.h
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"
#import "CLUPnPDevice.h"

@protocol DLNADelegate <NSObject>

@optional
/**
 DLNA局域网搜索设备结果
 @param devicesArray <CLUPnPDevice *> 搜索到的设备
 */
- (void)searchDLNAResult:(NSArray *)devicesArray;


/**
 投屏成功开始播放
 */
- (void)dlnaStartPlay;


/**
 获取音量回调
 */
-(void)dlnaRetuenedvolume:(NSString *)volume;


/**
 播放进度的回调
 */
-(void)dlnaBroadcastProgress:(NSString*)progress;


/**
 结束搜索
 */
-(void)dlnaDidEndSearch;

@end

@interface MRDLNA : NSObject

@property(nonatomic,weak)id<DLNADelegate> delegate;

@property(nonatomic, strong) CLUPnPDevice *device;

@property(nonatomic,copy) NSString *playUrl;

@property(nonatomic,assign) NSInteger searchTime;

/**typeStr:1 图片 typeStr：2 视频 */
@property (nonatomic,strong)NSString  *typeStr;

/**
 单例
 */
+(instancetype)sharedMRDLNAManager;

/**
 搜设备
 */
- (void)startSearch;

/**
 DLNA投屏
 */
- (void)startDLNA;
/**
 DLNA投屏(首先停止)---投屏不了可以使用这个方法
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop;

/**
 退出DLNA
 */
- (void)endDLNA;

/**
 播放
 */
- (void)dlnaPlay;

/**
 暂停
 */
- (void)dlnaPause;

/**
 设置音量 volume建议传0-100之间字符串
 */
- (void)volumeChanged:(NSString *)volume;


/**
 设置音量 加减固定的值
 */
-(void)volumeJumpValue:(NSInteger)jumpVolume;

/**
 设置播放进度 seek单位是秒
 */
- (void)seekChanged:(NSInteger)seek;


/**
 设置快进/退 几秒
 */
-(void)dlnaJump:(float)jumpTime;


/**
 播放切集
 */
- (void)playTheURL:(NSString *)url;


/**
 获取音量
 */
-(void)dlnaGetVolume;


/**
 销毁单例
 */
+(void)destory;


@end
