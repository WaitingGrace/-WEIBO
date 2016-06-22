//
//  QYHomeVC.m
//  Weibo
//
//  Created by qingyun on 16/5/14.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "QYHomeVC.h"
#import "QYStatus.h"
#import "QYStatusCell.h"
#import "QYStatusFooterView.h"
#import "QYDetailStatusVC.h"
#import "ConfigFile.h"
#import "QYAccessToken.h"
#import "AFNetworking.h"
//引入数据库操作类
#import "QYDataBaseTool.h"
#import "NSMutableDictionary+Serialization.h"

#import "QYSendStatusVC.h"


@interface QYHomeVC ()
@property (nonatomic, strong) NSMutableArray *statusArray;
//页码数
@property (nonatomic)NSInteger page;
//判断是否是下拉刷新
@property (nonatomic)BOOL isRefresh;

@end

@implementation QYHomeVC
static NSString *cellIdentifier = @"statusCell";
static NSString *footerIdentifier = @"statusFooter";
//懒加载微博首页数据
/*
-(NSArray *)statusArray{
    if (_statusArray == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"temp" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSArray *statusArr = dict[@"statuses"];
        NSMutableArray *models = [NSMutableArray array];
        for (NSDictionary *statusDict in statusArr) {
            QYStatus *status = [QYStatus statusWithDictionary:statusDict];
            [models addObject:status];
        }
        _statusArray = models;
    }
    return _statusArray;
}
*/
//网络请求数据
-(void)requestHomeList{
#if 0
  //GET请求方法
  //1合并URL
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@?access_token=%@&page=1",[BASEURL stringByAppendingPathComponent:GETHOMELISTPATH],[QYAccessToken shareHandel].access_token]];
  //2.请求数据
    __weak QYHomeVC *home=self;
    NSURLSession *seession=[NSURLSession sharedSession];
    NSURLSessionDataTask *task=[seession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       //2.1判断请求成功
        if(error)NSLog(@"=====%@",error);
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
        if (httpResponse.statusCode==200) {
          //2.2 data 转换成字典 JSON解析
          NSDictionary *prs=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
          //2.3 字典转mode
            if (prs) {
                NSArray *dataArr=prs[@"statuses"];
                NSMutableArray *modeArr=[NSMutableArray array];
                for (NSDictionary *tempDic in dataArr) {
                    [modeArr addObject:[QYStatus statusWithDictionary:tempDic]];
                }
                home.statusArray=modeArr;
            }
            //2.4.刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [home.tableView reloadData];
            });
        }
    }];
   //3.启动
    [task resume];
#endif
   //1.封装参数
    NSDictionary *pars=@{@"access_token":[QYAccessToken shareHandel].access_token,@"page":@(_page)};
   //2.执行请求
    __weak QYHomeVC *vc=self;
    [[AFHTTPSessionManager manager] GET:[BASEURL stringByAppendingPathComponent:GETHOMELISTPATH] parameters:pars progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [vc.refreshControl endRefreshing];
        //1.成功
        NSHTTPURLResponse *response=(NSHTTPURLResponse *)task.response;
        if (response.statusCode==200) {
           //1.字典转mode
            if (_isRefresh) {
                //清空表里的数据
                [QYDataBaseTool updateStatementsSql:Delete_HOMELIST withParsmeters:nil block:^(BOOL isOk, NSString *errorMsg) {
                    if (isOk) {
                        NSLog(@"======删除成功");
                    }
                }];
            }
            
            
            NSArray *dataArr=responseObject[@"statuses"];
            NSMutableArray *modeArr=[NSMutableArray array];
            for (NSMutableDictionary *tempDic in dataArr) {
                //1.执行插入数据库的操作
                //1.1序列化参数
                 //[tempDic serialization];
                //1.2执行sql语句
                [QYDataBaseTool updateStatementsSql:INSERT_HOMELIST_SQL withParsmeters:   [tempDic serialization] block:^(BOOL isOk, NSString *errorMsg) {
                    if (isOk) {
                        NSLog(@"insert ok");
                    }
                }];
                [modeArr addObject:[QYStatus statusWithDictionary:tempDic]];
            }
            //2.判断当前请求是下拉刷新,还是上了加载更多
            if (_isRefresh) {
              //下拉刷新
                vc.statusArray=modeArr;
                _isRefresh=NO;
            }else{
              //上拉加载更多
                [vc.statusArray addObjectsFromArray:modeArr];
            }
            
            //3.刷新UI 主线程刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc.tableView reloadData];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    }];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //判断授权码accessToken
    if ([QYAccessToken shareHandel].access_token) {
        //网络请求数据,下拉刷新
//        self.tableView.contentOffset=CGPointMake(0, -100);
//         [self refreshControlAction:self.refreshControl];
           [self firstLoadRequest];
        
        //隐藏登录按钮
        self.navigationItem.rightBarButtonItem=nil;
    }
}
//首次加载配置,适用下拉刷新
-(void)firstLoadRequest{
    _isRefresh=YES;
    _page=1;
    [self requestHomeList];
}


-(void)refreshControlAction:(UIRefreshControl*)refresh{
   //.下拉加载中
    refresh.attributedTitle=[[NSAttributedString alloc] initWithString:@"下拉加载中..."];
    //执行下拉刷新操作
    [self firstLoadRequest];
}
//添加下拉刷新
-(void)addsubView{
    self.refreshControl=[[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad {
    //1.从本地数据库读取数据
    if ([QYAccessToken shareHandel].access_token) {
        //
        __weak QYHomeVC *vc=self;
        [QYDataBaseTool selectStatementsSql:SELECT_HOMELIST_ALL withParsmeters:nil forMode:nil block:^(NSMutableArray *resposeOjbc, NSString *errorMsg) {
            //1.字典转mode
            NSMutableArray *modeArr=[NSMutableArray array];
            for (NSMutableDictionary *tempDic in resposeOjbc) {
                //反序列化
                 //[tempDic deSerializaion];
               QYStatus *mode=[QYStatus statusWithDictionary:[tempDic deSerializaion]];
                [modeArr addObject:mode];
            }
            vc.statusArray=modeArr;
            //2.刷新UI
            [vc.tableView reloadData];
        }];
    }

    [super viewDidLoad];
    //注册单元格
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QYStatusCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
    
    //注册sectionFooterView
    [self.tableView registerClass:[QYStatusFooterView class] forHeaderFooterViewReuseIdentifier:footerIdentifier];
    
    //设置tableView的预估高度
    self.tableView.estimatedRowHeight = 120;
    
    [self addsubView];
    
    //初始化page
    _page=1;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.statusArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QYStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //判断当前是否是倒数第二条数据
    if ((_statusArray.count-2)==indexPath.section) {
        //上拉加载更多,加载下一页
        _page++;
        [self requestHomeList];
    }
    
    
    //获取当前section的模型
    QYStatus *cellStatus = self.statusArray[indexPath.section];
    cell.statusModel = cellStatus;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else{
        return 10;
    }
}

//设置sectionFooterView的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

//设置sectionFooterView
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    QYStatusFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerIdentifier];
    
    //获取当前section的模型
    QYStatus *status = self.statusArray[section];
    footerView.footerStatus = status;
    
    //处理回调
    __weak QYHomeVC *vc=self;
    footerView.Block=^(QYStatus *mode,RETYPE type){
        switch (type) {
            case REPORT:{//转发
                QYSendStatusVC *sendVc=[self.storyboard instantiateViewControllerWithIdentifier:@"QYSendStatusId"];
                //参数
                UINavigationController *natavation=[[UINavigationController alloc] initWithRootViewController:sendVc];
                
                sendVc.status=mode;
                
                [vc presentViewController:natavation animated:YES completion:nil];
                
            }
                break;
            case RECOMMENTS://评论
                
                break;
            case RELIKE://赞
                
                break;
            default:
                break;
        }
    };
    
    return footerView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获取详情视图控制器
    QYDetailStatusVC *detailStatusVC = [self.storyboard instantiateViewControllerWithIdentifier:@"detailVC"];
    QYStatus *selectedStatus = self.statusArray[indexPath.section];
    detailStatusVC.cellStatus = selectedStatus;
    
    [self.navigationController pushViewController:detailStatusVC animated:YES];
}


@end
