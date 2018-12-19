//
//  AppDelegate.m
//  Chat
//
//  Created by Mark Valence on 1/8/18.
//  Copyright © 2018 Sassafras Software Inc. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"NSQuitAlwaysKeepsWindows"];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	for (NSWindow *win in [NSApp windows])
		[win setIsVisible:YES];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)app hasVisibleWindows:(BOOL)flag
{
	if (!flag) {
		for (NSWindow *win in [NSApp windows])
			[win setIsVisible:YES];
	} else {
		for (NSWindow *win in [NSApp windows]) {
			if ([win isMiniaturized])
				[win deminiaturize:win];
		}
	}
	return NO;
}

@end
