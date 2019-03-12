//
//  XMPPManager.m
//  XMPPTest
//
//  Created by Neil on 2019/3/12.
//  Copyright © 2019 Neil. All rights reserved.
//

#import "XMPPManager.h"
#import <XMPPRosterCoreDataStorage.h>
#import <XMPPMessageArchivingCoreDataStorage.h>

// server host
static NSString *const kHostName = @"60.248.166.71";
// server port
static UInt16 const kHostPort = 5222;

// connect type
typedef NS_ENUM(NSUInteger,ConnectToServerStatus) {
    ConnectToServerStatusLogin,
    ConnectToServerStatusRegist,
};

@interface XMPPManager ()
@property (nonatomic,strong)NSString *loginpassword;
@property (nonatomic,strong)NSString *registpassword;
@property (nonatomic,assign)ConnectToServerStatus connectToSercerStatus;

@end

@implementation XMPPManager

+ (XMPPManager *)sharedXMPPManager{
    static XMPPManager *xmppManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        xmppManager = [[XMPPManager alloc] init];
    });
    return xmppManager;
}

- (instancetype)init{
    if ([super init]) {
        self.stream = [[XMPPStream alloc] init];
        self.stream.hostName = kHostName;
        self.stream.hostPort = kHostPort;
        // set stream delegate.
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        XMPPRosterCoreDataStorage *rosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
        self.roster = [[XMPPRoster alloc] initWithRosterStorage:rosterStorage dispatchQueue:dispatch_get_main_queue()];
        // activate stream.
        [self.roster activate:self.stream];
        
        XMPPMessageArchivingCoreDataStorage *_messageArchiving = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_messageArchiving dispatchQueue:dispatch_get_main_queue()];
        [self.messageArchiving activate:self.stream];
        
        self.managerObjectContext = _messageArchiving.mainThreadManagedObjectContext;
    }
    return self;
}

#pragma Connect to server.
-(void)connectToServerWithUser:(NSString *)user{
    if ([self.stream isConnected]) {
        [self disconnectServer];
    }
    XMPPJID *jid = [XMPPJID jidWithUser:user domain:@"DH_Fantasy" resource:@"iPhone"];
    self.stream.myJID = jid;
    NSError *error = nil;
    [self.stream connectWithTimeout:30.0f error:&error];
    if (nil != error) {
        NSLog(@"%s_%d_connect fail：%@",__FUNCTION__,__LINE__,error);
    }
}


-(void)disconnectServer{
    [self.stream disconnect];
}

- (void)loginWithUserName:(NSString *)userName password:(NSString *)password{
    self.connectToSercerStatus = ConnectToServerStatusLogin;
    self.loginpassword = password;
    [self connectToServerWithUser:userName];
}

- (void)registWithUserName:(NSString *)userName password:(NSString *)password{
    self.connectToSercerStatus = ConnectToServerStatusRegist;
    self.registpassword = password;
    [self connectToServerWithUser:userName];
}

#pragma mark XMPPStreamDelegate

-(void)xmppStreamDidConnect:(XMPPStream *)sender{

    switch (self.connectToSercerStatus) {
        case ConnectToServerStatusLogin:
        {
            NSError *error = nil;
            [self.stream authenticateWithPassword:self.loginpassword error:&error];
            if (nil != error) {
                NSLog(@"%s_%d_verification fail：%@",__FUNCTION__,__LINE__,error);
            }
            break;
        }
        case ConnectToServerStatusRegist:
        {
            NSError *err = nil;
            [self.stream registerWithPassword:self.registpassword error:&err];
            if (nil != err) {
                NSLog(@"%s_%d_regist fail：%@",__FUNCTION__,__LINE__,err);
            }
            break;
        }
        default:
            break;
    }
}

#pragma Connect timeout.
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"Connect  timeout.");
}

- (void)xmppStreamWillConnect:(XMPPStream *)sender {
    NSLog(@"Connecting...");
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    NSLog(@"Connect success.");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"XMPP authorize fail.%@", error.description);
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"XMPP auhorize success.");
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"XMPP connect lost.");
}

@end
