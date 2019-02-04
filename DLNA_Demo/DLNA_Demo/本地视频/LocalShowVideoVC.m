//
//  LocalShowVideoVC.m
//  DLNA_Demo
//


#import "LocalShowVideoVC.h"
#import <GCDWebServer/GCDWebDAVServer.h>
#import "GCDWebServerDataResponse.h"
#import  <GCDWebServer/GCDWebServerFileResponse.h>
#import "MRDLNA.h"
#import <Photos/Photos.h>
#import <SVProgressHUD.h>


@interface LocalShowVideoVC ()<DLNADelegate,GCDWebDAVServerDelegate>{
    NSInteger _index;
}
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (nonatomic,strong)MRDLNA  *dlnaManager;
@property (nonatomic,assign)float  totalTime;
@property (nonatomic,assign)NSUInteger  volumeSize;
@property (nonatomic, strong) GCDWebDAVServer* davServer;
@property (nonatomic,strong)NSString  *currentStr;
@end

@implementation LocalShowVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地视频播放";
    self.currentStr = self.localFiles[self.fileIndex][@"url"];
    [self makeServer];
}

//开启服务器
-(void)makeServer{
    __weak typeof(self)  weakSelf = self;
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.davServer = [[GCDWebDAVServer alloc] initWithUploadDirectory:documentsPath];
    self.davServer.delegate =  self;
    [self.davServer addHandlerForMethod:@"GET" pathRegex:@"/video.mov" requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        GCDWebServerFileResponse *res = [GCDWebServerFileResponse responseWithFile:weakSelf.currentStr byteRange:request.byteRange];
        completionBlock(res);
    }];
    [self.davServer start];
}

-(void)webServerDidStart:(GCDWebServer *)server{
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.delegate = self;
    self.dlnaManager.typeStr = @"2";
    self.dlnaManager.playUrl = [NSString stringWithFormat:@"%@video.mov",self.davServer.serverURL.absoluteString];
    [self.dlnaManager startDLNA];
}



//上一个
- (IBAction)privious:(id)sender {
    _index--;
    if(_index<0){
        _index = self.localFiles.count-1;
    }
    NSDictionary* file = self.localFiles[self.fileIndex];
    self.currentStr = file[@"url"];
    [self.dlnaManager playTheURL:self.dlnaManager.playUrl];
}

//下一个
- (IBAction)next:(id)sender {
    _index++;
    if(_index>=self.localFiles.count)  _index= 0;
    NSDictionary* file = self.localFiles[self.fileIndex];
    self.currentStr = file[@"url"];
    [self.dlnaManager playTheURL:self.dlnaManager.playUrl];
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

-(void)dealloc{
    [self.davServer stop];
    self.davServer = nil;
    [self.dlnaManager endDLNA];
    NSLog(@"%s",__FUNCTION__);
}
@end
