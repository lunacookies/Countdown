@interface Countdown : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
@property(nonatomic, copy) NSString *title;
@property(nonatomic) NSDate *date;
@end

@interface CountdownStore : NSObject

@property(class, readonly) CountdownStore *sharedCountdownStore;
@property(nonatomic, copy, readonly) NSArray<Countdown *> *countdowns;

- (Countdown *)addCountdown;
- (void)deleteCountdownAtIndex:(NSUInteger)index;

@end

typedef NS_ENUM(NSInteger, CountdownStoreChangeType) {
	CountdownStoreChangeTypeInsert,
	CountdownStoreChangeTypeDelete,
	CountdownStoreChangeTypeUpdate,
};

@interface CountdownStoreChange : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)changeWithType:(CountdownStoreChangeType)type index:(NSUInteger)index;
@property(nonatomic, readonly) CountdownStoreChangeType type;
@property(nonatomic, readonly) NSUInteger index;
@end

static NSString *const CountdownStoreChangeKey = @"CountdownStoreChange";
