//
//  NSMutableDictionary+Serialization.h
//  Weibo
//
//  Created by qingyun on 16/6/21.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSMutableDictionary (Serialization)
//序列化数据
-(NSMutableDictionary *)serialization;
//反序列化数据
-(NSMutableDictionary *)deSerializaion;

@end
