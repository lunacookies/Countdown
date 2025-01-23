@interface Countdown : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@property(nonatomic, copy) NSString *title;
@property(nonatomic) NSDate *date;
@end

@interface Preferences : NSObject

@property(class, readonly) Preferences *sharedPreferences;
@property(nonatomic, copy, readonly) NSArray<Countdown *> *countdowns;

- (Countdown *)addCountdown;
- (void)deleteCountdownAtIndex:(NSUInteger)index;

@end

typedef NS_ENUM(NSInteger, PreferencesCountdownsChangeType) {
	PreferencesCountdownsChangeTypeInsert,
	PreferencesCountdownsChangeTypeDelete,
	PreferencesCountdownsChangeTypeUpdate,
};

@interface PreferencesCountdownsChange : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)changeWithType:(PreferencesCountdownsChangeType)type index:(NSUInteger)index;
@property(nonatomic, readonly) PreferencesCountdownsChangeType type;
@property(nonatomic, readonly) NSUInteger index;
@end

static NSString *const PreferencesCountdownsChangeKey = @"PreferencesCountdownsChange";
