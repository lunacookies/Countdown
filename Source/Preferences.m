@interface Countdown ()
- (instancetype)initForPreferences;
+ (instancetype)countdownWithPropertyList:(id)propertyList;
@property(readonly, nonatomic) id propertyList;
@end

@implementation Countdown {
	NSString *_title;
	NSDate *_date;
}

- (instancetype)init {
	self = [super init];
	_title = @"";
	_date = [NSDate date];
	return self;
}

- (NSString *)title {
	return _title;
}

- (void)setTitle:(NSString *)title {
	_title = [title copy];
	[self didChange];
}

- (NSDate *)date {
	return _date;
}

- (void)setDate:(NSDate *)date {
	_date = date;
	[self didChange];
}

- (void)didChange {
	[NSNotificationCenter.defaultCenter postNotificationName:CountdownDidChangeNotification object:self];
}

- (instancetype)initForPreferences {
	return [self init];
}

static NSString *const TitleKey = @"Title";
static NSString *const DateKey = @"Date";

+ (instancetype)countdownWithPropertyList:(id)propertyList {
	Countdown *countdown = [[Countdown alloc] init];
	NSAssert([propertyList isKindOfClass:[NSDictionary class]], @"property list must be dictionary");
	NSDictionary<NSString *, id> *dictionary = propertyList;

	countdown->_title = dictionary[TitleKey];
	countdown->_date = dictionary[DateKey];

	return countdown;
}

- (id)propertyList {
	return @{TitleKey : _title, DateKey : _date};
}

@end

@implementation Preferences {
	NSMutableArray<Countdown *> *_countdowns;
}

static NSString *const CountdownsKey = @"Countdowns";

- (instancetype)init {
	self = [super init];

	[NSUserDefaults.standardUserDefaults registerDefaults:@{CountdownsKey : @[]}];

	NSArray<id> *countdownsPropertyList = [NSUserDefaults.standardUserDefaults arrayForKey:CountdownsKey];
	_countdowns = [NSMutableArray arrayWithCapacity:countdownsPropertyList.count];
	for (id countdownPropertyList in countdownsPropertyList) {
		[_countdowns addObject:[Countdown countdownWithPropertyList:countdownPropertyList]];
	}

	[NSNotificationCenter.defaultCenter addObserver:self
	                                       selector:@selector(countdownDidChange:)
	                                           name:CountdownDidChangeNotification
	                                         object:nil];

	return self;
}

+ (Preferences *)sharedPreferences {
	static Preferences *preferences = nil;
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		preferences = [[Preferences alloc] init];
	});

	return preferences;
}

- (NSArray<Countdown *> *)countdowns {
	return [_countdowns copy];
}

- (Countdown *)addCountdown {
	Countdown *countdown = [[Countdown alloc] initForPreferences];
	NSUInteger index = _countdowns.count;
	[_countdowns addObject:countdown];
	[self didChangeCountdownsWithChangeType:PreferencesCountdownsChangeTypeInsert atIndex:index];
	return countdown;
}

- (void)deleteCountdownAtIndex:(NSUInteger)index {
	[_countdowns removeObjectAtIndex:index];
	[self didChangeCountdownsWithChangeType:PreferencesCountdownsChangeTypeDelete atIndex:index];
}

- (void)countdownDidChange:(NSNotification *)notification {
	Countdown *countdown = notification.object;
	NSUInteger index = [_countdowns indexOfObject:countdown];
	NSAssert(index != NSNotFound, @"all countdowns are contained in the global Preferences singleton");
	[self didChangeCountdownsWithChangeType:PreferencesCountdownsChangeTypeUpdate atIndex:index];
}

- (void)didChangeCountdownsWithChangeType:(PreferencesCountdownsChangeType)changeType atIndex:(NSUInteger)index {
	NSMutableArray<id> *countdownsPropertyList = [NSMutableArray arrayWithCapacity:_countdowns.count];
	for (Countdown *countdown in _countdowns) {
		[countdownsPropertyList addObject:countdown.propertyList];
	}
	[NSUserDefaults.standardUserDefaults setObject:countdownsPropertyList forKey:CountdownsKey];

	PreferencesCountdownsChange *change = [PreferencesCountdownsChange changeWithType:changeType index:index];
	[NSNotificationCenter.defaultCenter postNotificationName:PreferencesCountdownsDidChangeNotification
	                                                  object:nil
	                                                userInfo:@{PreferencesCountdownsChangeKey : change}];
}

@end

@implementation PreferencesCountdownsChange

+ (instancetype)changeWithType:(PreferencesCountdownsChangeType)type index:(NSUInteger)index {
	PreferencesCountdownsChange *change = [[PreferencesCountdownsChange alloc] init];
	change->_type = type;
	change->_index = index;
	return change;
}

@end
