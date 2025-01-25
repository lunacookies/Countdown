typedef NSString *Font;
static const Font FontSystem = @"FontSystem";
static const Font FontSystemSerif = @"FontSystemSerif";
static const Font FontSystemMonospace = @"FontSystemMonospace";
static const Font FontSystemRounded = @"FontSystemRounded";

@interface Settings : NSObject
@property(class, readonly) Settings *sharedSettings;
@property(nonatomic) Font font;
@property(nonatomic) CGFloat fontSize;
- (NSFont *)NSFontOfSize:(CGFloat)fontSize;
@end
