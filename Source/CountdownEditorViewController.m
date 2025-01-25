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

	// 8pt between labels and controls (2009 Mac HIG, page 282)
	gridView.columnSpacing = 8;

	// 8pt between discrete controls (2009 Mac HIG, page 349)
	gridView.rowSpacing = 8;

	gridView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:gridView];
	[NSLayoutConstraint activateConstraints:@[
		[gridView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[gridView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.bottomAnchor],
		[gridView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[gridView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
		[_titleField.widthAnchor constraintEqualToConstant:200],
	]];
}

- (void)controlTextDidChange:(NSNotification *)obj {
	_countdown.title = _titleField.stringValue;
}

- (void)datePickerValueDidChange:(NSDatePicker *)datePicker {
	_countdown.date = _datePicker.dateValue;
}

- (void)countdownDidChange:(NSNotification *)notification {
	_titleField.stringValue = _countdown.title;
	_datePicker.dateValue = _countdown.date;
}

- (Countdown *)countdown {
	return _countdown;
}

- (void)setCountdown:(Countdown *)countdown {
	_countdown = countdown;
	[NSNotificationCenter.defaultCenter removeObserver:self name:CountdownDidChangeNotification object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(countdownDidChange:)
	                                           name:CountdownDidChangeNotification
	                                         object:_countdown];
	[self countdownDidChange:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:CountdownDidChangeNotification object:nil];
}

@end
