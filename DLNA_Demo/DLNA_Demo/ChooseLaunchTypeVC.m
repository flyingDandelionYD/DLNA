//
//  ChooseLaunchTypeVC.m
//  DLNA_Demo
//


#import "ChooseLaunchTypeVC.h"

#import "RemotePicturesVC.h"
#import "LocalPicturesVC.h"
#import "RomoteShowVideoVC.h"
#import "LocalVideosVC.h"

@interface ChooseLaunchTypeVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)NSArray  *typesArr;
@property (nonatomic,strong)UITableView  *baseV;
@end

@implementation ChooseLaunchTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择要投屏的类型";
    [self  setUpUI];
}

-(NSArray*)typesArr{
    if(_typesArr==nil){
        _typesArr = @[
                      @"网络图片",
                      @"网络视频",
                      @"本地图片",
                      @"本地视频"
                      ];
    }
    return _typesArr;
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
    return self.typesArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseLaunchTypeVC"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChooseLaunchTypeVC"];
    }
    cell.textLabel.text  = self.typesArr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row==0){
        RemotePicturesVC *vc = [[RemotePicturesVC alloc]initWithNibName:@"RemotePicturesVC" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row==2){
        LocalPicturesVC *vc = [[LocalPicturesVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row==1){
        RomoteShowVideoVC *vc = [[RomoteShowVideoVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        LocalVideosVC *vc = [[LocalVideosVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
