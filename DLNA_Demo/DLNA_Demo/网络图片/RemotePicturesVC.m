//
//  RemotePicturesVC.m
//  DLNA_Demo
//


#import "RemotePicturesVC.h"
#import "MRDLNA.h"

@interface RemotePicturesVC ()

@property (nonatomic,strong)NSArray  *picsUrlArr;
@property (nonatomic,strong)MRDLNA  *dlnaManager;
@end

@implementation RemotePicturesVC{
    NSInteger _index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"网络图片的投影";
    self.dlnaManager = [MRDLNA sharedMRDLNAManager];
    self.dlnaManager.typeStr = @"1";
    self.dlnaManager.playUrl = self.picsUrlArr.firstObject;
    [self.dlnaManager startDLNA];
}

-(NSArray*)picsUrlArr{
    if(_picsUrlArr==nil){
        _picsUrlArr = @[
                        @"http://pic2.nipic.com/20090506/2256386_141149004_2.jpg",
                        @"http://pic21.nipic.com/20120519/5454342_154115399000_2.jpg",
                        @"http://img.bimg.126.net/photo/ZZ5EGyuUCp9hBPk6_s4Ehg==/5727171351132208489.jpg"
                        ];
    }
    return _picsUrlArr;
}

- (IBAction)previous:(id)sender {
    _index--;
    if(_index<0) _index= self.picsUrlArr.count-1;
    [self.dlnaManager playTheURL:self.picsUrlArr[_index]];
}

- (IBAction)next:(id)sender {
    _index++;
    if(_index>=self.picsUrlArr.count)  _index= 0;
    [self.dlnaManager playTheURL:self.picsUrlArr[_index]];
}

-(void)dealloc{
    [self.dlnaManager endDLNA];
    NSLog(@"%s",__FUNCTION__);
}
@end
