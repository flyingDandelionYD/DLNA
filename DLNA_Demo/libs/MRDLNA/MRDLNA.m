//
//  MRDLNA.m
//  MRDLNA
//
//  Created by MccRee on 2018/5/4.
//

#import "MRDLNA.h"
#import "StopAction.h"
#import <SVProgressHUD.h>

@interface MRDLNA()<CLUPnPServerDelegate, CLUPnPResponseDelegate>

@property(nonatomic,strong) CLUPnPServer *upd;              //MDS服务器
@property(nonatomic,strong) NSMutableArray *dataArray;

@property(nonatomic,strong) CLUPnPRenderer *render;         //MDR渲染器
@property(nonatomic,copy) NSString *volume;
@property(nonatomic,assign) NSInteger seekTime;
@property(nonatomic,assign) BOOL isPlaying;
@property(nonatomic,assign) BOOL isJump;
@property (nonatomic,assign)float  jumpTime;
@end

@implementation MRDLNA

static MRDLNA *instance = nil;
static dispatch_once_t once;

+ (MRDLNA *)sharedMRDLNAManager{
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.upd = [CLUPnPServer shareServer];
        self.upd.searchTime = 5;
        self.upd.delegate = self;
        self.dataArray = [NSMutableArray array];
    }
    return self;
}

/**
 ** DLNA投屏
 */
- (void)startDLNA{
    [self initCLUPnPRendererAndDlnaPlay];//初始化CLUPnPRenderer
}
/**
 ** DLNA投屏
 ** 【流程: 停止 ->设置代理 ->设置Url -> 播放】
 */
- (void)startDLNAAfterStop{
    StopAction *action = [[StopAction alloc]initWithDevice:self.device Success:^{
        [self initCLUPnPRendererAndDlnaPlay];
        
    } failure:^{
        [self initCLUPnPRendererAndDlnaPlay];
    }];
    [action executeAction];
}
/**
 初始化CLUPnPRenderer
 */
-(void)initCLUPnPRendererAndDlnaPlay{
    self.render = [[CLUPnPRenderer alloc] initWithModel:self.device];
    self.render.delegate = self;
    [self.render setAVTransportURL:self.playUrl WithType:self.typeStr];//self.playUrl -- 播放的url
}
/**
 退出DLNA
 */
- (void)endDLNA{
    [self.render stop];
}

/**
 播放
 */
- (void)dlnaPlay{
    [self.render play];
}


/**
 暂停
 */
- (void)dlnaPause{
    [self.render pause];
}

/**
 搜设备
 */
- (void)startSearch{
    [self.upd start];
}

/**
 获取音量
 */
-(void)dlnaGetVolume{
    if(self.render){
        [self.render getVolume];
    }
}


/**
 设置音量
 */
- (void)volumeChanged:(NSString *)volume{
    self.volume = volume;
    [self.render setVolumeWith:volume];
}

/**
 设置音量 加减固定的值
 */
-(void)volumeJumpValue:(NSInteger)jumpVolume{
    NSInteger currentVolume = [self.volume intValue];
    currentVolume+=jumpVolume;
    if(currentVolume<=0) currentVolume = 0;
    if(currentVolume>=100) currentVolume = 100;
    self.volume = [NSString stringWithFormat:@"%ld",(long)currentVolume];
    [self.render setVolumeWith:self.volume];
}


/**
 设置播放进度
 */
- (void)seekChanged:(NSInteger)seek{
    self.seekTime = seek;
    NSString *seekStr = [self timeFormatted:seek];
    [self.render seekToTarget:seekStr Unit:unitREL_TIME];
}


/**
 设置快进/退 几秒
 */
-(void)dlnaJump:(float)jumpTime{
    _jumpTime = jumpTime;
    _isJump =  YES;
    [self.render getPositionInfo];
}

/**
 播放进度单位转换成string
 */
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

/**
 播放切集
 */
- (void)playTheURL:(NSString *)url{
    self.playUrl = url;
    [self.render setAVTransportURL:url WithType:self.typeStr];
}

#pragma mark -- 搜索协议CLUPnPDeviceDelegate回调
- (void)upnpSearchChangeWithResults:(NSArray<CLUPnPDevice *> *)devices{
    NSMutableArray *deviceMarr = [NSMutableArray array];
    NSLog(@"devices-->%@",devices);
    for (CLUPnPDevice *device in devices) {
        // 只返回匹配到视频播放的设备
        if ([device.uuid containsString:serviceType_AVTransport]) {
            [deviceMarr addObject:device];
        }
    }
    if ([self.delegate respondsToSelector:@selector(searchDLNAResult:)]) {
        [self.delegate searchDLNAResult:[deviceMarr copy]];
    }
    self.dataArray = deviceMarr;
}

- (void)upnpSearchErrorWithError:(NSError *)error{
//    NSLog(@"DLNA_Error======>%@", error);
}

-(void)didEndSearch{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dlnaDidEndSearch)]){
        [self.delegate dlnaDidEndSearch];
    }
}

#pragma mark - CLUPnPResponseDelegate
- (void)upnpSetAVTransportURIResponse{
    [self.render play];
}

- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info{
//    NSLog(@"%@ === %@", info.currentTransportState, info.currentTransportStatus);
    if (!([info.currentTransportState isEqualToString:@"PLAYING"] || [info.currentTransportState isEqualToString:@"TRANSITIONING"])) {
        [self.render play];
    }
}

- (void)upnpPlayResponse{
    if ([self.delegate respondsToSelector:@selector(dlnaStartPlay)]) {
        [self.delegate dlnaStartPlay];
    }
}

//获取音量的回调
-(void)upnpGetVolumeResponse:(NSString *)volume{
    if([self.delegate respondsToSelector:@selector(dlnaRetuenedvolume:)]){
        [self.delegate dlnaRetuenedvolume:volume];
    }
}

//获取视频现在的播放进度的回调(里面有播放的总时间哟)
-(void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
    if(_isJump){
        [self.render seek:info.relTime+(_jumpTime)];
        _isJump = NO;
        _jumpTime = 0;
    }
}

//errorDomain报错
-(void)upnpErrorDomain:(NSError *)error{
    NSLog(@"网络发生错误啦");
    [SVProgressHUD showInfoWithStatus:@"投屏失败，请确保有网或者要在同一个局域网内哟"];
}

#pragma mark Set&Get
- (void)setSearchTime:(NSInteger)searchTime{
    _searchTime = searchTime;
    self.upd.searchTime = searchTime;
}


+(void)destory{
    once = 0;
    instance = nil;
}

@end
