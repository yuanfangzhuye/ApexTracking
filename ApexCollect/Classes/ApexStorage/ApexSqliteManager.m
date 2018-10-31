//
//  ApexSqliteManager.m
//  ApexTracker
//
//  Created by 李超 on 2018/10/22.
//  Copyright © 2018 LiChao. All rights reserved.
//

#import "ApexSqliteManager.h"
#import "sqlite3.h"

const NSString *kErrorDomain = @"com.chinapex.ChinapexAnalytics.ErrorDomain";

const NSInteger kErrorDatabaseNotOpened = 1001;
const NSInteger kErrorDatabaseNotClosed = 1002;
const NSInteger kErrorDatabaseQueryFail = 1003;

@interface ApexSqliteManager ()

@property (assign, nonatomic) sqlite3 *dataManager;

@end

@implementation ApexSqliteManager

+ (instancetype)sharedSqliteManager
{
    static ApexSqliteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (NSString *)getDataManagerPath
{
    NSString *dataPathDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *databasePath = [dataPathDirectory stringByAppendingPathComponent:ApexSqliteName];
    
    [[PEXLogger sharedInstance] debug:[NSString stringWithFormat:@"dataManagerPath：%@", databasePath]];
    
    return databasePath;
}

- (NSError *)createUserTableWithTrackingID:(NSString *)trackingID
{
    NSString *sql = [NSString stringWithFormat:@"create table if not exists `%@` (id INTEGER PRIMARY KEY AUTOINCREMENT, type CHAR(20), content TEXT);", trackingID];
    
    NSError *error = nil;
    
    const char *dataPath = [[self getDataManagerPath] UTF8String];
    int openResult = sqlite3_open(dataPath, &_dataManager);
    
    if (openResult != SQLITE_OK) {
        const char *errorMessage = sqlite3_errmsg(self.dataManager);
        NSString *errorDescription = [NSString stringWithFormat:@"%@:%@", @"apexError_database_not_opened", [NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]];
        
        [[PEXLogger sharedInstance] debug:errorDescription];
        error = [NSError errorWithDomain:[kErrorDomain copy] code:kErrorDatabaseNotClosed userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
    }
    else {
        [[PEXLogger sharedInstance] debug:@"读取数据库中队列数据成功"];
        [self update:sql with:nil error:&error];
    }
    
    return error;
}

//关闭数据库
- (NSError *)closeDatabaseManager
{
    NSError *error = nil;
    if (self.dataManager != nil) {
        if (sqlite3_close(self.dataManager) != SQLITE_OK) {
            const char *errorMsg = sqlite3_errmsg(self.dataManager);
            NSString *errorStr = [NSString stringWithFormat: @"%@:%@", @"apexError_database_close_fail", [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]];
            error = [NSError errorWithDomain:[kErrorDomain copy]
                                        code:kErrorDatabaseNotClosed
                                    userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        }
        
        self.dataManager = nil;
    }
    
    return error;
}

//查询
- (NSArray *)query:(NSString *)sql error:(NSError **)error
{
    NSMutableArray *queryArray = [[NSMutableArray alloc] init];
    if (self.dataManager == nil) {
        *error = [NSError errorWithDomain:[kErrorDomain copy] code:kErrorDatabaseNotClosed userInfo:@{NSLocalizedDescriptionKey : @"please open database first"}];
        return @[];
    }
    
    sqlite3_stmt *statement;
    const char *query = [sql UTF8String];
    
    int returnCode = sqlite3_prepare_v2(self.dataManager, query, -1, &statement, NULL);
    if (returnCode != SQLITE_OK) {
        const char *errorMessage = sqlite3_errmsg(self.dataManager);
        NSString *errorDescription = [NSString stringWithFormat:@"%@:%@", @"apexError_database_query_fail", [NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]];
        *error = [NSError errorWithDomain:[kErrorDomain copy] code:kErrorDatabaseQueryFail userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        
        return @[];
    }
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        int columns = sqlite3_column_count(statement);
        NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] initWithCapacity:columns];
        
        for (int i = 0; i < columns; i++) {
            const char *name = sqlite3_column_name(statement, i);
            NSString *columnNameString = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            int type = sqlite3_column_type(statement, i);
            switch (type) {
                case SQLITE_INTEGER:
                {
                    int value = sqlite3_column_int(statement, i);
                    [queryDictionary setObject:[NSNumber numberWithInt:value] forKey:columnNameString];
                }
                    break;
                    case SQLITE_FLOAT:
                {
                    double value = sqlite3_column_double(statement, i);
                    [queryDictionary setObject:[NSNumber numberWithDouble:value] forKey:columnNameString];
                }
                    break;
                case SQLITE_BLOB:
                {
                    int bytes = sqlite3_column_bytes(statement, i);
                    if (bytes > 0) {
                        const void *value = sqlite3_column_blob(statement, i);
                        if (value != NULL) {
                            [queryDictionary setObject:[NSData dataWithBytes:value length:bytes] forKey:columnNameString];
                        }
                    }
                }
                    break;
                case SQLITE_NULL:
                {
                    [queryDictionary setObject:[NSNull null] forKey:columnNameString];
                }
                    break;
                case SQLITE_TEXT:
                {
                    const char *value = (const char *)sqlite3_column_text(statement, i);
                    [queryDictionary setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnNameString];
                }
                    break;
                default:
                {
                    const char *value = (const char *)sqlite3_column_text(statement, i);
                    [queryDictionary setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnNameString];
                }
                    break;
            }
        }
        
        [queryArray addObject:queryDictionary];
    }
    
    sqlite3_finalize(statement);
    
    return queryArray;
}

//更新
- (int64_t)update:(NSString *)sql with:(NSArray *)params error:(NSError *__autoreleasing *)error
{
    if (self.dataManager == nil) {
        *error = [NSError errorWithDomain:[kErrorDomain copy]
                                     code:kErrorDatabaseNotOpened
                                 userInfo:@{NSLocalizedDescriptionKey:@"apexError_database_not_opened"}];
        return 0;
    }

    sqlite3_stmt *statement;
    const char *query = [sql UTF8String];
    sqlite3_prepare_v2(self.dataManager, query, -1, &statement, NULL);
    
    int paramscount = 0;
    for (id param  in params) {
        paramscount++;
        if ([param isKindOfClass:[NSString class]]) {
            const char *c = [param UTF8String];
            sqlite3_bind_text(statement, paramscount, c, -1, SQLITE_TRANSIENT);
        }
        
        if ([param isKindOfClass:[NSNumber class]]) {
            if (strcmp([param objCType], @encode(float)) == 0) {
                sqlite3_bind_double(statement, paramscount, [param doubleValue]);
            }
            else if (strcmp([param objCType], @encode(int)) == 0) {
                sqlite3_bind_int(statement, paramscount, [param intValue]);
            }
            else if (strcmp([param objCType], @encode(Boolean)) == 0) {
                sqlite3_bind_int(statement, paramscount, [param intValue]);
            }
            else {
                [[PEXLogger sharedInstance] debug:@"unknown NSNumber"];
            }
        }
        
        if ([param isKindOfClass:[NSDate class]]) {
            sqlite3_bind_double(statement, paramscount, [param timeIntervalSince1970]);
        }
        
        if ([param isKindOfClass:[NSData class]]) {
            sqlite3_bind_blob(statement, paramscount, [param bytes], (int)[param length], SQLITE_STATIC);
        }
    }

    if (sqlite3_step(statement) == SQLITE_ERROR) {
        const char *errorMsg = sqlite3_errmsg(self.dataManager);
        NSString *errorStr = [NSString stringWithFormat: @"%@:%@", @"apexError_database_query_fail", [NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]];
        *error = [NSError errorWithDomain:[kErrorDomain copy]
                                     code:kErrorDatabaseQueryFail
                                 userInfo:@{NSLocalizedDescriptionKey:errorStr}];
        return 0;
    }
    sqlite3_finalize(statement);
    
    return 0;
}

@end
