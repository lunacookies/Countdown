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

- (NSFont *)NSFontOfSize:(CGFloat)fontSize {
	NSFontDescriptor *fontDescriptor = [NSFontDescriptor preferredFontDescriptorForTextStyle:NSFontTextStyleBody
	                                                                                 options:@{}];
	NSFontDescriptorSystemDesign design = 0;
	Font settingsFont = Settings.sharedSettings.font;
	if ([settingsFont isEqualToString:FontSystem]) {
		design = NSFontDescriptorSystemDesignDefault;
	} else if ([settingsFont isEqualToString:FontSystemSerif]) {
		design = NSFontDescriptorSystemDesignSerif;
	} else if ([settingsFont isEqualToString:FontSystemMonospace]) {
		design = NSFontDescriptorSystemDesignMonospaced;
	} else if ([settingsFont isEqualToString:FontSystemRounded]) {
		design = NSFontDescriptorSystemDesignRounded;
	} else {
		NSAssert(NO, @"unreachable");
	}

	fontDescriptor = [fontDescriptor fontDescriptorWithDesign:design];
	return [NSFont fontWithDescriptor:fontDescriptor size:fontSize];
}

- (void)didChange {
	[NSNotificationCenter.defaultCenter postNotificationName:SettingsDidChangeNotification object:nil];
}

@end
