@interface Countdown ()
- (instancetype)initForPreferences;
+ (instancetype)countdownWithPropertyList:(id)propertyList;
@property(readonly, nonatomic) id propertyList;
@end

@interface Preferences ()
- (void)didChange;
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
	[Preferences.sharedPreferences didChange];
}

- (NSDate *)date {
	return _date;
}

- (void)setDate:(NSDate *)date {
	_date = date;
	[Preferences.sharedPreferences didChange];
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
	[_countdowns addObject:countdown];
	[self didChange];
	return countdown;
}

- (void)didChange {
	NSMutableArray<id> *countdownsPropertyList = [NSMutableArray arrayWithCapacity:_countdowns.count];
	for (Countdown *countdown in _countdowns) {
		[countdownsPropertyList addObject:countdown.propertyList];
	}
	[NSUserDefaults.standardUserDefaults setObject:countdownsPropertyList forKey:CountdownsKey];

	[NSNotificationCenter.defaultCenter postNotificationName:PreferencesDidChangeNotification object:nil];
}

@end
