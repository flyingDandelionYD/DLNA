//
//  ViewController.m
//  DLNA_Demo
//


#import "ViewController.h"
#import "SearchDevicesVC.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"DLNA投屏";

}

- (IBAction)goToSearch:(id)sender {
    SearchDevicesVC *searchVC = [[SearchDevicesVC alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}

@end
