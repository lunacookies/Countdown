@implementation Preferences {
	BOOL _hasCreatedCountdown;
}

- (instancetype)init {
	self = [super init];
	_countdownDate = [NSDate date];
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

- (void)setCountdownDate:(NSDate *)countdownDate {
	_countdownDate = countdownDate;
	_hasCreatedCountdown = YES;
	[self preferencesDidChange];
}

- (void)preferencesDidChange {
	[NSNotificationCenter.defaultCenter postNotificationName:PreferencesDidChangeNotification object:nil];
}

- (BOOL)hasCreatedCountdown {
	return _hasCreatedCountdown;
}

@end
