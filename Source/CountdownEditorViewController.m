@interface CountdownEditorViewController () <NSTextFieldDelegate>
@end

@implementation CountdownEditorViewController {
	NSTextField *_titleField;
	NSDatePicker *_datePicker;
	Countdown *_countdown;
}

- (void)loadView {
	[super loadView];

	_titleField = [NSTextField textFieldWithString:@""];
	_titleField.placeholderString = @"Chemistry Report";
	_titleField.delegate = self;

	_datePicker = [[NSDatePicker alloc] init];
	_datePicker.datePickerElements = NSDatePickerElementFlagYearMonthDay;
	_datePicker.presentsCalendarOverlay = YES;
	_datePicker.target = self;
	_datePicker.action = @selector(datePickerValueDidChange:);

	NSGridView *gridView = [NSGridView gridViewWithViews:@[
		@[ [NSTextField labelWithString:@"Title:"], _titleField ],
		@[ [NSTextField labelWithString:@"Count down until:"], _datePicker ],
	]];

	gridView.rowAlignment = NSGridRowAlignmentFirstBaseline;
	[gridView columnAtIndex:0].xPlacement = NSGridCellPlacementTrailing;

	gridView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:gridView];
	NSLayoutGuide *guide = self.view.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[gridView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[gridView.bottomAnchor constraintLessThanOrEqualToAnchor:guide.bottomAnchor],
		[gridView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[gridView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
		[_titleField.widthAnchor constraintEqualToConstant:200],
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

- (void)controlTextDidChange:(NSNotification *)obj {
	_countdown.title = _titleField.stringValue;
}

- (void)datePickerValueDidChange:(NSDatePicker *)datePicker {
	_countdown.date = _datePicker.dateValue;
}

- (void)preferencesDidChange:(NSNotification *)notification {
	if (_countdown == nil) {
		return;
	}
	_titleField.stringValue = _countdown.title;
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
