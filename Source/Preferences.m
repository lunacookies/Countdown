@implementation Preferences

static NSString *const CountdownDateKey = @"CountdownDate";

+ (Preferences *)sharedPreferences {
	static Preferences *preferences = nil;
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		preferences = [[Preferences alloc] init];
	});

	return preferences;
}

- (NSDate *)countdownDate {
	return [NSUserDefaults.standardUserDefaults objectForKey:CountdownDateKey];
}

- (void)setCountdownDate:(NSDate *)countdownDate {
	[NSUserDefaults.standardUserDefaults setObject:countdownDate forKey:CountdownDateKey];
	[self preferencesDidChange];
}

- (void)preferencesDidChange {
	[NSNotificationCenter.defaultCenter postNotificationName:PreferencesDidChangeNotification object:nil];
}

@end
