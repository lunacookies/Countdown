@import AppKit;

static const NSNotificationName PreferencesDidChangeNotification =
        @"org.xoria.Countdown.PreferencesDidChangeNotification";

#include "AppDelegate.h"
#include "Preferences.h"
#include "EditWindowController.h"
#include "SettingsWindowController.h"
#include "CountdownEditorViewController.h"

#include "AppDelegate.m"
#include "Preferences.m"
#include "EditWindowController.m"
#include "SettingsWindowController.m"
#include "CountdownEditorViewController.m"

int main(void) {
	[NSApplication sharedApplication];
	AppDelegate *appDelegate = [[AppDelegate alloc] init];
	NSApp.delegate = appDelegate;
	[NSApp run];
}
