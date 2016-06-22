//
//  QYDetailStatusVC.m
//  Weibo
//
//  Created by qingyun on 16/5/28.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "QYDetailStatusVC.h"
#import "QYStatusCell.h"
#import "QYDetailSectionHeaderView.h"
#import "QYCommentCell.h"
#import "QYComment.h"
#import "QYStatus.h"

#import "ConfigFile.h"
#import "QYAccessToken.h"
@interface QYDetailStatusVC ()

@property (nonatomic, strong) NSArray *commentArray;    //评论array
@property (nonatomic, strong) NSArray *otherArray;     //其他(转发/赞)

@property (nonatomic, strong) NSArray *showDatas;       //第一个section显示的数据

@property (nonatomic)         NSInteger selectedIndexOfSectionBtns;    //保存当前sectionHeaderView选中的btn的tag值
@end

@implementation QYDetailStatusVC
static NSString *statusCellIdentifier = @"statusCell";
static NSString *headerIdentifier = @"headerView";
static NSString *commentCellIdentifier = @"commentCell";
//懒加载commentArray
-(NSArray *)commentArray{
#if 0
    if (_commentArray == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"comments" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSArray *comments = dict[@"comments"];
        
        NSMutableArray *models = [NSMutableArray array];
        for (NSDictionary *commentDict in comments) {
            QYComment *comment = [QYComment commentWithDictionary:commentDict];
            [models addObject:comment];
        }
        _commentArray = models;
    }
#endif
    if (_commentArray == nil) {
        _commentArray = [NSArray array];
    }
    return _commentArray;
}

//获取评论列表数据
- (void)repuestCommentListDatas{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@?access_token=%@&id=%@",GETCOMMENTLIST,[QYAccessToken shareHandel].access_token,_cellStatus.idstr];
#if 0
    NSURL * url = [NSURL URLWithString:urlStr];
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    __weak QYDetailStatusVC * statusVC = self;
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error)NSLog(@"%@",error);
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray * array = dict[@"comments"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *commentDict in array) {
                QYComment *comment = [QYComment commentWithDictionary:commentDict];
                [models addObject:comment];
            }
            statusVC.commentArray = models;
            statusVC.showDatas = models;
            
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [statusVC.tableView reloadData];
        });
    }];
    [dataTask resume];
#endif
    
    //创建manager
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    //请求
    __weak QYDetailStatusVC * statusVC = self;
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)task.response;
        if (httpResponse.statusCode == 200) {
            //字典转model
            NSArray * array = responseObject[@"comments"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSDictionary *commentDict in array) {
                QYComment *comment = [QYComment commentWithDictionary:commentDict];
                [models addObject:comment];
            }
            statusVC.commentArray = models;
            statusVC.showDatas = models;
            
        }else{
            NSLog(@"statusCode : %ld",httpResponse.statusCode);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [statusVC.tableView reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
    }];
    
    
}



-(NSArray *)otherArray{
    if (_otherArray == nil) {
        _otherArray = @[];
    }
    return _otherArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 120;
    
    //注册第0个section中的单元格
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QYStatusCell class]) bundle:nil] forCellReuseIdentifier:statusCellIdentifier];
    
    //注册第一个section中的单元格
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QYCommentCell class]) bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
    
    self.showDatas = self.commentArray;
    self.selectedIndexOfSectionBtns = 102;
    
     [self repuestCommentListDatas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section ? self.showDatas.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        QYStatusCell *statusCell = [tableView dequeueReusableCellWithIdentifier:statusCellIdentifier forIndexPath:indexPath];
        
        statusCell.statusModel = self.cellStatus;
        
        return statusCell;
    }else if (indexPath.section == 1){
        QYCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier forIndexPath:indexPath];
        
        QYComment *comment = self.showDatas[indexPath.row];
        
        commentCell.commentModel = comment;
        
        return commentCell;
    }
    
    // Configure the cell...
    
    return nil;
}


//设置section的header的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 30.0;
    }
    return 0.1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    return 0.1;
}

//设置section的headerView
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return nil;
    }
    //获取headerView
    QYDetailSectionHeaderView *headerView = [QYDetailSectionHeaderView sectionHeaderViewForTableView:tableView WithSelectedTag:self.selectedIndexOfSectionBtns];
    //设置headerStatus
    headerView.headerStatus = self.cellStatus;
    
    __weak QYDetailStatusVC *weakSelf = self;
    headerView.changedSelectedBtn = ^(NSInteger tag){
        [weakSelf changedUI:tag];
    };
    
    return headerView;
}

//更改UI界面
-(void)changedUI:(NSInteger)selectedTag{
    
    if (selectedTag == 101 || selectedTag == 103) {
        _showDatas = self.otherArray;
    }else if (selectedTag == 102){
        _showDatas = self.commentArray;
    }
    
    //刷新第一个section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    self.selectedIndexOfSectionBtns = selectedTag;
    QYDetailSectionHeaderView *headerView = (QYDetailSectionHeaderView *)[self.tableView headerViewForSection:1];
    headerView.selectedTagOfBtns = selectedTag;
    
}
@end
