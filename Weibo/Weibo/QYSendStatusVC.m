//
//  QYSendStatusVC.m
//  Weibo
//
//  Created by qingyun on 16/6/21.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "QYSendStatusVC.h"
#import "QYStatus.h"
#import "QYUser.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "QYAccessToken.h"
#import "ConfigFile.h"

@interface QYSendStatusVC ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property(nonatomic ,strong)UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *adTitleLabe;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImageView;

@property(strong,nonatomic)NSMutableArray *iconArr;

@end

@implementation QYSendStatusVC

-(void)disMiss{
//取消
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)send{
//发送信息
    //1.封装参数
    
    if (REPORTTYPE==_type) {
    NSDictionary *pars;
    if (_myTextView.text.length>0) {
      pars=@{@"access_token":[QYAccessToken shareHandel].access_token,@"id":self.status.idstr,@"status":_myTextView.text};
    }else{
     pars=@{@"access_token":[QYAccessToken shareHandel].access_token,@"id":self.status.idstr};
    }
    //2请求
    __weak QYSendStatusVC *vc=self;
    [SVProgressHUD showWithStatus:@"转发中..."];
    [[AFHTTPSessionManager manager] POST:[BASEURL stringByAppendingPathComponent:REPORTPATH] parameters:pars progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"======%@",responseObject);
        [SVProgressHUD showSuccessWithStatus:@"转发成功"];
        [SVProgressHUD dismissWithDelay:1];
        [vc.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"请求失败"];
        [SVProgressHUD dismissWithDelay:1];
    }];
    }else{
        if (_myTextView.text.length<1) {
            //提示不能发送
 //           [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
//            [SVProgressHUD dismissWithDelay:2];
            return;
        }
        
          NSDictionary *pars=@{@"access_token":[QYAccessToken shareHandel].access_token,@"status":_myTextView.text};
        
      //发送信息
        __weak QYSendStatusVC *vc=self;

        if (_iconArr.count>0) {
            //带图片发微博
            [SVProgressHUD showWithStatus:@"正在发送..."];
            
            [[AFHTTPSessionManager manager] POST:UPLOADNEWWBPATH parameters:pars constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                //追加数据
                UIImage *image=_iconArr[0];
                NSData *data=UIImageJPEGRepresentation(image,1);

                [formData appendPartWithFileData:data name:@"pic" fileName:@"statname" mimeType:@"image/jpeg"];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"=======%lld",uploadProgress.completedUnitCount);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"======成功");
                [SVProgressHUD dismiss];
                [vc dismissViewControllerAnimated:YES completion:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
            }];
            
            
            
            
        }else{
            
           //2.请求
            [SVProgressHUD showWithStatus:@"正在发送..."];
            [[AFHTTPSessionManager manager] POST:UPDATENEWWBPATH parameters:pars progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"========%@",responseObject);
                [SVProgressHUD dismiss];
                [vc dismissViewControllerAnimated:YES completion:nil];
               
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [SVProgressHUD showErrorWithStatus:error];
                [SVProgressHUD dismissWithDelay:1];
            }];
        }
    
    
    
    
    
    
    }
        
        
}




- (IBAction)TapPhoneAction:(id)sender {
    //调用相机
    UIImagePickerController *pickerController=[[UIImagePickerController alloc] init];
    //设置类型 图册
    pickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing=YES;
    //设置代理
    pickerController.delegate=self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //1.获取图片
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    _phoneImageView.image=image;
    
    [_iconArr addObject:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

}


-(void)addSubView{

    
    
    _titleLab=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
    if (_type==REPORTTYPE) {
         _titleLab.text=@"请输入信息...";
    }else{
         _titleLab.text=@"分享新鲜事";
    }
   
    _titleLab.textColor=[UIColor grayColor];
    //添加到textView
    [_myTextView addSubview:_titleLab];
    _myTextView.delegate=self;
    
    //barbuttonItem
    UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(disMiss)];
    UIBarButtonItem *rigthBtnItem=[[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    self.navigationItem.leftBarButtonItem=leftBtnItem;
    self.navigationItem.rightBarButtonItem=rigthBtnItem;
    if (REPORTTYPE==_type) {
        //初始化视图
        [[NSBundle mainBundle] loadNibNamed:@"ReportView" owner:self options:nil];
        self.tableView.tableFooterView=self.adView;
        //绑定转发数据
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.status.user.profile_image_url]];
        self.adTitleLabe.text=[NSString stringWithFormat:@"@%@",self.status.user.name];
        self.contentLab.text=self.status.text;

    }else{
        UIView *tempView=[[NSBundle mainBundle] loadNibNamed:@"ImageViewSelect" owner:self options:nil][0];
        self.tableView.tableFooterView=tempView;
    }
   
   
}


- (void)viewDidLoad {
        //1初始数组
    _iconArr=[NSMutableArray array];
    
    [super viewDidLoad];
    [self addSubView];

}


#pragma textViewdelegate
//-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    self.titleLab.hidden=YES;
//    return YES;
//}
- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length==0) {
        self.titleLab.hidden=NO;

    }else{
        self.titleLab.hidden=YES;

    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
