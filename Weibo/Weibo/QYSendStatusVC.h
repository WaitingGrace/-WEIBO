//
//  QYSendStatusVC.h
//  Weibo
//
//  Created by qingyun on 16/6/21.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QYStatus;
typedef enum : NSUInteger {
    REPORTTYPE, //转发
    WRITETYPE,  //写入
}  WRITE;

@interface QYSendStatusVC : UITableViewController
@property(nonatomic,strong)QYStatus *status;

@property(nonatomic)WRITE type;
@end
