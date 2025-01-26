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
	self.window = [[NSWindow alloc] initWithContentRect:(NSRect){0}
	                                          styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable
	                                            backing:NSBackingStoreBuffered
	                                              defer:YES];
	self.window.identifier = EditWindowIdentifier;
	self.window.title = @"Edit Countdowns";

	_tableView = [[NSTableView alloc] init];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.headerView = nil;
	[_tableView addTableColumn:[[NSTableColumn alloc] init]];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = _tableView;
	scrollView.borderType = NSLineBorder;
	scrollView.hasVerticalScroller = YES;

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
		// 16pt padding inside group boxes except for top, which is 10pt (2009 Mac HIG, page 352)
		[_editorViewController.view.topAnchor constraintEqualToAnchor:box.topAnchor constant:10],
		[_editorViewController.view.bottomAnchor constraintEqualToAnchor:box.bottomAnchor constant:-16],
		[_editorViewController.view.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:16],
		[_editorViewController.view.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-16],

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

	// 20pt padding inside windows except for top, which is 14pt (2009 Mac HIG, pages 349 and 350)
	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:14],
		[scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
		[scrollView.widthAnchor constraintEqualToConstant:200],
		[scrollView.heightAnchor constraintEqualToConstant:300],

		[addButton.topAnchor constraintEqualToAnchor:scrollView.bottomAnchor constant:10],
		[addButton.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20],
		[addButton.leadingAnchor constraintEqualToAnchor:scrollView.leadingAnchor],

		[_removeButton.centerYAnchor constraintEqualToAnchor:addButton.centerYAnchor],
		[_removeButton.leadingAnchor constraintEqualToAnchor:addButton.trailingAnchor constant:5],

		[box.topAnchor constraintEqualToAnchor:scrollView.topAnchor],
		[box.bottomAnchor constraintEqualToAnchor:scrollView.bottomAnchor],
		[box.leadingAnchor constraintEqualToAnchor:scrollView.trailingAnchor constant:10],
		[box.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
	]];

	[self.window layoutIfNeeded];
	[self.window center];

	self.windowFrameAutosaveName = EditWindowIdentifier;
}

- (void)windowDidLoad {
	[self updateRemoveButtonEnabledState];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(countdownStoreDidChange:)
	                                           name:CountdownStoreDidChangeNotification
	                                         object:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:CountdownStoreDidChangeNotification object:nil];
}

- (void)countdownStoreDidChange:(NSNotification *)notification {
	CountdownStoreChange *change = notification.userInfo[CountdownStoreChangeKey];

	switch (change.type) {
		case CountdownStoreChangeTypeInsert: {
			[_tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:change.index]
			                  withAnimation:NSTableViewAnimationSlideDown];
			break;
		}

		case CountdownStoreChangeTypeDelete: {
			[_tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:change.index]
			                  withAnimation:NSTableViewAnimationSlideDown];
			break;
		}

		case CountdownStoreChangeTypeUpdate: {
			NSIndexSet *rowIndexes = [NSIndexSet indexSetWithIndex:change.index];
			NSUInteger columnCount = _tableView.tableColumns.count;
			NSIndexSet *columnIndexes = [NSIndexSet indexSetWithIndexesInRange:(NSRange){0, columnCount}];
			[_tableView reloadDataForRowIndexes:rowIndexes columnIndexes:columnIndexes];
			break;
		}
	}
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

	_editorViewController.countdown = CountdownStore.sharedCountdownStore.countdowns[(NSUInteger)selectedRow];
}

- (void)updateRemoveButtonEnabledState {
	_removeButton.enabled = _tableView.selectedRow >= 0;
}

- (NSArray<NSTableViewRowAction *> *)tableView:(NSTableView *)tableView
                              rowActionsForRow:(NSInteger)row
                                          edge:(NSTableRowActionEdge)edge {
	if (edge != NSTableRowActionEdgeTrailing) {
		return @[];
	}

	return @[ [NSTableViewRowAction rowActionWithStyle:NSTableViewRowActionStyleDestructive
		                                         title:@"Delete"
		                                       handler:^(NSTableViewRowAction *action, NSInteger row_) {
		                                           (void)action;
		                                           [CountdownStore.sharedCountdownStore
		                                                   deleteCountdownAtIndex:(NSUInteger)row_];
		                                       }] ];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return (NSInteger)CountdownStore.sharedCountdownStore.countdowns.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return CountdownStore.sharedCountdownStore.countdowns[(NSUInteger)row];
}

- (void)addCountdown:(NSButton *)addButton {
	[CountdownStore.sharedCountdownStore addCountdown];
}

- (void)removeCountdown:(NSButton *)removeButton {
	NSAssert(_tableView.selectedRow >= 0, @"must have a selected row to remove a countdown");
	[CountdownStore.sharedCountdownStore deleteCountdownAtIndex:(NSUInteger)_tableView.selectedRow];
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
