@interface WidgetWrapperView : NSView
@end

@interface WidgetCountdownItem : NSCollectionViewItem
@property(nonatomic) Countdown *countdown;
@end

static const NSUserInterfaceItemIdentifier WidgetCountdownItemIdentifier = @"org.xoria.Countdown.WidgetCountdownItem";

@interface WidgetWindowController () <NSCollectionViewDataSource>
@end

@implementation WidgetWindowController {
	NSCollectionView *_collectionView;
}

- (instancetype)init {
	return [super initWithWindowNibName:@""];
}

- (void)loadWindow {
	self.window =
	        [[NSWindow alloc] initWithContentRect:(NSRect) { {100, 100}, {400, 200} }
	                                    styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
	                                              NSWindowStyleMaskResizable | NSWindowStyleMaskFullSizeContentView
	                                      backing:NSBackingStoreBuffered
	                                        defer:YES];
	self.window.identifier = WidgetWindowIdentifier;
	self.window.title = @"Countdowns";
	self.window.level = CGWindowLevelForKey(kCGBackstopMenuLevelKey);
	self.window.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorTransient;

	self.window.titlebarAppearsTransparent = YES;
	self.window.titleVisibility = NSWindowTitleHidden;
	[self.window standardWindowButton:NSWindowCloseButton].hidden = YES;
	[self.window standardWindowButton:NSWindowMiniaturizeButton].hidden = YES;
	[self.window standardWindowButton:NSWindowZoomButton].hidden = YES;

	_collectionView = [[NSCollectionView alloc] init];
	_collectionView.dataSource = self;

	NSCollectionLayoutSize *itemSize =
	        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
	                                       heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1]];
	NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize];

	NSCollectionLayoutSize *groupSize =
	        [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1]
	                                       heightDimension:[NSCollectionLayoutDimension absoluteDimension:32]];
	NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize
	                                                                                subitem:item
	                                                                                  count:2];
	group.interItemSpacing = [NSCollectionLayoutSpacing fixedSpacing:10];

	NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
	section.interGroupSpacing = 10;
	section.contentInsets = (NSDirectionalEdgeInsets){10, 10, 10, 10};
	_collectionView.collectionViewLayout = [[NSCollectionViewCompositionalLayout alloc] initWithSection:section];

	[_collectionView registerClass:[WidgetCountdownItem class] forItemWithIdentifier:WidgetCountdownItemIdentifier];

	NSScrollView *scrollView = [[NSScrollView alloc] init];
	scrollView.documentView = _collectionView;
	scrollView.hasVerticalScroller = YES;

	NSVisualEffectView *effectView = [[NSVisualEffectView alloc] init];
	effectView.material = NSVisualEffectMaterialPopover;
	effectView.state = NSVisualEffectStateActive;
	scrollView.drawsBackground = NO;
	_collectionView.backgroundColors = @[ NSColor.clearColor ];

	WidgetWrapperView *widgetWrapperView = [[WidgetWrapperView alloc] init];

	scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	effectView.translatesAutoresizingMaskIntoConstraints = NO;
	[effectView addSubview:scrollView];
	[widgetWrapperView addSubview:effectView];

	[NSLayoutConstraint activateConstraints:@[
		[scrollView.topAnchor constraintEqualToAnchor:effectView.topAnchor],
		[scrollView.bottomAnchor constraintEqualToAnchor:effectView.bottomAnchor],
		[scrollView.leadingAnchor constraintEqualToAnchor:effectView.leadingAnchor],
		[scrollView.trailingAnchor constraintEqualToAnchor:effectView.trailingAnchor],

		[effectView.topAnchor constraintEqualToAnchor:widgetWrapperView.topAnchor],
		[effectView.bottomAnchor constraintEqualToAnchor:widgetWrapperView.bottomAnchor],
		[effectView.leadingAnchor constraintEqualToAnchor:widgetWrapperView.leadingAnchor],
		[effectView.trailingAnchor constraintEqualToAnchor:widgetWrapperView.trailingAnchor],

		[scrollView.widthAnchor constraintGreaterThanOrEqualToConstant:350],
		[scrollView.heightAnchor constraintGreaterThanOrEqualToConstant:150],
	]];

	self.window.contentView = widgetWrapperView;

	self.windowFrameAutosaveName = WidgetWindowIdentifier;
}

- (void)windowDidLoad {
	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(countdownStoreDidChange:)
	                                           name:CountdownStoreDidChangeNotification
	                                         object:nil];

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(settingsDidChange:)
	                                           name:SettingsDidChangeNotification
	                                         object:nil];
}

- (void)dealloc {
	[NSNotificationCenter.defaultCenter removeObserver:self name:CountdownStoreDidChangeNotification object:nil];
	[NSNotificationCenter.defaultCenter removeObserver:self name:SettingsDidChangeNotification object:nil];
}

- (void)countdownStoreDidChange:(NSNotification *)notification {
	CountdownStoreChange *change = notification.userInfo[CountdownStoreChangeKey];

	NSSet<NSIndexPath *> *indexPaths = [NSSet setWithObject:[NSIndexPath indexPathForItem:(NSInteger)change.index
	                                                                            inSection:0]];

	switch (change.type) {
		case CountdownStoreChangeTypeInsert: {
			[_collectionView.animator
			        performBatchUpdates:^{
				        [_collectionView insertItemsAtIndexPaths:indexPaths];
			        }
			          completionHandler:nil];
			break;
		}

		case CountdownStoreChangeTypeDelete: {
			[_collectionView.animator
			        performBatchUpdates:^{
				        [_collectionView deleteItemsAtIndexPaths:indexPaths];
			        }
			          completionHandler:nil];
			break;
		}

		case CountdownStoreChangeTypeUpdate: {
			[_collectionView reloadItemsAtIndexPaths:indexPaths];
			break;
		}
	}
}

- (void)settingsDidChange:(NSNotification *)notification {
	[_collectionView reloadData];
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return (NSInteger)CountdownStore.sharedCountdownStore.countdowns.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
        itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
	WidgetCountdownItem *item = [_collectionView makeItemWithIdentifier:WidgetCountdownItemIdentifier
	                                                       forIndexPath:indexPath];
	item.countdown = CountdownStore.sharedCountdownStore.countdowns[(NSUInteger)indexPath.item];
	return item;
}

@end

@implementation WidgetWrapperView

+ (NSMenu *)defaultMenu {
	NSMenu *menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:@"Remove Widget" action:@selector(performClose:) keyEquivalent:@""];
	return menu;
}

- (NSEdgeInsets)safeAreaInsets {
	return (NSEdgeInsets){0};
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
	return YES;
}

- (void)mouseDown:(NSEvent *)event {
	[self.window performWindowDragWithEvent:event];
}

@end

@implementation WidgetCountdownItem {
	NSTextField *_titleLabel;
	NSTextField *_timeLeftLabel;
	Countdown *_countdown;
}

- (instancetype)init {
	self = [super init];
	self.identifier = WidgetCountdownItemIdentifier;
	return self;
}

- (void)loadView {
	[super loadView];

	NSBox *background = [[NSBox alloc] init];
	background.wantsLayer = YES;
	background.boxType = NSBoxCustom;
	background.fillColor = [NSColor.whiteColor colorWithAlphaComponent:0.3];
	background.borderWidth = 0;
	background.layer.cornerRadius = 5;

	_titleLabel = [NSTextField labelWithString:@""];
	_titleLabel.allowsDefaultTighteningForTruncation = YES;
	_titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

	_timeLeftLabel = [NSTextField labelWithString:@""];
	_timeLeftLabel.alignment = NSTextAlignmentRight;
	_timeLeftLabel.allowsDefaultTighteningForTruncation = YES;

	background.translatesAutoresizingMaskIntoConstraints = NO;
	_titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_timeLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[_titleLabel setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow
	                                      forOrientation:NSLayoutConstraintOrientationHorizontal];

	[self.view addSubview:background];
	[self.view addSubview:_titleLabel];
	[self.view addSubview:_timeLeftLabel];

	[NSLayoutConstraint activateConstraints:@[
		[background.topAnchor constraintEqualToAnchor:self.view.topAnchor],
		[background.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
		[background.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[background.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

		[_titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
		[_timeLeftLabel.firstBaselineAnchor constraintEqualToAnchor:_titleLabel.firstBaselineAnchor],
		[_titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
		[_timeLeftLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor constant:5],
		[_timeLeftLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10],
	]];
}

- (Countdown *)countdown {
	return _countdown;
}

- (void)setCountdown:(Countdown *)countdown {
	_countdown = countdown;
	_titleLabel.stringValue = countdown.title;
	_titleLabel.font = [Settings.sharedSettings NSFontOfSize:13 weight:Settings.sharedSettings.fontWeight];
	_timeLeftLabel.stringValue = countdown.timeLeftString;
	_timeLeftLabel.font = [Settings.sharedSettings NSFontOfSize:13 weight:Settings.sharedSettings.fontWeight + 0.2];
}

@end
