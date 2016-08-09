//
//  SearchViewController.m
//  hualongxiang
//
//  Created by polyent on 16/1/22.
//  Copyright © 2016年 crazysun. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIDocumentInteractionControllerDelegate>
@property (nonatomic,strong) UISearchBar *searchBar;

@property (nonatomic,strong) NSMutableArray* searchData;
@property (nonatomic,strong) UITableView* tableView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _searchData = [NSMutableArray new];
    [_searchData addObjectsFromArray:_data];
    [self initNavigationBar];
    [self initTableView];
}

- (void)initNavigationBar{
    
    [self.navigationController setNavigationBarHidden:YES];
    
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar = [UISearchBar new];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入关键字";
    _searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width-100, 44);
    [_searchBar becomeFirstResponder];
    UIBarButtonItem* left = [[UIBarButtonItem alloc] initWithCustomView:_searchBar];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
    [item setLeftBarButtonItem:left];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_searchBar.frame), 0, 50, 44)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* right = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    [item setRightBarButtonItem:right];
#pragma mark -- 修改导航栏颜色失败  自定义导航栏 issue frame && color
    //    [bar setTintColor:[UIColor clearColor]];
    //    [bar setBackgroundColor:[UIColor clearColor]];
    [bar pushNavigationItem:item animated:NO];
    //    [right setTintColor:[UIColor clearColor]];
    [self.view addSubview:bar];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


/**
 *初始化tableView
 */
-(void)initTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}
/**
 *  点击取消按钮
 */
- (void)clickCancelBtn{
    if([_searchBar isFirstResponder]){
        [_searchBar resignFirstResponder];
    }else{
        [self.navigationController popViewControllerAnimated:YES ];

    }
    
}

#pragma mark -- SearchBar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{

    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder ];
    [_searchData removeAllObjects];
    for (int i = 0; i < _data.count; i++) {
        NSDictionary* dic = _data[i];
        NSString* desc = [dic objectForKey:@"desc"];
        if ([desc containsString:searchBar.text]) {
            [_searchData addObject:dic];
        }
    }
    [_tableView reloadData];
}



#pragma mark -- tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        return _searchData.count;

}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cellID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary*  dic = _searchData[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"desc"];
    return cell;
}

#pragma mark -- tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary* dic = _searchData[indexPath.row];
    NSString* name = [dic objectForKey:@"doc"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:name];
    
    
    NSURL *url=[NSURL fileURLWithPath:filePath];

  
//    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
//    NSURL *url=[NSURL fileURLWithPath:filePath];
    
    UIDocumentInteractionController* controller = [UIDocumentInteractionController  interactionControllerWithURL:url];

    controller.delegate = self;
    [controller presentPreviewAnimated:YES];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchBar resignFirstResponder];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        [_history removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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




@end
