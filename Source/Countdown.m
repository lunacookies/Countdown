@interface Countdown ()
- (instancetype)initForCountdownStore;
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

- (instancetype)initForCountdownStore {
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

@implementation CountdownStore {
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

+ (CountdownStore *)sharedCountdownStore {
	static CountdownStore *countdownStore = nil;
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		countdownStore = [[CountdownStore alloc] init];
	});

	return countdownStore;
}

- (NSArray<Countdown *> *)countdowns {
	return [_countdowns copy];
}

- (Countdown *)addCountdown {
	Countdown *countdown = [[Countdown alloc] initForCountdownStore];
	NSUInteger index = _countdowns.count;
	[_countdowns addObject:countdown];
	[self didChangeWithType:CountdownStoreChangeTypeInsert atIndex:index];
	return countdown;
}

- (void)deleteCountdownAtIndex:(NSUInteger)index {
	[_countdowns removeObjectAtIndex:index];
	[self didChangeWithType:CountdownStoreChangeTypeDelete atIndex:index];
}

- (void)countdownDidChange:(NSNotification *)notification {
	Countdown *countdown = notification.object;
	NSUInteger index = [_countdowns indexOfObject:countdown];
	NSAssert(index != NSNotFound, @"all countdowns are contained in the global CountdownStore singleton");
	[self didChangeWithType:CountdownStoreChangeTypeUpdate atIndex:index];
}

- (void)didChangeWithType:(CountdownStoreChangeType)changeType atIndex:(NSUInteger)index {
	NSMutableArray<id> *countdownsPropertyList = [NSMutableArray arrayWithCapacity:_countdowns.count];
	for (Countdown *countdown in _countdowns) {
		[countdownsPropertyList addObject:countdown.propertyList];
	}
	[NSUserDefaults.standardUserDefaults setObject:countdownsPropertyList forKey:CountdownsKey];

	CountdownStoreChange *change = [CountdownStoreChange changeWithType:changeType index:index];
	[NSNotificationCenter.defaultCenter postNotificationName:CountdownStoreDidChangeNotification
	                                                  object:nil
	                                                userInfo:@{CountdownStoreChangeKey : change}];
}

@end

@implementation CountdownStoreChange

+ (instancetype)changeWithType:(CountdownStoreChangeType)type index:(NSUInteger)index {
	CountdownStoreChange *change = [[CountdownStoreChange alloc] init];
	change->_type = type;
	change->_index = index;
	return change;
}

@end
