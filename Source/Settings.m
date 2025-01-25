@implementation Settings

static NSString *const FontKey = @"Font";
static NSString *const FontSizeKey = @"FontSize";

- (instancetype)init {
	self = [super init];
	[NSUserDefaults.standardUserDefaults registerDefaults:@{FontKey : FontSystem, FontSizeKey : @11}];
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

- (Font)font {
	return [NSUserDefaults.standardUserDefaults stringForKey:FontKey];
}

- (void)setFont:(Font)font {
	[NSUserDefaults.standardUserDefaults setObject:font forKey:FontKey];
	[self didChange];
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
