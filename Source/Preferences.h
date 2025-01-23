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
- (void)removeCountdownAtIndex:(NSUInteger)index;

@end
