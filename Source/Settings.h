@interface Settings : NSObject
@property(class, readonly) Settings *sharedSettings;
@property(nonatomic) CGFloat fontSize;
@end
