@interface Preferences : NSObject

@property(class, readonly) Preferences *sharedPreferences;

@property(nonatomic) NSDate *countdownDate;
@property(nonatomic, readonly) BOOL hasCreatedCountdown;

@end
