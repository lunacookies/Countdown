static NSString *const CountdownCellViewIdentifier = @"org.xoria.Countdown.CountdownCellViewIdentifier";

@interface CountdownCellView : NSTableCellView
@end

@interface EditWindowController () <NSTableViewDelegate, NSTableViewDataSource>
@end

@implementation EditWindowController {
	NSTableView *_tableView;
	CountdownEditorViewController *_editorViewController;
	NSTextField *_noSelectionLabel;
	NSButton *_removeButton;
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
	scrollView.borderType = NSLineBorder;

	NSBox *box = [[NSBox alloc] init];
	box.titlePosition = NSNoTitle;

	_editorViewController = [[CountdownEditorViewController alloc] init];
	_editorViewController.view.wantsLayer = YES;
	_editorViewController.view.alphaValue = 0;
	_editorViewController.view.hidden = YES;

	_noSelectionLabel = [NSTextField labelWithString:@"No Selection"];
	_noSelectionLabel.wantsLayer = YES;
	_noSelectionLabel.font = [NSFont systemFontOfSize:24 weight:NSFontWeightBold];
	_noSelectionLabel.textColor = NSColor.placeholderTextColor;
	_noSelectionLabel.alignment = NSTextAlignmentCenter;

	_editorViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	_noSelectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[box addSubview:_editorViewController.view];
	[box addSubview:_noSelectionLabel];
	[NSLayoutConstraint activateConstraints:@[
		[_editorViewController.view.topAnchor constraintEqualToAnchor:box.topAnchor],
		[_editorViewController.view.bottomAnchor constraintEqualToAnchor:box.bottomAnchor],
		[_editorViewController.view.leadingAnchor constraintEqualToAnchor:box.leadingAnchor],
		[_editorViewController.view.trailingAnchor constraintEqualToAnchor:box.trailingAnchor],
		[_noSelectionLabel.leadingAnchor constraintEqualToAnchor:_editorViewController.view.leadingAnchor],
		[_noSelectionLabel.trailingAnchor constraintEqualToAnchor:_editorViewController.view.trailingAnchor],
		[_noSelectionLabel.centerYAnchor constraintEqualToAnchor:_editorViewController.view.centerYAnchor],
	]];

	NSButton *addButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameAddTemplate]
	                                         target:self
	                                         action:@selector(addCountdown:)];

	_removeButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameRemoveTemplate]
	                                   target:self
	                                   action:@selector(removeCountdown:)];

	NSView *contentView = self.window.contentView;
	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	box.translatesAutoresizingMaskIntoConstraints = NO;
	addButton.translatesAutoresizingMaskIntoConstraints = NO;
	_removeButton.translatesAutoresizingMaskIntoConstraints = NO;
	[contentView addSubview:scrollView];
	[contentView addSubview:box];
	[contentView addSubview:addButton];
	[contentView addSubview:_removeButton];

	NSLayoutGuide *guide = contentView.layoutMarginsGuide;
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:guide.topAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
		[_tableView.widthAnchor constraintEqualToConstant:200],
		[_tableView.heightAnchor constraintEqualToConstant:300],

		[addButton.topAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:10],
		[addButton.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
		[addButton.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],

		[_removeButton.centerYAnchor constraintEqualToAnchor:addButton.centerYAnchor],
		[_removeButton.leadingAnchor constraintEqualToAnchor:addButton.trailingAnchor constant:5],

		[box.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
		[box.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
		[box.leadingAnchor constraintEqualToAnchor:scrollView.trailingAnchor constant:10],
		[box.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
	]];

	[self.window layoutIfNeeded];
	[self.window center];
}

- (void)windowDidLoad {
	[self updateRemoveButtonEnabledState];
	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(preferencesDidChange:)
	                                           name:PreferencesDidChangeNotification
	                                         object:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:PreferencesDidChangeNotification object:nil];
}

- (void)preferencesDidChange:(NSNotification *)notification {
	[_tableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	CountdownCellView *view = [_tableView makeViewWithIdentifier:CountdownCellViewIdentifier owner:nil];
	if (view == nil) {
		view = [[CountdownCellView alloc] init];
	}
	return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	[self updateRemoveButtonEnabledState];

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

- (void)updateRemoveButtonEnabledState {
	_removeButton.enabled = _tableView.selectedRow >= 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return (NSInteger)Preferences.sharedPreferences.countdowns.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return Preferences.sharedPreferences.countdowns[(NSUInteger)row];
}

- (void)addCountdown:(NSButton *)addButton {
	[Preferences.sharedPreferences addCountdown];
}

- (void)removeCountdown:(NSButton *)removeButton {
	NSAssert(_tableView.selectedRow >= 0, @"must have a selected row to remove a countdown");
	[Preferences.sharedPreferences removeCountdownAtIndex:(NSUInteger)_tableView.selectedRow];
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
	if (countdown.title.length > 0) {
		_label.stringValue = countdown.title;
	} else {
		NSString *dateString = [NSDateFormatter localizedStringFromDate:countdown.date
		                                                      dateStyle:NSDateFormatterMediumStyle
		                                                      timeStyle:NSDateFormatterNoStyle];
		_label.stringValue = [NSString stringWithFormat:@"Countdown on %@", dateString];
	}
}

@end
