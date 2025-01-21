@implementation CountdownEditorViewController {
	NSDatePicker *_datePicker;
	Countdown *_countdown;
}

- (void)loadView {
	[super loadView];

	_datePicker = [[NSDatePicker alloc] init];
	_datePicker.datePickerElements = NSDatePickerElementFlagYearMonthDay;
	_datePicker.presentsCalendarOverlay = YES;
	_datePicker.target = self;
	_datePicker.action = @selector(datePickerValueDidChange:);

	NSGridView *gridView = [NSGridView gridViewWithViews:@[
		@[ [NSTextField labelWithString:@"Count down until:"], _datePicker ],
	]];

	gridView.rowAlignment = NSGridRowAlignmentFirstBaseline;

	gridView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:gridView];
	NSLayoutGuide *guide = self.view.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[gridView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[gridView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[gridView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[gridView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
	]];
}

- (void)viewDidLoad {
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

- (void)preferencesDidChange:(NSNotification *)notification {
	_datePicker.dateValue = _countdown.date;
}

- (Countdown *)countdown {
	return _countdown;
}

- (void)setCountdown:(Countdown *)countdown {
	_countdown = countdown;
	[self preferencesDidChange:nil];
}

@end
