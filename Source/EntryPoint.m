@import AppKit;

static const NSNotificationName CountdownDidChangeNotification = @"org.xoria.Countdown.CountdownDidChangeNotification";

static const NSNotificationName CountdownStoreDidChangeNotification =
        @"org.xoria.Countdown.CountdownStoreDidChangeNotification";

static const NSNotificationName SettingsDidChangeNotification = @"org.xoria.Countdown.SettingsDidChangeNotification";

#include "AppDelegate.h"
#include "Countdown.h"
#include "Settings.h"
#include "EditWindowController.h"
#include "SettingsWindowController.h"
#include "CountdownEditorViewController.h"

#include "AppDelegate.m"
#include "Countdown.m"
#include "Settings.m"
#include "EditWindowController.m"
#include "SettingsWindowController.m"
#include "CountdownEditorViewController.m"

int main(void) {
	[NSApplication sharedApplication];
	AppDelegate *appDelegate = [[AppDelegate alloc] init];
	NSApp.delegate = appDelegate;
	[NSApp run];
}
