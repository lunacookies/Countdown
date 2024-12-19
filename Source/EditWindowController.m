@implementation EditWindowController {
	NSDatePicker *_datePicker;
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
	[self preferencesDidChange:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(preferencesDidChange:)
	                                           name:PreferencesDidChangeNotification
	                                         object:nil];
}

- (void)datePickerValueDidChange:(NSDatePicker *)sender {
	Preferences.sharedPreferences.countdownDate = _datePicker.dateValue;
}

- (void)preferencesDidChange:(id)sender {
	_datePicker.dateValue = Preferences.sharedPreferences.countdownDate;
}

@end
