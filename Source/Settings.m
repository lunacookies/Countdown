@implementation Settings

static NSString *const FontSizeKey = @"FontSize";

- (instancetype)init {
	self = [super init];
	[NSUserDefaults.standardUserDefaults registerDefaults:@{FontSizeKey : @11}];
	return self;
}

+ (Settings *)sharedSettings {
	static Settings *settings = nil;
	static dispatch_once_t predicate;

	dispatch_once(&predicate, ^{
		settings = [[Settings alloc] init];
	});

	return settings;
}

- (CGFloat)fontSize {
	return (CGFloat)[NSUserDefaults.standardUserDefaults doubleForKey:FontSizeKey];
}

- (void)setFontSize:(CGFloat)fontSize {
	[NSUserDefaults.standardUserDefaults setDouble:(double)fontSize forKey:FontSizeKey];
	[self didChange];
}

- (void)didChange {
	[NSNotificationCenter.defaultCenter postNotificationName:SettingsDidChangeNotification object:nil];
}

@end
