//
//  NSMutableDictionary+Serialization.m
//  Weibo
//
//  Created by qingyun on 16/6/21.
//  Copyright © 2016年 QingYun. All rights reserved.
//

#import "NSMutableDictionary+Serialization.h"
#import "Common.h"

@implementation NSMutableDictionary (Serialization)

-(NSMutableDictionary *)serialization{
    NSArray*keyArr=@[@"idstr",@"created_at",@"text",@"source",@"favorited",@"user",@"retweeted_status",@"reposts_count",@"comments_count",@"attitudes_count",@"pic_urls"];
    
    
    //1.取出数据
    //retweeted_status 被转发的原微博信息字段
    NSDictionary *retDic=self[kStatusRetweetedStatus];
    //2.user
    NSDictionary *usrDic=self[kStatusUser];
    //3.pic_urls
    NSArray *picArr=self[kStatusPicUrls];
    //4.bool
    BOOL favo=[self[kStatusFavorited] boolValue];
    //判断是否为空
    NSData *retData;
    NSData *userData;
    NSData *picData;
    if (retDic) {
      //序列化操作
       retData=[NSKeyedArchiver archivedDataWithRootObject:retDic];
    }
    if (usrDic) {
        //序列化操作
        userData=[NSKeyedArchiver archivedDataWithRootObject:usrDic];
    }
    if (picArr) {
        //序列化操作
        picData=[NSKeyedArchiver archivedDataWithRootObject:picArr];
    }
    //声明可变字典
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:self];
 
    
  //重置字典里的值
    [dic setValue:retData?:[NSNull null]forKey:kStatusRetweetedStatus];
    [dic setValue:userData?:[NSNull null]forKey:kStatusUser];
    [dic setValue:picData?:[NSNull null]forKey:kStatusPicUrls];
    [dic setValue:favo?@1:@0 forKey:kStatusFavorited];
    
    //清空无用字段
    NSArray *keys=[dic allKeys];
    for (NSString *key in keys) {
        if (![keyArr containsObject:key]) {
            [dic removeObjectForKey:key];
        }
    }
    return dic;
}

-(NSMutableDictionary *)deSerializaion{
    //数据库取出的数据
    NSData *retData=self[kStatusRetweetedStatus];
    NSData *userData=self[kStatusUser];
    NSData *picData=self[kStatusPicUrls];
    NSInteger favo=[self[kStatusFavorited] integerValue];
    //NSdata===>objc
    NSDictionary *retDic=![retData isKindOfClass:[NSNull class]]?[NSKeyedUnarchiver unarchiveObjectWithData:retData]:[NSDictionary dictionary];
    NSDictionary *usrDic=![userData isKindOfClass:[NSNull class]]?[NSKeyedUnarchiver unarchiveObjectWithData:userData]:[NSDictionary dictionary];
    NSArray *picArr=![picData isKindOfClass:[NSNull class]]?[NSKeyedUnarchiver unarchiveObjectWithData:picData]:[NSArray array];
    NSNumber *favoBool=favo?@YES:@NO;
    //赋值操作
    //声明可变字典
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:self];

    [dic setValue:retDic forKey:kStatusRetweetedStatus];
    [dic setValue:usrDic forKey:kStatusUser];
    [dic setValue:picArr forKey:kStatusPicUrls];
    [dic setValue:favoBool forKey:kStatusFavorited];
    
    return dic;
}



@end
