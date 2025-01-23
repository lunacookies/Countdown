@implementation AppDelegate {
	EditWindowController *_editWindowController;
	SettingsWindowController *_settingsWindowController;
	NSMutableArray<NSStatusItem *> *_countdownStatusItems;
	NSStatusItem *_emptyStateStatusItem;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSString *displayName = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];

	NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"Main Menu"];

	{
		NSMenuItem *appMenuItem = [mainMenu addItemWithTitle:displayName action:nil keyEquivalent:@""];
		NSMenu *appMenu = [[NSMenu alloc] initWithTitle:displayName];
		appMenuItem.submenu = appMenu;

		[appMenu addItemWithTitle:[NSString stringWithFormat:@"About %@", displayName]
		                   action:@selector(orderFrontStandardAboutPanel:)
		            keyEquivalent:@""];

		[appMenu addItem:[NSMenuItem separatorItem]];
		[appMenu addItemWithTitle:@"Settings…" action:nil keyEquivalent:@","];
		[appMenu addItem:[NSMenuItem separatorItem]];

		NSMenuItem *servicesMenuItem = [appMenu addItemWithTitle:@"Services" action:nil keyEquivalent:@""];
		NSMenu *servicesMenu = [[NSMenu alloc] initWithTitle:@"Services"];
		servicesMenuItem.submenu = servicesMenu;
		NSApp.servicesMenu = servicesMenu;

		[appMenu addItem:[NSMenuItem separatorItem]];
		[appMenu addItemWithTitle:[NSString stringWithFormat:@"Hide %@", displayName]
		                   action:@selector(hide:)
		            keyEquivalent:@"h"];

		[appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"]
		        .keyEquivalentModifierMask |= NSEventModifierFlagOption;

		[appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
		[appMenu addItem:[NSMenuItem separatorItem]];

		[appMenu addItemWithTitle:[NSString stringWithFormat:@"Quit %@", displayName]
		                   action:@selector(terminate:)
		            keyEquivalent:@"q"];
	}

	{
		NSMenuItem *fileMenuItem = [mainMenu addItemWithTitle:@"File" action:nil keyEquivalent:@""];
		NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
		fileMenuItem.submenu = fileMenu;

		[fileMenu addItemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n"];
		[fileMenu addItemWithTitle:@"Open…" action:@selector(openDocument:) keyEquivalent:@"o"];

		NSMenuItem *openRecentMenuItem = [fileMenu addItemWithTitle:@"Open Recent" action:nil keyEquivalent:@""];
		NSMenu *openRecentMenu = [[NSMenu alloc] initWithTitle:@"Open Recent"];
		openRecentMenuItem.submenu = openRecentMenu;
		[openRecentMenu addItemWithTitle:@"Clear Menu" action:@selector(clearRecentDocuments:) keyEquivalent:@""];

		[fileMenu addItem:[NSMenuItem separatorItem]];
		[fileMenu addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
		[fileMenu addItemWithTitle:@"Save…" action:@selector(saveDocument:) keyEquivalent:@"s"];

		[fileMenu addItemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"s"]
		        .keyEquivalentModifierMask |= NSEventModifierFlagShift;

		[fileMenu addItemWithTitle:@"Revert to Saved" action:@selector(revertDocumentToSaved:) keyEquivalent:@"r"];
		[fileMenu addItem:[NSMenuItem separatorItem]];

		[fileMenu addItemWithTitle:@"Page Setup…" action:@selector(runPageLayout:) keyEquivalent:@"p"]
		        .keyEquivalentModifierMask |= NSEventModifierFlagShift;

		[fileMenu addItemWithTitle:@"Print…" action:@selector(print:) keyEquivalent:@"p"];
	}

	{
		NSMenuItem *editMenuItem = [mainMenu addItemWithTitle:@"Edit" action:nil keyEquivalent:@""];
		NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
		editMenuItem.submenu = editMenu;

		[editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];

		[editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"z"].keyEquivalentModifierMask |=
		        NSEventModifierFlagShift;

		[editMenu addItem:[NSMenuItem separatorItem]];
		[editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
		[editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
		[editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
		[editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
	}

	{
		NSMenuItem *viewMenuItem = [mainMenu addItemWithTitle:@"View" action:nil keyEquivalent:@""];
		NSMenu *viewMenu = [[NSMenu alloc] initWithTitle:@"View"];
		viewMenuItem.submenu = viewMenu;

		[viewMenu addItemWithTitle:@"Show Toolbar" action:@selector(toggleToolbarShown:) keyEquivalent:@"t"]
		        .keyEquivalentModifierMask |= NSEventModifierFlagOption;

		[viewMenu addItemWithTitle:@"Customize Toolbar…"
		                    action:@selector(runToolbarCustomizationPalette:)
		             keyEquivalent:@""];

		[viewMenu addItem:[NSMenuItem separatorItem]];

		[viewMenu addItemWithTitle:@"Show Sidebar" action:@selector(toggleSidebar:) keyEquivalent:@"s"]
		        .keyEquivalentModifierMask |= NSEventModifierFlagControl;

		[viewMenu addItemWithTitle:@"Enter Full Screen" action:@selector(toggleFullScreen:) keyEquivalent:@"f"]
		        .keyEquivalentModifierMask |= NSEventModifierFlagControl;
	}

	{
		NSMenuItem *windowMenuItem = [mainMenu addItemWithTitle:@"Window" action:nil keyEquivalent:@""];
		NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
		windowMenuItem.submenu = windowMenu;

		[windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
		[windowMenu addItemWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];
		[windowMenu addItem:[NSMenuItem separatorItem]];
		[windowMenu addItemWithTitle:@"Bring All to Front" action:@selector(arrangeInFront:) keyEquivalent:@""];

		NSApp.windowsMenu = windowMenu;
	}

	NSApp.mainMenu = mainMenu;

	_editWindowController = [[EditWindowController alloc] init];
	_settingsWindowController = [[SettingsWindowController alloc] init];

	NSArray<Countdown *> *countdowns = Preferences.sharedPreferences.countdowns;
	_countdownStatusItems = [NSMutableArray arrayWithCapacity:countdowns.count];
	for (Countdown *countdown in countdowns) {
		NSStatusItem *statusItem = [self newStatusItem];
		[_countdownStatusItems addObject:statusItem];
		[self configureStatusItem:statusItem forCountdown:countdown];
	}

	[self updateEmptyStateStatusItem];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(preferencesCountdownsDidChange:)
	                                           name:PreferencesCountdownsDidChangeNotification
	                                         object:nil];
}

- (void)editCountdowns:(id)sender {
	[_editWindowController showWindow:nil];
	[NSApp activate];
}

- (void)showSettings:(id)sender {
	[_settingsWindowController showWindow:nil];
	[NSApp activate];
}

- (void)preferencesCountdownsDidChange:(NSNotification *)notification {
	PreferencesCountdownsChange *change = notification.userInfo[PreferencesCountdownsChangeKey];

	switch (change.type) {
		case PreferencesCountdownsChangeTypeInsert: {
			Countdown *countdown = Preferences.sharedPreferences.countdowns[change.index];
			NSStatusItem *statusItem = [self newStatusItem];
			[_countdownStatusItems insertObject:statusItem atIndex:change.index];
			[self configureStatusItem:statusItem forCountdown:countdown];
			break;
		}

		case PreferencesCountdownsChangeTypeDelete: {
			[_countdownStatusItems removeObjectAtIndex:change.index];
			break;
		}

		case PreferencesCountdownsChangeTypeUpdate: {
			Countdown *countdown = Preferences.sharedPreferences.countdowns[change.index];
			[self configureStatusItem:_countdownStatusItems[change.index] forCountdown:countdown];
			break;
		}
	}

	[self updateEmptyStateStatusItem];
}

- (void)updateEmptyStateStatusItem {
	if (_countdownStatusItems.count > 0) {
		_emptyStateStatusItem = nil;
		return;
	}

	if (_emptyStateStatusItem == nil) {
		_emptyStateStatusItem = [self newStatusItem];
		_emptyStateStatusItem.button.title = @"No Countdowns";
	}
}

- (void)configureStatusItem:(NSStatusItem *)statusItem forCountdown:(Countdown *)countdown {
	NSDate *startOfToday = [NSCalendar.currentCalendar startOfDayForDate:[NSDate date]];
	NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
	formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
	formatter.allowedUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSString *intervalString = [formatter stringFromDate:startOfToday toDate:countdown.date];

	if (countdown.title.length > 0) {
		statusItem.button.title = [NSString stringWithFormat:@"%@: %@ left", countdown.title, intervalString];
	} else {
		statusItem.button.title = [NSString stringWithFormat:@"%@ left", intervalString];
	}
}

- (NSStatusItem *)newStatusItem {
	NSStatusItem *statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
	NSMenu *menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:@"Edit Countdowns…" action:@selector(editCountdowns:) keyEquivalent:@""];
	[menu addItemWithTitle:@"Settings…" action:@selector(showSettings:) keyEquivalent:@","];
	statusItem.menu = menu;
	return statusItem;
}

@end
