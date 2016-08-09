//
//  KWFirstViewController.m
//  KWFormViewDemo
//
//  Created by kevin on 15/3/20.
//  Copyright (c) 2015年 kevin. All rights reserved.
//

#import "KWFirstViewController.h"
#import "KWFormViewQuickBuilder.h"
#import <QuickLook/QuickLook.h>
#import "SearchViewController.h"
@interface KWFirstViewController ()<UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSMutableArray* arr ;
@property (nonatomic, strong) NSMutableArray* dateForSearch ;
@end

@implementation KWFirstViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"常委会方案展示系统";
    self.navigationController.navigationBar.barTintColor = SXRGB16Color(0x00BFFF);
    
    self.navigationItem.rightBarButtonItem          = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"icon_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self action:@selector(onClickRightMenuButton)];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"方案.csv"];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* fileContents = [NSString stringWithContentsOfFile:path
                                                       encoding: enc error:nil];
    
    if(!fileContents){
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"请先导入数据" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    
    NSArray* array = [fileContents componentsSeparatedByString:@"\r\n"];
    _arr = [NSMutableArray new];
    _dateForSearch = [NSMutableArray new];
    
    for (int i = 0; i < array.count; i++) {
        NSString* strsInOneLine = [array objectAtIndex:i];
        NSString *trimmedString = [strsInOneLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray* singleStrs = [trimmedString componentsSeparatedByString:@","];
        
        if (i>0) {
            NSMutableDictionary* dic = [NSMutableDictionary new];
            [dic setValue: [trimmedString stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"desc"];
            [dic setValue:[singleStrs lastObject] forKey:@"doc"];
            [_dateForSearch addObject:dic];
        }
        [_arr addObject:singleStrs];
    }
    
    KWFormViewQuickBuilder *builder = [[KWFormViewQuickBuilder alloc] init];
    [builder addRecord: _arr[0]];
    NSArray* one = _arr[0];
    NSMutableArray *SELs  = [NSMutableArray new];
    for (int i = 0; i < one.count; i++) {
        [SELs addObject:@"detail:"];
    }
    for (int i = 1; i< _arr.count;i++) {
        [builder addRecord:_arr[i] SELNames:SELs];
    }
    
    [builder setActionTarget:self];
    UIScrollView* scrollview = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scrollview];
    
    NSArray* arrOne = _arr[0];
    NSMutableArray* widths = [NSMutableArray new];
    CGFloat width =  [[UIScreen mainScreen] bounds].size.width;
    for (int i = 0; i< arrOne.count; i++) {
        if (i == 0||i==2) {
            [widths addObject:@(0.5*width/(arrOne.count-1))];
        }else if (i==6||i==7){
            [widths addObject:@(1.5*width/(arrOne.count-1))];
        }else{
            [widths addObject:@(width/(arrOne.count-1))];
        }
    }
    KWFormView *formView = [builder startCreatWithWidths:widths startPoint:CGPointMake(0, 0)];
    CGSize size = CGSizeMake(self.view.frame.size.width, 80 *_arr.count);
    //    formView.delegate = self;
    [scrollview setContentSize:size];
    [scrollview addSubview:formView];
 
}

-(void)detail:(UIButton *)sender
{
    int colum = ((int)sender.tag - 10000)/100;
    NSArray* oneLine = _arr[colum];
    NSString* name = [oneLine lastObject];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:name];

    
    NSURL *url=[NSURL fileURLWithPath:filePath];
    
    UIDocumentInteractionController* controller = [UIDocumentInteractionController  interactionControllerWithURL:url];

    controller.delegate = self;

    [controller presentPreviewAnimated:YES];
}


- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller
{
    return self;
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller

{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

/**
 *  导航栏rightBarButtonItem点击事件
 */
-(void)onClickRightMenuButton{
    SearchViewController *vc = [SearchViewController new];
    vc.data = _dateForSearch;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:vc animated:NO];
}


@end
