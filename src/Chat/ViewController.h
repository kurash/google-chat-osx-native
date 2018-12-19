//
//  ViewController.h
//  Chat
//
//  Created by Mark Valence on 1/8/18.
//  Copyright © 2018 Sassafras Software Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "NotificationProvider.h"

@interface ViewController : NSViewController <NSWindowDelegate, WebFrameLoadDelegate, WebUIDelegate, WebPolicyDelegate, WebResourceLoadDelegate> {
	NotificationProvider *notificationProvider;
}

@property (weak) IBOutlet WebView *webView;

@end

