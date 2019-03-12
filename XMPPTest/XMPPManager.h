//
//  XMPPManager.h
//  XMPPTest
//
//  Created by Neil on 2019/3/12.
//  Copyright © 2019 Neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPP.h>
#import <XMPPRoster.h>
#import <XMPPMessageArchiving.h>

NS_ASSUME_NONNULL_BEGIN

@interface XMPPManager : NSObject<XMPPStreamDelegate>

+ (XMPPManager *)sharedXMPPManager;

#pragma Messgae stream.
@property (nonatomic,strong)XMPPStream *stream;

#pragma get/delete/add to friends list.
@property (nonatomic,strong)XMPPRoster *roster;


#pragma Message saved.
@property (nonatomic,strong)XMPPMessageArchiving *messageArchiving;

@property (nonatomic,strong)NSManagedObjectContext *managerObjectContext;

#pragma Sign in
- (void)loginWithUserName:(NSString *)userName password:(NSString *)password;

#pragma Regist
- (void)registWithUserName:(NSString *)userName password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
