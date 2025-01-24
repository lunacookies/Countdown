@implementation SettingsWindowController {
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
		@[ [NSTextField labelWithString:@"Font Size:"], _fontSizeSlider ],
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
		[_fontSizeSlider.widthAnchor constraintEqualToConstant:200],
	]];

	[self.window layoutIfNeeded];
	[self.window center];
}

- (void)windowDidLoad {
	[self settingsDidChange:nil];
}

- (void)fontSizeSliderDidChange:(NSSlider *)fontSizeSlider {
	Settings.sharedSettings.fontSize = (CGFloat)_fontSizeSlider.doubleValue;
}

- (void)settingsDidChange:(NSNotification *)notification {
	_fontSizeSlider.doubleValue = Settings.sharedSettings.fontSize;
}

@end
