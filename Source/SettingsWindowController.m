@implementation SettingsWindowController {
	NSButton *_systemFontRadioButton;
	NSButton *_systemSerifFontRadioButton;
	NSButton *_systemMonospaceFontRadioButton;
	NSButton *_systemRoundedFontRadioButton;
	NSSlider *_fontSizeSlider;
	NSSlider *_fontWeightSlider;
}

- (instancetype)init {
	return [super initWithWindowNibName:@""];
}

- (void)loadWindow {
	self.window = [[NSWindow alloc] initWithContentRect:(NSRect){0}
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
	                                            backing:NSBackingStoreBuffered
	                                              defer:YES];
	self.window.identifier = SettingsWindowIdentifier;
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

	// 6pt between radio buttons in a group (2009 Mac HIG, page 282)
	fontRadioButtons.spacing = 6;

	CGFloat minimumFontSize = 8;
	CGFloat maximumFontSize = 15;
	_fontSizeSlider = [NSSlider sliderWithValue:11
	                                   minValue:minimumFontSize
	                                   maxValue:maximumFontSize
	                                     target:self
	                                     action:@selector(fontSizeSliderDidChange:)];
	_fontSizeSlider.allowsTickMarkValuesOnly = YES;
	_fontSizeSlider.numberOfTickMarks = (NSInteger)(maximumFontSize - minimumFontSize + 1); // Fencepost Problem

	_fontWeightSlider = [NSSlider sliderWithValue:0
	                                     minValue:0
	                                     maxValue:1
	                                       target:self
	                                       action:@selector(fontWeightSliderDidChange:)];
	_fontWeightSlider.allowsTickMarkValuesOnly = YES;
	_fontWeightSlider.numberOfTickMarks = 8;

	NSGridView *gridView = [NSGridView gridViewWithViews:@[
		@[ [NSTextField labelWithString:@"Font:"], fontRadioButtons ],
		@[ [NSTextField labelWithString:@"Font Size:"], _fontSizeSlider ],
		@[ [NSTextField labelWithString:@"Font Weight:"], _fontWeightSlider ],
	]];

	gridView.rowAlignment = NSGridRowAlignmentFirstBaseline;
	[gridView columnAtIndex:0].xPlacement = NSGridCellPlacementTrailing;

	// 8pt between labels and controls (2009 Mac HIG, page 282)
	gridView.columnSpacing = 8;

	// 8pt between discrete controls (2009 Mac HIG, page 349)
	gridView.rowSpacing = 8;

	NSView *contentView = self.window.contentView;
	gridView.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:gridView];

	// 20pt padding inside windows except for top, which is 14pt (2009 Mac HIG, pages 349 and 350)
	[NSLayoutConstraint activateConstraints:@[
		[gridView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:14],
		[gridView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20],
		[gridView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
		[gridView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
	]];

	[self.window layoutIfNeeded];
	[self.window center];

	self.windowFrameAutosaveName = SettingsWindowIdentifier;
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

- (void)fontWeightSliderDidChange:(NSSlider *)fontWeightSlider {
	Settings.sharedSettings.fontWeight = (CGFloat)_fontWeightSlider.doubleValue;
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
	_fontWeightSlider.doubleValue = Settings.sharedSettings.fontWeight;
}

@end
