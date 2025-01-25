@implementation SettingsWindowController {
	NSButton *_systemFontRadioButton;
	NSButton *_systemSerifFontRadioButton;
	NSButton *_systemMonospaceFontRadioButton;
	NSButton *_systemRoundedFontRadioButton;
	NSSlider *_fontSizeSlider;
}

- (instancetype)init {
	return [super initWithWindowNibName:@""];
}

- (void)loadWindow {
	self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0)
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
	                                            backing:NSBackingStoreBuffered
	                                              defer:YES];
	self.window.title = @"Countdown Settings";

	_systemFontRadioButton = [NSButton radioButtonWithTitle:@"System" target:self action:@selector(didSelectFont:)];
	_systemSerifFontRadioButton = [NSButton radioButtonWithTitle:@"System Serif"
	                                                      target:self
	                                                      action:@selector(didSelectFont:)];
	_systemMonospaceFontRadioButton = [NSButton radioButtonWithTitle:@"System Monospace"
	                                                          target:self
	                                                          action:@selector(didSelectFont:)];
	_systemRoundedFontRadioButton = [NSButton radioButtonWithTitle:@"System Rounded"
	                                                        target:self
	                                                        action:@selector(didSelectFont:)];

	NSStackView *fontRadioButtons = [NSStackView stackViewWithViews:@[
		_systemFontRadioButton, _systemSerifFontRadioButton, _systemMonospaceFontRadioButton,
		_systemRoundedFontRadioButton
	]];

	fontRadioButtons.orientation = NSUserInterfaceLayoutOrientationVertical;
	fontRadioButtons.alignment = NSLayoutAttributeLeading;

	CGFloat minValue = 8;
	CGFloat maxValue = 15;
	_fontSizeSlider = [NSSlider sliderWithValue:11
	                                   minValue:minValue
	                                   maxValue:maxValue
	                                     target:self
	                                     action:@selector(fontSizeSliderDidChange:)];
	_fontSizeSlider.allowsTickMarkValuesOnly = YES;
	_fontSizeSlider.numberOfTickMarks = (NSInteger)(maxValue - minValue + 1); // Fencepost Problem

	NSGridView *gridView = [NSGridView gridViewWithViews:@[
		@[ [NSTextField labelWithString:@"Font:"], fontRadioButtons ],
		@[ [NSTextField labelWithString:@"Font Size:"], _fontSizeSlider ],
	]];

	gridView.rowAlignment = NSGridRowAlignmentFirstBaseline;
	[gridView columnAtIndex:0].xPlacement = NSGridCellPlacementTrailing;


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
	[self settingsDidChange:nil];
}

- (void)didSelectFont:(NSButton *)sender {
	if (sender == _systemFontRadioButton) {
		Settings.sharedSettings.font = FontSystem;
	} else if (sender == _systemSerifFontRadioButton) {
		Settings.sharedSettings.font = FontSystemSerif;
	} else if (sender == _systemMonospaceFontRadioButton) {
		Settings.sharedSettings.font = FontSystemMonospace;
	} else if (sender == _systemRoundedFontRadioButton) {
		Settings.sharedSettings.font = FontSystemRounded;
	} else {
		NSAssert(NO, @"unreachable");
	}
}

- (void)fontSizeSliderDidChange:(NSSlider *)fontSizeSlider {
	Settings.sharedSettings.fontSize = (CGFloat)_fontSizeSlider.doubleValue;
}

- (void)settingsDidChange:(NSNotification *)notification {
	Font font = Settings.sharedSettings.font;
	if ([font isEqualToString:FontSystem]) {
		_systemFontRadioButton.state = 1;
	} else if ([font isEqualToString:FontSystemSerif]) {
		_systemSerifFontRadioButton.state = 1;
	} else if ([font isEqualToString:FontSystemMonospace]) {
		_systemMonospaceFontRadioButton.state = 1;
	} else if ([font isEqualToString:FontSystemRounded]) {
		_systemRoundedFontRadioButton.state = 1;
	} else {
		NSAssert(NO, @"unreachable");
	}

	_fontSizeSlider.doubleValue = Settings.sharedSettings.fontSize;
}

@end
