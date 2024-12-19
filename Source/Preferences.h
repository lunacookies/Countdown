@interface Preferences : NSObject

@property(class, readonly) Preferences *sharedPreferences;
@property(nonatomic) NSDate *countdownDate;

@end
