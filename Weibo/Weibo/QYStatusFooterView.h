//
//  QYStatusFooterView.h
//  Weibo
//
//  Created by qingyun on 16/5/26.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYStatus;

typedef enum : NSUInteger {
    REPORT,    //转发
    RECOMMENTS,//评论
    RELIKE,    //赞
} RETYPE;

typedef void(^RECallBack)(QYStatus *mode,RETYPE type);

@interface QYStatusFooterView : UITableViewHeaderFooterView
@property (nonatomic, strong) QYStatus *footerStatus;
@property (nonatomic,strong)RECallBack Block;
@end
