//
//  ZegoLocalEnvManager.m
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/24.
//

#import "ZegoLocalEnvManager.h"

@implementation ZegoLocalEnvManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static ZegoLocalEnvManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZegoLocalEnvManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _userName = [[NSUserDefaults standardUserDefaults] valueForKey:ZegoLoginUserName];
        _roomID = [[NSUserDefaults standardUserDefaults] valueForKey:ZegoLoginRoomID];
        _roomSeviceTestEnv = [[NSUserDefaults standardUserDefaults] boolForKey:ZegoRoomSeviceTestEnv];
        _docsSeviceTestEnv = [[NSUserDefaults standardUserDefaults] boolForKey:ZegoDocsSeviceTestEnv];
        _enableCutomFont = [[NSUserDefaults standardUserDefaults] boolForKey:ZegoEnableCustomFont];
        _domain = [[NSUserDefaults standardUserDefaults] objectForKey:ZegoDomain];
        _roomSeviceTestEnv = NO;
        _docsSeviceTestEnv = NO;
        if(_domain.length == 0) _domain = @"https://cloudrecord-sh.zego.im";
        DLog(@"LocalEnvInit,userName:%@,roomID:%@,docsServiceTextEnv:%d,roomServiceTextEnv:%d,customFont:%d,_domain:%@",_userName,_roomID,_docsSeviceTestEnv,_roomSeviceTestEnv,_enableCutomFont,_domain);
    }
    return self;
}

- (void)setupRoomSeviceTestEnv:(BOOL)env {
    _roomSeviceTestEnv = env;
    [[NSUserDefaults standardUserDefaults] setBool:env forKey:ZegoRoomSeviceTestEnv];
    DLog(@"settingRoomSeviceTestEnv,result:%d",env?1:0);
    
}

- (void)setupDocsSeviceTestEnv:(BOOL)env {
    _docsSeviceTestEnv = env;
    [[NSUserDefaults standardUserDefaults] setBool:env forKey:ZegoDocsSeviceTestEnv];
    DLog(@"settingDocsSeviceTestEnv,result:%d",env?1:0);
}

- (void)setupCurrentUserName:(NSString *)userName roomID:(NSString *)roomID {
    _userName = userName;
    _roomID = roomID;
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:ZegoLoginUserName];
    [[NSUserDefaults standardUserDefaults] setValue:roomID forKey:ZegoLoginRoomID];
    DLog(@"settingUserName:%@,RoomID:%@",userName,roomID);
}

- (void)setupEnableCustomFont:(BOOL)enable {
    _enableCutomFont = enable;
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:ZegoEnableCustomFont];
    DLog(@"settingCustomFont,result:%d",enable?1:0);
}

- (void)setupDomain:(NSString *)domain
{
    _domain = domain;
    [[NSUserDefaults standardUserDefaults] setObject:domain forKey:ZegoDomain];
    DLog(@"setupDomain %@",domain);

}

- (NSString *)userID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserIDKey];
}


@end
