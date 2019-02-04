//
//  RomoteShowVideoVC.m
//  DLNA_Demo
//


#import "RomoteShowVideoVC.h"
#import "MRDLNA.h"
#import <Photos/Photos.h>
#import <SVProgressHUD.h>


@interface RomoteShowVideoVC ()<DLNADelegate>{
    NSInteger _index;
}
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic,strong)NSArray  *videosUrlArr;
@property (nonatomic,strong)MRDLNA  *dlnaManager;
@property (nonatomic,assign)float  totalTime;
@property (nonatomic,assign)NSUInteger  volumeSize;
@end

@implementation RomoteShowVideoVC

-(NSArray*)videosUrlArr{
    if(_videosUrlArr==nil){
        _videosUrlArr = @[
                        @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
                        @"http://www.thxf.gov.cn/vod/gcdr.mp4",
                        ];
    }
    return _videosUrlArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络视频播放";
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.delegate = self;
    self.dlnaManager.typeStr = @"2";
    self.dlnaManager.playUrl = self.videosUrlArr.firstObject;
    [self.dlnaManager startDLNA];
    [self.dlnaManager dlnaGetVolume];
   
}

//上一个
- (IBAction)privious:(id)sender {
    _index--;
    if(_index<0){
        _index = self.videosUrlArr.count-1;
    }
    [self.dlnaManager playTheURL:self.videosUrlArr[_index]];

}

//下一个
- (IBAction)next:(id)sender {
    _index++;
    if(_index>=self.videosUrlArr.count)  _index= 0;
    [self.dlnaManager playTheURL:self.videosUrlArr[_index]];
  
}


//音量-
- (IBAction)volumeReduce:(id)sender {
    [self.dlnaManager volumeJumpValue:-5];
}

//音量+
- (IBAction)volumeAdd:(id)sender {
    [self.dlnaManager volumeJumpValue:5];
}

//播放
- (IBAction)broadcast:(id)sender {
    [self.dlnaManager dlnaPlay];
}

//暂停
- (IBAction)pause:(id)sender {
    [self.dlnaManager dlnaPause];
}

//快退
- (IBAction)quickBack:(id)sender{
    [self.dlnaManager dlnaPlay];
    [self.dlnaManager dlnaJump:-5.0];
}

//快进
- (IBAction)quickGo:(id)sender{
    [self.dlnaManager dlnaPlay];
    [self.dlnaManager dlnaJump:5.0];
}


//静音
- (IBAction)noVolume:(id)sender{
    [SVProgressHUD showInfoWithStatus:@"静音（指令）"];
}

//不静音
- (IBAction)makeVolume:(id)sender{
    [SVProgressHUD showInfoWithStatus:@"不静音（指令）"];
}


//音量控制
- (IBAction)volumeSlider:(UISlider *)sender {
    [self.dlnaManager volumeChanged:[NSString stringWithFormat:@"%.0f",sender.value*100]];
}


//播放进度控制
- (IBAction)broadcastSlider:(UISlider *)sender{
    [self.dlnaManager seekChanged:sender.value*self.totalTime];
}

-(void)dealloc{
    [self.dlnaManager endDLNA];
    NSLog(@"%s",__FUNCTION__);
}

-(void)dlnaStartPlay{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         NSLog(@"时长：%f", [self getVideoTotalTime:self.dlnaManager.playUrl]);
         self.totalTime =  [self getVideoTotalTime:self.dlnaManager.playUrl];
    });
}

-(float)getVideoTotalTime:(NSString*)urlStr{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:urlStr]];
    CMTime   time = [asset duration];
    return  ceil(time.value/time.timescale);
}

- (void)dlnaRetuenedvolume:(NSString *)volume{
    self.volumeSize = [volume intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.volumeSlider setValue:self.volumeSize];
    });
}

@end
