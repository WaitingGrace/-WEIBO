//
//  DataBaseFile.h
//  01-数据持久化作业
//
//  Created by qingyun on 16/6/20.
//  Copyright © 2016年 QingYun. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef DataBaseFile_h
#define DataBaseFile_h

static NSString * const kStatusCreatedAt = @"created_at";
static NSString * const kStatusIdstr = @"idstr";
static NSString * const kStatusText = @"text";
static NSString * const kStatusSource = @"source";
static NSString * const kStatusFavorited = @"favorited";
static NSString * const kStatusThumbnailPic = @"thumbnail_pic";
static NSString * const kStatusBmiddlePic = @"bmiddle_pic";
static NSString * const kStatusOriginalPic = @"original_pic";
static NSString * const kStatusUser = @"user";
static NSString * const kStatusRetweetedStatus = @"retweeted_status";
static NSString * const kStatusRepostsCount = @"reposts_count";
static NSString * const kStatusCommentsCount = @"comments_count";
static NSString * const kStatusAttitudesCount = @"attitudes_count";
static NSString * const kStatusPicUrls = @"pic_urls";



//数据库名称
#define BaseFileName @"WeiBo.db"
//创建表

#define createTabel @"create table if not exists WBHome(idstr text,created_at text,text text,source text,favorited  integer, user blob,retweeted_status blob,reposts_count integer,comments_count integer,attitudes_count integer,pic_urls blob);"
//插入数据
#define INSERT_HOMELIST_SQL @"insert into WBHome values(:idstr,:created_at,:text,:source,:favorited,:user,:retweeted_status,:reposts_count,:comments_count,:attitudes_count,:pic_urls)"
//查询所有的数据
#define SELECT_HOMELIST_ALL @"select * from WBHome order by created_at desc"

//删除数据
#define Delete_HOMELIST @"delete from WBHome"

#endif /* DataBaseFile_h */
