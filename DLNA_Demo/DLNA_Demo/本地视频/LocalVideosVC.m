//
//  LocalVideosVC.m
//  DLNA_Demo
//


#import "LocalVideosVC.h"
#import "AVTableViewCell.h"
#import <Photos/Photos.h>
#import "LocalShowVideoVC.h"

@interface LocalVideosVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView  *baseV;
@property (nonatomic,strong)NSArray  *files;
@end

@implementation LocalVideosVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地视频列表";
    [self setUpUI];
    [self getVideosList];
}

-(void)getVideosList{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.files = [self getAllMoviesForLocalShow];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.baseV reloadData];
        });
    });
}

//获取所有视频
- (NSArray *)getAllMoviesForLocalShow {
    PHFetchOptions *allOptions = [[PHFetchOptions alloc]init];
    allOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allVideos= [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:allOptions];
    
    NSMutableArray* files = [NSMutableArray new];
    
    [allVideos enumerateObjectsUsingBlock:^(PHAsset *assert, NSUInteger idx, BOOL * _Nonnull stop) {
        if(assert){
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [[PHImageManager defaultManager] requestAVAssetForVideo:assert options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                NSString * urlString = [[[info objectForKey:@"PHImageFileSandboxExtensionTokenKey"]componentsSeparatedByString:@";"] lastObject];
                NSDateFormatter* format = [NSDateFormatter new];
                format.dateFormat = @"yyyy-MM-dd hh:mm aa";
                [files addObject:@{@"url" : urlString ?: @"", @"title" : [format stringFromDate:assert.creationDate] ?: @"",@"asset":asset}];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
        }
    }];
    return files;
}


-(void)setUpUI{
    self.baseV = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.baseV];
    self.baseV.delegate =self;
    self.baseV.dataSource = self;
    self.baseV.tableFooterView  =[UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AVTableViewCell *cell = [AVTableViewCell cellWithTableView:tableView];
    NSDictionary* file = self.files[indexPath.item];
    AVAsset * asset = file[@"asset"];
    [cell setVideoThumbImage:asset];
    cell.textLabel.text  = file[@"title"];
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    LocalShowVideoVC *vc = [[LocalShowVideoVC alloc]initWithNibName:@"LocalShowVideoVC" bundle:nil];
    vc.localFiles = self.files;
    vc.fileIndex = indexPath.row;
    [self.navigationController showViewController:vc sender:self];
}
@end
