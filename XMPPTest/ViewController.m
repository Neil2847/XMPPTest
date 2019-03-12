//
//  ViewController.m
//  XMPPTest
//
//  Created by Neil on 2019/3/12.
//  Copyright © 2019 Neil. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // XMPP init.
    [[XMPPManager sharedXMPPManager].stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (IBAction)login:(UIButton *)sender {
    
    [[XMPPManager sharedXMPPManager] loginWithUserName:@"ios02" password:@"ios02"];
}


- (IBAction)sendMessage:(UIButton *)sender {
    
    XMPPJID *jid = [XMPPJID jidWithUser:@"android01" domain:@"60.248.166.71" resource:@"60.248.166.71"];
    
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    // write something...
    [message addBody:@"Hi,can you see me?"];
    // send message.
    [[XMPPManager sharedXMPPManager].stream sendElement:message];
}

#pragma Verification success
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    // Change APP login status.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoginStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // The default mode is offline,need response to server current status.
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager sharedXMPPManager].stream sendElement:presence];
    
    // Back to root.
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma Verification fail
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"Verification fail.");
}


#pragma Send message success
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"Send message success.");
}

#pragma Send message fail
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"Send message fail.");
}

#pragma Receive message
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    if ([message isChatMessageWithBody]) {
        NSLog(@"%@",[message body]);
    }
}

@end
