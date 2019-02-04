//
//  CLUPnPRenderer.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/9/29.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "CLUPnP.h"
#import "GDataXMLNode.h"
#import "CLUPnPAction.h"

#define VideoDIDL @"<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:sec=\"http://www.sec.co.kr/\" xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\"><item id=\"f-0\" parentID=\"0\" restricted=\"0\"><dc:title>Video</dc:title><dc:creator>Anonymous</dc:creator><upnp:class>object.item.videoItem</upnp:class><res protocolInfo=\"http-get:*:video/*:DLNA.ORG_OP=01;DLNA.ORG_CI=0;DLNA.ORG_FLAGS=01700000000000000000000000000000\" sec:URIType=\"public\">%@</res></item></DIDL-Lite>"


#define ImageDIDL @"<DIDL-Lite xmlns=\"urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/\" xmlns:upnp=\"urn:schemas-upnp-org:metadata-1-0/upnp/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dlna=\"urn:schemas-dlna-org:metadata-1-0/\" xmlns:sec=\"http://www.sec.co.kr/\"><item id=\"filePath\" parentID=\"0\" restricted=\"1\"><upnp:class>object.item.imageItem</upnp:class><dc:title>IMAG1466</dc:title><dc:creator>Unknown Artist</dc:creator><upnp:artist>Unknown Artist</upnp:artist><upnp:albumArtURI>http://IP:PORT/filePath</upnp:albumArtURI><upnp:album>Unknown Album</upnp:album><res protocolInfo=\"http-get:*:image/jpeg:DLNA.ORG_PN=JPEG_LRG;DLNA.ORG_OP=01;DLNA.ORG_FLAGS=01700000000000000000000000000000\">http://IP:PORT/filePath</res></item></DIDL-Lite>"

@implementation CLUPnPRenderer

//传入一个“服务对象" 来创建一个渲染 实例
- (instancetype)initWithModel:(CLUPnPDevice *)model{
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (void)setModel:(CLUPnPDevice *)model{
    _model = model;
}


#pragma mark -
#pragma mark -- AVTransport动作 --
- (void)setAVTransportURL:(NSString *)urlStr WithType:(NSString*)typeStr{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];//设置当前播放时期时为 0 即可
    [action setArgumentValue:urlStr forName:@"CurrentURI"]; //设置播放资源URI
    if([typeStr isEqualToString:@"1"]){
         [action setArgumentValue:ImageDIDL forName:@"CurrentURIMetaData"]; //媒体meta数据，可以为空  // ImageDIDLP:图片  VideoDIDL:视频
    }else{
         [action setArgumentValue:VideoDIDL forName:@"CurrentURIMetaData"]; //媒体meta数据，可以为空  // ImageDIDLP:图片  VideoDIDL:视频
    }
    [self postRequestWith:action];
}

- (void)setNextAVTransportURI:(NSString *)urlStr{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetNextAVTransportURI"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:urlStr forName:@"NextURI"];
    [action setArgumentValue:@"" forName:@"NextURIMetaData"];
    [self postRequestWith:action];
    
}

- (void)play{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Play"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"1" forName:@"Speed"];
    [self postRequestWith:action];
}

- (void)pause{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Pause"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)stop{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Stop"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)next{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Next"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)previous{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Previous"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)getPositionInfo{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetPositionInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)getTransportInfo{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetTransportInfo"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [self postRequestWith:action];
}

- (void)seek:(float)relTime{
    [self seekToTarget:[NSString stringWithDurationTime:relTime] Unit:unitREL_TIME];
}

- (void)seekToTarget:(NSString *)target Unit:(NSString *)unit{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"Seek"];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:unit forName:@"Unit"];
    [action setArgumentValue:target forName:@"Target"];
    [self postRequestWith:action];
}


#pragma mark -
#pragma mark -- RenderingControl动作 --
- (void)getVolume{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"GetVolume"];
    [action setServiceType:CLUPnPServiceRenderingControl];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [self postRequestWith:action];
}

- (void)setVolumeWith:(NSString *)value{
    CLUPnPAction *action = [[CLUPnPAction alloc] initWithAction:@"SetVolume"];
    [action setServiceType:CLUPnPServiceRenderingControl];
    [action setArgumentValue:@"0" forName:@"InstanceID"];
    [action setArgumentValue:@"Master" forName:@"Channel"];
    [action setArgumentValue:value forName:@"DesiredVolume"];
    [self postRequestWith:action];
}



#pragma mark -
#pragma mark -- 发送动作请求 --
- (void)postRequestWith:(CLUPnPAction *)action{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL       *url = [NSURL URLWithString:[action getPostUrlStrWith:_model]];
    NSString    *postXML = [action getPostXMLFile];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval =  3.0;
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[action getSOAPAction] forHTTPHeaderField:@"SOAPAction"];//内容是SDD中serviceType与Action名字拼接而成
    request.HTTPBody = [postXML dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || data == nil) {
            [self _UndefinedResponse:nil postXML:postXML];//失败 OR data为空
            if([error.userInfo.allKeys containsObject:@"NSUnderlyingError"]){
                NSString *errorStr = [NSString stringWithFormat:@"%@",error.userInfo[@"NSUnderlyingError"]];
                if([errorStr containsString:@"kCFErrorDomainCFNetwork"]){
                    [self _ErrorDomain:error];
                }
            }
            return;
        }else{
            [self parseRequestResponseData:data postXML:postXML]; //接收到了动作响应（发送了服务动作请求的指令）
        }
    }];
    [dataTask resume];
}

#pragma mark -
#pragma mark -- 动作响应 --
- (void)parseRequestResponseData:(NSData *)data postXML:(NSString *)postXML{
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArr = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            [self resultsWith:needArr postXML:postXML];//处理 发送了服务动作请求的指令返回的有用的数据
        }else{
            [self _UndefinedResponse:[xmlEle XMLString] postXML:postXML];
        }
    }
}

//处理 发送了服务动作请求的指令返回的有用的数据 
- (void)resultsWith:(NSArray *)array postXML:(NSString *)postXML{
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) { //设置URI的响应
            [self _SetAVTransportURIResponse];
            [self getTransportInfo];
        }else if ([[ele name] hasSuffix:@"SetNextAVTransportURIResponse"]){ //设置下一个URI的响应
            [self _SetNextAVTransportURIResponse];
        }else if ([[ele name] hasSuffix:@"PauseResponse"]){//“暂停”的响应
            [self _PauseResponse];
        }else if ([[ele name] hasSuffix:@"PlayResponse"]){//“播放”的响应
            [self _PlayResponse];
        }else if ([[ele name] hasSuffix:@"StopResponse"]){//“停止”的响应
            [self _StopResponse];
        }else if ([[ele name] hasSuffix:@"SeekResponse"]){//“跳”的响应 （跳转到特定的进度或者特定的视频）
            [self _SeekResponse];
        }else if ([[ele name] hasSuffix:@"NextResponse"]){//“下一个” 的响应
            [self _NextResponse];
        }else if ([[ele name] hasSuffix:@"PreviousResponse"]){//“上一个” 的响应
            [self _PreviousResponse];
        }else if ([[ele name] hasSuffix:@"SetVolumeResponse"]){//“设置音量”的 响应
            [self _SetVolumeResponse];
        }else if ([[ele name] hasSuffix:@"GetVolumeResponse"]){ //“获取音量”的 响应
            [self _GetVolumeSuccessWith:[ele children]];
        }else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]){ //获取“播放进度”的响应
            [self _GetPositionInfoResponseWith:[ele children]];
        }else if ([[ele name] hasSuffix:@"GetTransportInfoResponse"]){
            [self _GetTransportInfoResponseWith:[ele children]];
        }else{
            [self _UndefinedResponse:[ele XMLString] postXML:postXML];
        }
    }
}

#pragma mark -
#pragma mark -- 回调协议 --
- (void)_SetAVTransportURIResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetAVTransportURIResponse)]) {
        [self.delegate upnpSetAVTransportURIResponse];
    }
}

- (void)_SetNextAVTransportURIResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetNextAVTransportURIResponse)]) {
        [self.delegate upnpSetNextAVTransportURIResponse];
    }
}

- (void)_PauseResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPauseResponse)]) {
        [self.delegate upnpPauseResponse];
    }
}

- (void)_PlayResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPlayResponse)]) {
        [self.delegate upnpPlayResponse];
    }
}

- (void)_StopResponse{
    if ([self.delegate respondsToSelector:@selector(upnpStopResponse)]) {
        [self.delegate upnpStopResponse];
    }
}

- (void)_SeekResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSeekResponse)]) {
        [self.delegate upnpSeekResponse];
    }
}

- (void)_NextResponse{
    if ([self.delegate respondsToSelector:@selector(upnpNextResponse)]) {
        [self.delegate upnpNextResponse];
    }
}

- (void)_PreviousResponse{
    if ([self.delegate respondsToSelector:@selector(upnpPreviousResponse)]) {
        [self.delegate upnpPreviousResponse];
    }
}

- (void)_SetVolumeResponse{
    if ([self.delegate respondsToSelector:@selector(upnpSetVolumeResponse)]) {
        [self.delegate upnpSetVolumeResponse];
    }
}

- (void)_GetVolumeSuccessWith:(NSArray *)array{
    for (int j = 0; j < array.count; j++) {
        GDataXMLElement *eleXml = [array objectAtIndex:j];
        if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
            if ([self.delegate respondsToSelector:@selector(upnpGetVolumeResponse:)]) {
                [self.delegate upnpGetVolumeResponse:[eleXml stringValue]];
            }
        }
    }
}

- (void)_GetPositionInfoResponseWith:(NSArray *)array{
    CLUPnPAVPositionInfo *info = [[CLUPnPAVPositionInfo alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(upnpGetPositionInfoResponse:)]) {
        [self.delegate upnpGetPositionInfoResponse:info];
    }
}

- (void)_GetTransportInfoResponseWith:(NSArray *)array{
    CLUPnPTransportInfo *info = [[CLUPnPTransportInfo alloc] init];
    [info setArray:array];
    if ([self.delegate respondsToSelector:@selector(upnpGetTransportInfoResponse:)]) {
        [self.delegate upnpGetTransportInfoResponse:info];
    }
}

- (void)_UndefinedResponse:(NSString *)xmlStr postXML:(NSString *)postXML{
    NSLog(@"===========发送信息:%@ \n",postXML);
    NSLog(@"===========响应信息:%@ \n",xmlStr);
    if ([self.delegate respondsToSelector:@selector(upnpUndefinedResponse:postXML:)]) {
        [self.delegate upnpUndefinedResponse:xmlStr postXML:postXML];
    }
}

-(void)_ErrorDomain:(NSError*)error{
    if([self.delegate respondsToSelector:@selector(upnpErrorDomain:)]){
        [self.delegate upnpErrorDomain:error];
    }
}
@end
