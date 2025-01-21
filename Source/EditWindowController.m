static NSString *const CountdownCellViewIdentifier = @"org.xoria.Countdown.CountdownCellViewIdentifier";

@interface CountdownCellView : NSTableCellView
@end

@interface EditWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation EditWindowController {
	NSTableView *_tableView;
	CountdownEditorViewController *_editorViewController;
	NSTextField *_noSelectionLabel;
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

	_tableView = [[NSTableView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.headerView = nil;
	[_tableView addTableColumn:[[NSTableColumn alloc] init]];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = _tableView;

	_editorViewController = [[CountdownEditorViewController alloc] init];
	_editorViewController.view.wantsLayer = YES;
	_editorViewController.view.alphaValue = 0;
	_editorViewController.view.hidden = YES;

	_noSelectionLabel = [NSTextField labelWithString:@"No Selection"];
	_noSelectionLabel.wantsLayer = YES;
	_noSelectionLabel.font = [NSFont systemFontOfSize:24 weight:NSFontWeightBold];
	_noSelectionLabel.textColor = NSColor.placeholderTextColor;
	_noSelectionLabel.alignment = NSTextAlignmentCenter;

	NSView *contentView = self.window.contentView;
	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	_editorViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	_noSelectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:scrollView];
	[contentView addSubview:_editorViewController.view];
	[contentView addSubview:_noSelectionLabel];

	NSLayoutGuide *guide = contentView.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[scrollView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[_tableView.widthAnchor constraintEqualToConstant:200],
		[_tableView.heightAnchor constraintEqualToConstant:300],

		[_editorViewController.view.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[_editorViewController.view.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[_editorViewController.view.leadingAnchor constraintEqualToAnchor:scrollView.trailingAnchor constant:10],
		[_editorViewController.view.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],

		[_noSelectionLabel.leadingAnchor constraintEqualToAnchor:_editorViewController.view.leadingAnchor],
		[_noSelectionLabel.trailingAnchor constraintEqualToAnchor:_editorViewController.view.trailingAnchor],
		[_noSelectionLabel.centerYAnchor constraintEqualToAnchor:_editorViewController.view.centerYAnchor],
	]];

	[self.window layoutIfNeeded];
	[self.window center];
}

- (void)windowDidLoad {
	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(preferencesDidChange:)
	                                           name:PreferencesDidChangeNotification
	                                         object:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:PreferencesDidChangeNotification object:nil];
}

- (void)preferencesDidChange:(NSNotification *)notification {
	NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:0];
	NSIndexSet *columnIndexes = [NSIndexSet indexSetWithIndex:0];
	[_tableView reloadDataForRowIndexes:rowIndexes columnIndexes:columnIndexes];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	CountdownCellView *view = [_tableView makeViewWithIdentifier:CountdownCellViewIdentifier owner:nil];
	if (view == nil) {
		view = [[CountdownCellView alloc] init];
	}
	return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSInteger selectedRow = _tableView.selectedRow;

	if (selectedRow < 0) {
		[NSAnimationContext
		        runAnimationGroup:^(NSAnimationContext *context) {
			        (void)context;
			        _editorViewController.view.animator.alphaValue = 0;
			        _noSelectionLabel.hidden = NO;
			        _noSelectionLabel.animator.alphaValue = 1;
		        }
		        completionHandler:^{
			        if (_editorViewController.view.alphaValue == 0) {
				        _editorViewController.view.hidden = YES;
			        }
		        }];

		return;
	}

	[NSAnimationContext
	        runAnimationGroup:^(NSAnimationContext *context) {
		        (void)context;
		        _editorViewController.view.hidden = NO;
		        _editorViewController.view.animator.alphaValue = 1;
		        _noSelectionLabel.animator.alphaValue = 0;
	        }
	        completionHandler:^{
		        if (_noSelectionLabel.alphaValue == 0) {
			        _noSelectionLabel.hidden = YES;
		        }
	        }];

	_editorViewController.countdown = Preferences.sharedPreferences.countdowns[(NSUInteger)selectedRow];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return (NSInteger)Preferences.sharedPreferences.countdowns.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return Preferences.sharedPreferences.countdowns[(NSUInteger)row];
}

@end

@implementation CountdownCellView {
	NSTextField *_label;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	self.identifier = CountdownCellViewIdentifier;

	_label = [NSTextField labelWithString:@""];
	self.textField = _label;

	_label.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:_label];
	[NSLayoutConstraint activateConstraints:@[
		[_label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
		[_label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
		[_label.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
	]];

	return self;
}

- (void)setObjectValue:(id)objectValue {
	[super setObjectValue:objectValue];
	if (objectValue == nil) {
		_label.stringValue = @"";
		return;
	}

	NSAssert([objectValue isKindOfClass:[Countdown class]], @"CountdownCellView objectValue must be Countdown");
	Countdown *countdown = objectValue;
	_label.stringValue = [NSString stringWithFormat:@"%@", countdown.date];
}

@end
