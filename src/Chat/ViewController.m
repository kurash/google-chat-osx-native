//
//  ViewController.m
//  Chat
//
//  Created by Mark Valence on 1/8/18.
//  Copyright © 2018 Sassafras Software Inc. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self.webView setApplicationNameForUserAgent:@"Version/11.1.2 Safari/605.1.15"];

	notificationProvider = [[NotificationProvider alloc] init];
	[self.webView _setNotificationProvider:notificationProvider];

	[self.webView setFrameLoadDelegate:self];
	[self.webView setPolicyDelegate:self];
	[self.webView setUIDelegate:self];
	[self.webView setResourceLoadDelegate:self];

	[self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://chat.google.com"]]];
}

- (BOOL)windowShouldClose:(id)sender
{
	[sender setIsVisible:NO];
	return NO;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.view.window.delegate = self;
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[notificationProvider clearNotifications:nil];
}

#pragma mark FrameLoadDelegate

- (void)handleNetworkError:(NSError *)error forWebView:(WebView *)view
{
	NSString *failingURL = [error.userInfo valueForKey:@"NSErrorFailingURLStringKey"];
	if (!failingURL)
		failingURL = @"";

	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Retry"];
	[alert addButtonWithTitle:@"Quit"];
	[alert setMessageText:@"Unable to connect to Chat"];
	[alert setInformativeText:[[NSString alloc] initWithFormat:@"Check your internet connection.  URL: %@", failingURL]];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert beginSheetModalForWindow:self.webView.window completionHandler:^(NSModalResponse responseCode) {
		if (responseCode == NSAlertFirstButtonReturn)
			[view setMainFrameURL:@"https://chat.google.com"];
		else
			[NSApp stop:self];
	}];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	[self handleNetworkError:error forWebView:sender];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	[self handleNetworkError:error forWebView:sender];
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName decisionListener:(id <WebPolicyDecisionListener>)listener
{
	// route all links that request a new window to default browser
	[listener ignore];
	[[NSWorkspace sharedWorkspace] openURL:[request URL]];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	[listener use];
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
	if ([type isEqualToString:@"application/zip"])
		[listener download];
}

- (void)webView:(WebView *)webView unableToImplementPolicyWithError:(NSError *)error frame:(WebFrame *)frame
{
	NSLog(@"POLICY: %@", error);
}

#pragma mark WebUIDelegate

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"Please confirm"];
	[alert setInformativeText:message];
	[alert setAlertStyle:NSInformationalAlertStyle];
	return [alert runModal] == NSAlertFirstButtonReturn;
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:@"Chat"];
	[alert setInformativeText:message];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert runModal];
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary
{
	NSLog(@"ERROR: %@", [dictionary objectForKey:@"message"]);
}

- (void)webView:(WebView *)sender runOpenPanelForFileButtonWithResultListener:(id < WebOpenPanelResultListener >)resultListener
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:NO];

	if ([openDlg runModal] == NSModalResponseOK) {
		NSArray* files = [[openDlg URLs] valueForKey:@"relativePath"];
		[resultListener chooseFilenames:files];
	}
}

#pragma mark WebResourceLoadDelegate

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
	static long ident = 0;
	ident++;
	return [NSString stringWithFormat:@"%ld", ident];
}

- (NSURLRequest *)webView:(WebView *)sender
				 resource:(id)identifier
		  willSendRequest:(NSURLRequest *)request
		 redirectResponse:(NSURLResponse *)redirectResponse
		   fromDataSource:(WebDataSource *)dataSource
{
	NSString *str = [[request URL] absoluteString];
	if ([str hasPrefix:@"https://notifications.google.com/u/0/widget"]
		|| [str hasPrefix:@"https://play.google.com/"]
		|| [str hasPrefix:@"https://www.google.com/insights/consumersurveys"]
		|| [str hasPrefix:@"https://ogs.google.com/u/0/_/notifications/count"])
	{
		NSLog(@"REJECTING: %@", str);
		return nil;
	}
	NSLog(@"REQUESTING: %@ %@", identifier, str);
	return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
	//NSLog(@"REQUEST: %@", error);
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
	NSLog(@"RECEIVED: %@", identifier);
}

@end
