@implementation EditWindowController {
	NSDatePicker *_datePicker;
	Countdown *_countdown;
}

- (instancetype)init {
	return [super initWithWindowNibName:@""];
}

- (void)loadWindow {
	self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
	                                            backing:NSBackingStoreBuffered
	                                              defer:YES];
	self.window.title = @"Edit Countdowns";

	_datePicker = [[NSDatePicker alloc] init];
	_datePicker.datePickerElements = NSDatePickerElementFlagYearMonthDay;
	_datePicker.presentsCalendarOverlay = YES;
	_datePicker.target = self;
	_datePicker.action = @selector(datePickerValueDidChange:);

	NSGridView *gridView = [NSGridView gridViewWithViews:@[
		@[ [NSTextField labelWithString:@"Count down until:"], _datePicker ],
	]];

	gridView.rowAlignment = NSGridRowAlignmentFirstBaseline;

	NSView *contentView = self.window.contentView;
	gridView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:gridView];
	NSLayoutGuide *guide = contentView.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[gridView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[gridView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[gridView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[gridView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
	]];

	[self.window layoutIfNeeded];
	[self.window center];
}

- (void)windowDidLoad {
	NSArray<Countdown *> *countdowns = Preferences.sharedPreferences.countdowns;
	if (countdowns.count > 0) {
		_countdown = countdowns[0];
	} else {
		_countdown = [Preferences.sharedPreferences addCountdown];
	}
	[self preferencesDidChange:nil];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(preferencesDidChange:)
	                                           name:PreferencesDidChangeNotification
	                                         object:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:PreferencesDidChangeNotification object:nil];
}

- (void)datePickerValueDidChange:(NSDatePicker *)sender {
	_countdown.date = _datePicker.dateValue;
}

- (void)preferencesDidChange:(id)sender {
	_datePicker.dateValue = _countdown.date;
}

@end
