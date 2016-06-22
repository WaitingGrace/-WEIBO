//
//  ConfigFile.h
//  Weibo
//
//  Created by qingyun on 16/6/7.
//  Copyright © 2016年 QingYun. All rights reserved.
//


#ifndef ConfigFile_h
#define ConfigFile_h

#import "AFNetworking.h"
#import "SVProgressHUD.h"

//请求的主机
#define BASEURL @"https://api.weibo.com"
//请求路径path
//请求授权
#define AUTHORIZEPATH @"oauth2/authorize"
//获取授权accesstoken
#define GETACCESSTOKENPATH   @"oauth2/access_token"
//获取首页数据

#define GETHOMELISTPATH @"/2/statuses/home_timeline.json"
//转发微博
#define REPORTPATH @"/2/statuses/repost.json"
//评论的微博
#define GETCOMMENTLIST @"https://api.weibo.com/2/comments/show.json"

//发微博+图片
#define UPLOADNEWWBPATH @"https://api.weibo.com/2/statuses/upload.json"
//发微博文字
#define UPDATENEWWBPATH @"https://api.weibo.com/2/statuses/update.json"



#endif /* ConfigFile_h */
