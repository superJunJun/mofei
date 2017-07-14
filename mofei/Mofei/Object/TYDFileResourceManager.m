//
//  TYDFileResourceManager.m
//  Mofei
//
//  Created by macMini_Dev on 14/12/6.
//  Copyright (c) 2014年 Young. All rights reserved.
//
//  用于数据云同步
//

#import "TYDFileResourceManager.h"
#import "ZipArchive.h"
#import "CoreDataManager.h"
#import "TYDDataCenter.h"
#import "TYDMensesDataCenter.h"
#import "WalkStepEntity.h"
#import "HeartRateEntity.h"
#import "MensesInfoEntity.h"
#import "TYDStepRecordInfo.h"
#import "TYDHeartRateRecordInfo.h"
#import "TYDMensesInfo.h"
#import "NSString+MD5Addition.h"
#import "SBJson.h"
#import "TYDMensesInfoAssistorSet.h"

#define sServerUrlForFileUpload         @"http://service-mofei.yy845.com:8080/mofei/services/FileService/fileUpLoad"
#define sServerUrlForFileDownload       @"http://service-mofei.yy845.com:8080/mofei/services/FileService/fileDownLoad"
//#define sServerUrlForFileUpload         @"http://192.168.0.52:8890/mofei/services/FileService/fileUpLoad"
//#define sServerUrlForFileDownload       @"http://192.168.0.52:8890/mofei/services/FileService/fileDownLoad"

#define sCloudSynchronousFolder             @"cloudSynchronous"
#define sHTTPRequestBoundary                @"HttpPostRequestBoundary"
#define sFileNextLineFlag                   @"\r\n"
#define sZipContentType                     @"multipart/form-data"//@"application/x-zip-compressed"
#define sZipFileNameUpload                  @"file.zip"
#define sZipFileNameDownload                @"downloadFile.zip"

#define sUploadFileNameSportInfoUpdate      @"sport_info_update"
#define sUploadFileNameSportInfoLocal       @"sport_info_local"
#define sUploadFileNameHeartRateInfoUpdate  @"heart_info_update"
#define sUploadFileNameHeartRateInfoLocal   @"heart_info_local"
#define sUploadFileNameMensesInfoUpdate     @"buddy_info_update"
#define sUploadFileNameMensesInfoModify     @"buddy_info_mofefy"
#define sUploadFileNameMensesInfoLocal      @"buddy_info_local"

#define sDownloadFileNameSportInfo          @"sport_info_down"
#define sDownloadFileNameHeartReartInfo     @"heart_info_down"
#define sDownloadFileNameMensesInfo         @"buddy_info_down"
//sport_info_update:新增运动信息
//sport_info_local:已存在的运动信息
//heart_info_update:新增心率信息
//heart_info_local:已存在的心率信息
//buddy_info_update:新增大姨妈信息
//buddy_info_mofefy:需要更新的大姨妈信息
//buddy_info_local:已存在的大姨妈信息

#define sCloudSynchronizeTimeMark   @"cloudSynchronizeTime"

/*
 暂不考虑断点续传功能，个人认为方式不恰当
 CloudSynchronizeType:
 
 CloudSynchronizeTypeNormal:0，正常情形
 本地数据库数据打包上传，而后差集下传，更新本地数据库，并将本地之前标记为新生成的数据项删除
 
 CloudSynchronizeTypeLogin:1，登录时获取数据
 本地组织“空数据”打包上传，而后下传的就是整个数据集，在写入数据库前清空数据库（下传失败时保证本地数据依旧可用），而后再写入数据库
 
 CloudSynchronizeTypeLogout:2，退出时上传数据
 本地数据库数据打包上传，上传完成则过程完成，不用数据下传
 */

typedef NS_ENUM(NSInteger, CloudSynchronizeType)
{
    CloudSynchronizeTypeNormal = 0,
    CloudSynchronizeTypeLogin  = 1,
    CloudSynchronizeTypeLogout = 2
};

@interface TYDFileResourceManager () <ZipArchiveDelegate>

@property (strong, nonatomic) NSString *resourceDirectory;//目录
@property (strong, nonatomic) ZipArchive *zipArchive;
@property (strong, nonatomic) SBJsonParser *jsonParser;
@property (strong, nonatomic) NSData *dataForUpload;//
//@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (assign, nonatomic) CloudSynchronizeType csType;//同步类型

@end

@implementation TYDFileResourceManager

#pragma mark - SingleTon

- (instancetype)init
{
    if(self = [super init])
    {
        self.resourceDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:sCloudSynchronousFolder];
        self.dataForUpload = nil;
        //_isInCloudSynchronizeDuration = NO;
        self.csType = CloudSynchronizeTypeNormal;
        [self cloudSynchronizeMarkTimeInit];
    }
    return self;
}

+ (instancetype)defaultManager
{
    static TYDFileResourceManager *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (ZipArchive *)zipArchive
{
    if(!_zipArchive)
    {
        _zipArchive = [ZipArchive new];
        _zipArchive.delegate = self;
    }
    return _zipArchive;
}

- (SBJsonParser *)jsonParser
{
    if(!_jsonParser)
    {
        _jsonParser = [SBJsonParser new];
    }
    return _jsonParser;
}

//- (NSOperationQueue *)operationQueue
//{
//    if(!_operationQueue)
//    {
//        _operationQueue = [NSOperationQueue new];
//    }
//    return _operationQueue;
//}

#pragma mark - CloudSynchronizeTime

- (void)setNewCloudSynchronizeMarkTime
{
    NSUInteger currentTime = [BOTimeStampAssistor getCurrentTime];
    _cloudSynchronizeMarkTime = currentTime;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:currentTime forKey:sCloudSynchronizeTimeMark];
    [userDefaults synchronize];
}

- (void)cloudSynchronizeMarkTimeInit
{
    _cloudSynchronizeMarkTime = [[NSUserDefaults standardUserDefaults] integerForKey:sCloudSynchronizeTimeMark];
}

#pragma mark - Directory

- (void)cloudSynchroDirectoryClear
{
    NSString *path = self.resourceDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
    [fileManager createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
}

- (NSString *)filePathWithFileName:(NSString *)fileName
{
    return [self.resourceDirectory stringByAppendingPathComponent:fileName];
}

- (NSFetchRequest *)fetchRequestWithEntityName:(NSString *)entityName userID:(NSString *)userID
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:NO]];
    return request;
}

#pragma mark - UploadFileCreate

- (NSData *)dataForUpload
{
    if(!_dataForUpload)
    {
        [self cloudSynchroDirectoryClear];
        //上传文件是否为空文件
        BOOL forceEmpty = (self.csType == CloudSynchronizeTypeLogin);
        [self sportInfoSaveToFile:forceEmpty];
        [self heartRateInfoSaveToFile:forceEmpty];
        [self mensesInfoSaveToFile:forceEmpty];
        
        NSString *zipFilePath = [self filePathWithFileName:sZipFileNameUpload];
        [self.zipArchive CreateZipFile2:zipFilePath];
        //SportInfoFiles
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameSportInfoLocal] newname:sUploadFileNameSportInfoLocal];
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameSportInfoUpdate] newname:sUploadFileNameSportInfoUpdate];
        //HeartRateInfoFiles
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameHeartRateInfoLocal] newname:sUploadFileNameHeartRateInfoLocal];
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameHeartRateInfoUpdate] newname:sUploadFileNameHeartRateInfoUpdate];
        //MensesInfoFiles
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameMensesInfoLocal] newname:sUploadFileNameMensesInfoLocal];
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameMensesInfoUpdate] newname:sUploadFileNameMensesInfoUpdate];
        [self.zipArchive addFileToZip:[self filePathWithFileName:sUploadFileNameMensesInfoModify] newname:sUploadFileNameMensesInfoModify];
        [self.zipArchive CloseZipFile2];
        
        _dataForUpload = [NSData dataWithContentsOfFile:zipFilePath];
    }
    return _dataForUpload;
}

- (void)sportInfoSaveToFile:(BOOL)forceEmpty
{
    NSString *userID = [TYDUserInfo sharedUserInfo].userID;
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSString *localFilePath = [self filePathWithFileName:sUploadFileNameSportInfoLocal];
    NSString *updatedFilePath = [self filePathWithFileName:sUploadFileNameSportInfoUpdate];
    
    NSMutableString *localInfoString = [@"" mutableCopy];
    NSMutableString *updatedInfoString = [@"" mutableCopy];
    
    if(!forceEmpty)
    {
        NSFetchRequest *request = [self fetchRequestWithEntityName:sWalkStepInfoEntityName userID:userID];
        NSArray *stepInfos = [coreDataManager fetchObjectsWithRequest:request];
        for(WalkStepEntity *wsEntity in stepInfos)
        {
            NSNumber *startTime = wsEntity.timeStamp;
            NSNumber *endTime = wsEntity.endTimeStamp;
            NSInteger costTime = MAX(0, ((endTime.integerValue - startTime.integerValue)));
            
            if(wsEntity.syncFlag.boolValue)
            {//local,
             //上传格式:mstarttime
                [localInfoString appendString:[NSString stringWithFormat:@"%@%@", [BOTimeStampAssistor timeStampToTimeString:startTime.integerValue], sFileNextLineFlag]];
            }
            else
            {//update,
             //上传格式:accoutid,mstarttime,msteps,mcosttime,mmileage,msporttype,mcalories
                [updatedInfoString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@%@", userID, [BOTimeStampAssistor timeStampToTimeString:startTime.integerValue], wsEntity.walkStepCount, @(costTime), wsEntity.distance, @(0), wsEntity.calorie, sFileNextLineFlag]];
            }
        }
    }
    //Test
    //[fileContentString appendFormat:@"545adbf5c23099ccbc000450,201412121130,100,60,75,0,5"];
    
    NSError *error = nil;
    if(![localInfoString writeToFile:localFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameSportInfoLocal, error.userInfo);
    }
    if(![updatedInfoString writeToFile:updatedFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameSportInfoUpdate, error.userInfo);
    }
}

- (void)heartRateInfoSaveToFile:(BOOL)forceEmpty
{
    NSString *userID = [TYDUserInfo sharedUserInfo].userID;
    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
    NSString *localFilePath = [self filePathWithFileName:sUploadFileNameHeartRateInfoLocal];
    NSString *updatedFilePath = [self filePathWithFileName:sUploadFileNameHeartRateInfoUpdate];
    
    NSMutableString *localInfoString = [@"" mutableCopy];
    NSMutableString *updatedInfoString = [@"" mutableCopy];
    if(!forceEmpty)
    {
        NSFetchRequest *request = [self fetchRequestWithEntityName:sHeartRateInfoEntityName userID:userID];
        NSArray *heartRateInfos = [coreDataManager fetchObjectsWithRequest:request];
        for(HeartRateEntity *hrEntity in heartRateInfos)
        {
            if(hrEntity.syncFlag.boolValue)
            {//local,上传格式:mstarttime
                [localInfoString appendString:[NSString stringWithFormat:@"%@%@", [BOTimeStampAssistor timeStampToTimeString:hrEntity.timeStamp.integerValue], sFileNextLineFlag]];
            }
            else
            {//update,上传格式:accoutid,mstarttime,mheartrate
                [updatedInfoString appendString:[NSString stringWithFormat:@"%@,%@,%@%@", userID, [BOTimeStampAssistor timeStampToTimeString:hrEntity.timeStamp.integerValue], hrEntity.heartRateValue, sFileNextLineFlag]];
            }
        }
    }
    //Test
    //[fileContentString appendFormat:@"545adbf5c23099ccbc000450,201412121130,74"];
    
    NSError *error = nil;
    if(![localInfoString writeToFile:localFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameHeartRateInfoLocal, error.userInfo);
    }
    if(![updatedInfoString writeToFile:updatedFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameHeartRateInfoUpdate, error.userInfo);
    }
}

- (void)mensesInfoSaveToFile:(BOOL)forceEmpty
{
    NSString *localMensesInfosString = @"";
    NSString *updatedMensesInfosString = @"";
    NSString *modifiedMensesInfosString = @"";
    
    if(!forceEmpty)
    {
        TYDMensesInfoAssistorSet *assistor = [TYDMensesInfoAssistorSet new];
        assistor.nextLineFlagString = sFileNextLineFlag;
        [assistor refreshInfosFromDataBase];
        localMensesInfosString = [assistor stringOfLocalInfos];
        updatedMensesInfosString = [assistor stringOfUpdatedInfos];
        modifiedMensesInfosString = [assistor stringOfModifiedInfos];
    }
    NSString *localFilePath = [self filePathWithFileName:sUploadFileNameMensesInfoLocal];
    NSString *updatedFilePath = [self filePathWithFileName:sUploadFileNameMensesInfoUpdate];
    NSString *modifiedFilePath = [self filePathWithFileName:sUploadFileNameMensesInfoModify];
    
    NSError *error = nil;
    if(![localMensesInfosString writeToFile:localFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameMensesInfoLocal, error.userInfo);
    }
    if(![updatedMensesInfosString writeToFile:updatedFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameMensesInfoUpdate, error.userInfo);
    }
    if(![modifiedMensesInfosString writeToFile:modifiedFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    {
        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameMensesInfoModify, error.userInfo);
    }
    
//    NSString *userID = [TYDUserInfo sharedUserInfo].userID;
//    CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
//    NSString *filePath = [self filePathWithFileName:sUploadFileNameMensesInfoUpdate];
//    
//    NSMutableString *fileContentString = [NSMutableString new];
//    NSFetchRequest *request = [self fetchRequestWithEntityName:sMensesInfoEntityName userID:userID];
//    NSArray *mensesInfos = [coreDataManager fetchObjectsWithRequest:request];
//    for(MensesInfoEntity *miEntity in mensesInfos)
//    {
//        //上传格式:accoutid,mstarttime,mtype
//        //mtype:(0,无操作，1，开始，2，结束)
//        [fileContentString appendFormat:@"%@,%@,%@", userID, [self mensesInfoTimeStampToString:miEntity.timeStamp.integerValue], @(TYDMensesInfoItemTypeStart)];
//        [fileContentString appendString:sFileNextLineFlag];//换行
//        [fileContentString appendFormat:@"%@,%@,%@", userID, [self mensesInfoTimeStampToString:miEntity.endTimeStamp.integerValue], @(TYDMensesInfoItemTypeEnd)];
//        [fileContentString appendString:sFileNextLineFlag];//换行
//    }
//    
//    NSError *error = nil;
//    if(![fileContentString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error])
//    {
//        NSLog(@"%@ fileSaveFailed:%@", sUploadFileNameMensesInfoUpdate, error.userInfo);
//    }
}

#pragma mark - UrlRequest

- (NSURLRequest *)zipFileUploadRequestWithZipData:(NSData *)zipData
                                           params:(NSDictionary *)params
{
    NSString *boundary = sHTTPRequestBoundary;
    NSString *zipFileName = sZipFileNameUpload;
    NSString *zipContentType = sZipContentType;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sServerUrlForFileUpload]];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 60;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //body
    NSMutableString *contentString = [NSMutableString new];
    for(NSString *key in params)
    {//appendParameters
        [contentString appendFormat:@"--%@\r\n", boundary];
        [contentString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
        [contentString appendFormat:@"%@\r\n", params[key]];
    }
    NSMutableData *body = [NSMutableData new];
    [body appendData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if(zipData.length > 0)
    {//appendFile
        NSString *name = @"datafile";
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, zipFileName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", zipContentType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:zipData];
        
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    return request;
}

- (NSURLRequest *)zipFileDownloadRequestWithParams:(NSDictionary *)params
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sServerUrlForFileDownload]];
    NSString *boundary = sHTTPRequestBoundary;
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 60;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *bodyString = [NSMutableString new];
    for(NSString *key in params)
    {//appendParameters
        [bodyString appendFormat:@"--%@\r\n", boundary];
        [bodyString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
        [bodyString appendFormat:@"%@\r\n", params[key]];
    }
    [bodyString appendFormat:@"--%@--\r\n", boundary];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

#pragma mark - Upload

- (void)requireForUploadInfo
{
    NSString *md5String = self.dataForUpload.description.MD5String;
    __weak typeof(self) wself = self;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:md5String forKey:@"uploadFileMd5"];
    [params setValue:@(1) forKey:@"action"];
    [params setValue:[TYDUserInfo sharedUserInfo].userID forKey:@"account"];
    
    NSURLRequest *request = [self zipFileUploadRequestWithZipData:nil params:params];
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"requireForUploadInfo response:%@", response);
        if(connectionError)
        {
            [wself requireForUploadInfoFailed:connectionError];
        }
        else
        {
            NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = wself.jsonParser;
            NSError *error = nil;
            NSDictionary *resultDic = [jsonParser objectWithString:resultString error:&error];
            [wself requireForUploadInfoComplete:resultDic];
        }
    }];
}

- (void)requireForUploadInfoComplete:(id)resultDic
{
    NSLog(@"requireForUploadInfoComplete:%@", resultDic);
    BOOL needToUpload = NO;
    NSNumber *resultNumber = resultDic[@"result"];
    if(resultNumber.integerValue == 0)
    {
        NSNumber *existNumber = resultDic[@"exist"];
        if(existNumber.integerValue == 1)
        {
            NSNumber *fileSizeNumber = resultDic[@"fileSize"];
            NSInteger zipFileLength = self.dataForUpload.length;
            NSInteger fileSize = fileSizeNumber.integerValue;
            if(fileSize != zipFileLength)
            {
                needToUpload = YES;
            }
        }
        else
        {
            needToUpload = YES;
        }
    }
    if(needToUpload)
    {
        [self uploadInfo];
    }
    else
    {
        [self cloudSynchronizeSucceed];
    }
}

- (void)requireForUploadInfoFailed:(NSError *)connectError
{
    NSLog(@"requireForUploadInfoFailed:%@", connectError.userInfo);
    [self cloudSynchronizeFailed];
}

- (void)uploadInfo
{
    __weak typeof(self) wself = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@(2) forKey:@"action"];
    [params setValue:[TYDUserInfo sharedUserInfo].userID forKey:@"account"];
    
    NSURLRequest *request = [self zipFileUploadRequestWithZipData:self.dataForUpload params:params];
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"uploadInfo response:%@", response);
        if(connectionError)
        {
            [wself uploadInfoFailed:connectionError];
        }
        else
        {
            NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = wself.jsonParser;
            NSError *error = nil;
            NSDictionary *resultDic = [jsonParser objectWithString:resultString error:&error];
            [wself uploadInfoComplete:resultDic];
        }
    }];
}

- (void)uploadInfoComplete:(id)resultDic
{
    NSLog(@"uploadInfoComplete:%@", resultDic);
    if(resultDic)
    {
        NSNumber *resultNumber = resultDic[@"result"];
        if(resultNumber.integerValue == 0)
        {
            //退出账号时，只上传，不下传
            if(self.csType == CloudSynchronizeTypeLogout)
            {
                [self cloudSynchronizeSucceed];
            }
            else
            {
                [self downloadInfo];
            }
        }
        else
        {
            [self cloudSynchronizeSucceed];
        }
    }
    else
    {
        [self cloudSynchronizeFailed];
    }
}

- (void)uploadInfoFailed:(NSError *)connectError
{
    NSLog(@"uploadInfoFailed:%@", connectError.userInfo);
    [self cloudSynchronizeFailed];
}

#pragma mark - Download

- (void)downloadInfo
{
    //暂不考虑断点续传，一律全传送
    __weak typeof(self) wself = self;
    NSString *userID = [TYDUserInfo sharedUserInfo].userID;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:userID forKey:@"account"];
    NSURLRequest *request = [self zipFileDownloadRequestWithParams:params];
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"downloadInfo response:%@", response);
        if(connectionError)
        {
            [wself downloadInfoFailed:connectionError];
        }
        else
        {
            [wself downloadInfoComplete:data];
        }
    }];
}

- (void)downloadInfoComplete:(id)resultData
{
    BOOL succeed = NO;
    NSData *data = resultData;
    if(data.length > 0)
    {
        NSString *zipFilePath = [self filePathWithFileName:sZipFileNameDownload];
        NSLog(@"zipFilePath:%@", zipFilePath);
        
        //[self cloudSynchroDirectoryClear];
        [data writeToFile:zipFilePath atomically:YES];
        ZipArchive *zipArchive = self.zipArchive;
        if([zipArchive UnzipOpenFile:zipFilePath])
        {
            BOOL zipActionResult = [zipArchive UnzipFileTo:self.resourceDirectory overWrite:YES];
            [zipArchive UnzipCloseFile];
            if(zipActionResult)
            {
                [self parseInfoFile];
                NSLog(@"parseInfoFileComplete");
                [self setNewCloudSynchronizeMarkTime];
                succeed = YES;
            }
        }
    }
    
    if(succeed)
    {
        [self cloudSynchronizeSucceed];
    }
    else
    {
        [self cloudSynchronizeFailed];
    }
}

- (void)downloadInfoFailed:(NSError *)connectionError
{
    NSLog(@"downloadInfoFailed:%@", connectionError.userInfo);
    [self cloudSynchronizeFailed];
}

#pragma mark - ParseFile

- (void)parseSportInfo
{
    NSError *error = nil;
    NSMutableArray *sportInfoArray = nil;
    NSString *filePath = [self filePathWithFileName:sDownloadFileNameSportInfo];
    NSString *sportInfosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if(!error && sportInfosText.length > 0)
    {
        sportInfoArray = [NSMutableArray new];
        int sportInfoItemCountPerInfo = 6;
        NSArray *sportInfoItems = [sportInfosText componentsSeparatedByString:sFileNextLineFlag];
        sportInfoItems = [[NSSet setWithArray:sportInfoItems] allObjects];//去重
        
        NSLog(@"sportInfoItems:%@", sportInfoItems);
        for(NSString *sportInfo in sportInfoItems)
        {
            //mTime,mSteps,mMileage,mCostTime,mSportType,mCalories
            NSArray *infoItems = [sportInfo componentsSeparatedByString:@","];
            if(infoItems.count >= sportInfoItemCountPerInfo)
            {
                TYDStepRecordInfo *info = [TYDStepRecordInfo new];
                info.timeStamp = [BOTimeStampAssistor timeStringToTimeStamp:infoItems[0]];
                info.stepCount = [infoItems[1] integerValue];
                info.distance = [infoItems[2] floatValue];
                info.endTimeStamp = [infoItems[3] integerValue] + info.timeStamp;
                info.calorie = [infoItems[5] floatValue];
                info.syncFlag = YES;
                
                [sportInfoArray addObject:info];
            }
        }
        
        TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
        for(TYDStepRecordInfo *stepInfo in sportInfoArray)
        {
            [dataCenter saveStepInfoToDataBaseDirectly:stepInfo];
        }
        
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sWalkStepInfoEntityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:NO]];
        NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
        NSMutableArray *deleteItems = [NSMutableArray new];
        for(WalkStepEntity *wsEntity in savedInfos)
        {
            if(wsEntity.syncFlag.boolValue == NO)
            {
                [deleteItems addObject:wsEntity];
            }
        }
        [coreDataManager deleteObjects:deleteItems];
    }
}

- (void)parseHeartRateInfo
{
    NSError *error = nil;
    NSMutableArray *heartRateInfoArray = nil;
    NSString *filePath = [self filePathWithFileName:sDownloadFileNameHeartReartInfo];
    NSString *heartRateInfosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if(!error && heartRateInfosText.length > 0)
    {
        heartRateInfoArray = [NSMutableArray new];
        int heartRateInfoItemCountPerInfo = 2;
        NSArray *heartRateInfoItems = [heartRateInfosText componentsSeparatedByString:sFileNextLineFlag];
        heartRateInfoItems = [[NSSet setWithArray:heartRateInfoItems] allObjects];//去重
        
        //NSLog(@"heartRateInfoItems:%@", heartRateInfoItems);
        for(NSString *heartRateInfo in heartRateInfoItems)
        {
            //mstarttime,mheartrate
            NSArray *infoItems = [heartRateInfo componentsSeparatedByString:@","];
            if(infoItems.count >= heartRateInfoItemCountPerInfo)
            {
                TYDHeartRateRecordInfo *info = [TYDHeartRateRecordInfo new];
                info.timeStamp = [BOTimeStampAssistor timeStringToTimeStamp:infoItems[0]];
                info.heartRate = [infoItems[1] integerValue];
                info.syncFlag = YES;
                
                [heartRateInfoArray addObject:info];
            }
        }
        TYDDataCenter *dataCenter = [TYDDataCenter defaultCenter];
        for(TYDHeartRateRecordInfo *hrInfo in heartRateInfoArray)
        {
            [dataCenter saveHeartRateInfoToDataBaseDirectly:hrInfo];
        }
        
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sHeartRateInfoEntityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:NO]];
        NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
        NSMutableArray *deleteItems = [NSMutableArray new];
        for(HeartRateEntity *hrEntity in savedInfos)
        {
            if(hrEntity.syncFlag.boolValue == NO)
            {
                [deleteItems addObject:hrEntity];
            }
        }
        [coreDataManager deleteObjects:deleteItems];
    }
}

- (void)parseMensesInfo
{
    NSError *error = nil;
    NSMutableArray *mensesInfoArray = nil;
    NSString *filePath = [self filePathWithFileName:sDownloadFileNameMensesInfo];
    NSString *mensesInfosText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if(!error && mensesInfosText.length > 0)
    {
        mensesInfoArray = [NSMutableArray new];
        int mensesInfoItemCountPerInfo = 2;
        NSArray *mensesInfoItems = [mensesInfosText componentsSeparatedByString:sFileNextLineFlag];
        //去重排序
        NSSet *mensesInfoSet = [NSSet setWithArray:mensesInfoItems];
        mensesInfoItems = [[mensesInfoSet allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSMutableArray *itemsTemple = [NSMutableArray new];
        for(NSString *info in mensesInfoItems)
        {
            if(info.length > 0)
            {
                //mstarttime,mtype
                NSArray *infoItems = [info componentsSeparatedByString:@","];
                if(infoItems.count >= mensesInfoItemCountPerInfo)
                {
                    int infoType = [infoItems[1] intValue];
                    if(infoType != TYDMensesInfoItemTypeNone)
                    {
                        TYDMensesTransformInfo *transformInfo = [TYDMensesTransformInfo new];
                        transformInfo.timeStamp = infoItems[0];
                        transformInfo.type = infoType;
                        [itemsTemple addObject:transformInfo];
                    }
                }
            }
        }
        
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:sMensesInfoEntityName];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sTimeStampAttributeNameInEntity ascending:NO]];
        NSArray *savedInfos = [coreDataManager fetchObjectsWithRequest:request];
        NSMutableArray *deleteInfos = [NSMutableArray new];
        for(MensesInfoEntity *miEntity in savedInfos)
        {
            if(miEntity.syncFlag.boolValue == YES)
            {
                if(miEntity.modifiedFlag.boolValue == YES)
                {
                    [deleteInfos addObject:miEntity];
                }
            }
            else
            {
                miEntity.syncFlag = @YES;
                miEntity.modifiedFlag = @NO;
            }
        }
        [coreDataManager saveContext];
        [coreDataManager deleteObjects:deleteInfos];
        
        for(int index = 1; index < itemsTemple.count; )
        {
            TYDMensesTransformInfo *transform0 = itemsTemple[index - 1];
            TYDMensesTransformInfo *transform1 = itemsTemple[index];
            if(transform0.type == TYDMensesInfoItemTypeStart
               && transform1.type == TYDMensesInfoItemTypeEnd)
            {
                TYDMensesInfo *mensesInfo = [TYDMensesInfo new];
                mensesInfo.timeStamp = [self mensesInfoTimeStringToTimeStamp:transform0.timeStamp];
                mensesInfo.endTimeStamp = [self mensesInfoTimeStringToTimeStamp:transform1.timeStamp];
                mensesInfo.syncFlag = YES;
                mensesInfo.modifiedFlag = NO;
                
                [mensesInfoArray addObject:mensesInfo];
                index += 2;
                continue;
            }
            index++;
        }
        
        TYDMensesDataCenter *mensesDataCenter = [TYDMensesDataCenter defaultCenter];
        for(TYDMensesInfo *mensesInfo in mensesInfoArray)
        {
            [mensesDataCenter saveOneMensesRecordInfo:mensesInfo];
        }
    }
}

- (void)parseInfoFile
{
    if(self.csType == CloudSynchronizeTypeLogin)
    {//登录时，导入数据前，清空本地数据
        CoreDataManager *coreDataManager = [CoreDataManager defaultManager];
        [coreDataManager deleteAllObjectsWithEntityName:sWalkStepInfoEntityName];
        [coreDataManager deleteAllObjectsWithEntityName:sHeartRateInfoEntityName];
        [coreDataManager deleteAllObjectsWithEntityName:sMensesInfoEntityName];
    }
    
    [self parseSportInfo];
    [self parseHeartRateInfo];
    [self parseMensesInfo];
    
    //[[TYDDataCenter defaultCenter] reloadInfosFromDataBase];
    [[TYDMensesDataCenter defaultCenter] reloadInfosFromDataBase];
}

#pragma mark - DelegateEvent

- (void)cloudSynchronizeEventStart
{
    //_isInCloudSynchronizeDuration = YES;
    if([self.delegate respondsToSelector:@selector(cloudSynchronizeEventStart)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cloudSynchronizeEventStart];
        });
    }
}

- (void)cloudSynchronizeEventComplete:(BOOL)succeed
{
    CloudSynchronizeType type = self.csType;
    self.csType = CloudSynchronizeTypeNormal;
    
    NSLog(@"cloudSynchronizeEventComplete");
    switch(type)
    {
        case CloudSynchronizeTypeLogin:
            [self loginCloudSynchronizeEventComplete:succeed];
            break;
        case CloudSynchronizeTypeLogout:
            [self logoutCloudSynchronizeEventComplete:succeed];
            break;
        case CloudSynchronizeTypeNormal:
        default:
            [self normalCloudSynchronizeEventComplete:succeed];
            break;
    }
    //_isInCloudSynchronizeDuration = NO;
}

- (void)normalCloudSynchronizeEventComplete:(BOOL)succeed
{
//    if(self.csType != CloudSynchronizeTypeNormal)
//    {
//        return;
//    }
    
    if([self.delegate respondsToSelector:@selector(cloudSynchronizeEventComplete:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate cloudSynchronizeEventComplete:succeed];
        });
    }
}

- (void)loginCloudSynchronizeEventComplete:(BOOL)succeed
{
//    if(self.csType != CloudSynchronizeTypeLogin)
//    {
//        return;
//    }
    
    if([self.loginDelegate respondsToSelector:@selector(loginCloudSynchronizeEventComplete:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loginDelegate loginCloudSynchronizeEventComplete:succeed];
        });
    }
}

- (void)logoutCloudSynchronizeEventComplete:(BOOL)succeed
{
//    if(self.csType != CloudSynchronizeTypeLogout)
//    {
//        return;
//    }
    //对于退出时数据上传成功，同时清空上次同步成功标记时间
    [self clearCloudSynchronizeMarkTime];
    if([self.logoutDelegate respondsToSelector:@selector(logoutCloudSynchronizeEventComplete:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.logoutDelegate logoutCloudSynchronizeEventComplete:succeed];
        });
    }
}

#pragma mark - CloudSynchronize

- (void)cloudSynchronizeFailed
{
    self.dataForUpload = nil;
    [self cloudSynchronizeEventComplete:NO];
}

- (void)cloudSynchronizeSucceed
{
    self.dataForUpload = nil;
    [self cloudSynchronizeEventComplete:YES];
}

- (void)cloudSynchronize
{
//    //if(self.isInCloudSynchronizeDuration)
//    if([TYDDataCenter defaultCenter].cloudSynchronizeLocked)
//    {
//        return;
//    }
    
    NSLog(@"cloudSynchronize:%@", self.resourceDirectory);
//    if(self.csType == CloudSynchronizeTypeNormal)
//    {
//        [self cloudSynchronizeEventStart];
//    }
    [self requireForUploadInfo];
}

//file:///Users/caiyajie/Library/Developer/CoreSimulator/Devices/E01BBD85-95FD-481E-AFEE-0D0BE9E7EA81/data/Containers/Data/Application/89E4E692-4024-488F-9836-D1F85D833644/tmp/cloudSynchronous

#pragma mark - TimeString

- (NSString *)mensesInfoTimeStampToString:(NSInteger)time
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMdd";
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

- (NSTimeInterval)mensesInfoTimeStringToTimeStamp:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyyMMdd";
    //dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    return [[dateFormatter dateFromString:timeString] timeIntervalSince1970];
}

#pragma mark - UserLogout

- (void)clearCloudSynchronizeMarkTime
{
    //清空上次同步成功标记时间
    _cloudSynchronizeMarkTime = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:_cloudSynchronizeMarkTime forKey:sCloudSynchronizeTimeMark];
    [userDefaults synchronize];
}

- (void)cloudSynchronizeWhenUserLogout
{
    self.csType = CloudSynchronizeTypeLogout;
    [self cloudSynchronize];
}

#pragma mark - UserLogin

- (void)cloudSynchronizeWhenUserLogin
{
    self.csType = CloudSynchronizeTypeLogin;
    [self cloudSynchronize];
}

#pragma mark - ZipArchiveDelegate

- (void)ErrorMessage:(NSString *)msg
{
    NSLog(@"%@", msg);
}

- (BOOL)OverWriteOperation:(NSString *)file
{
    return YES;
}

@end
