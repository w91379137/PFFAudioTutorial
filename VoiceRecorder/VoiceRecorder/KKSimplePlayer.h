//https://zonble.gitbooks.io/kkbox-ios-dev/content/audio_apis/audio_queue.html

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KKSimplePlayer : NSObject

- (id)initWithURL:(NSURL *)inURL;
- (void)play;
- (void)pause;
@property (readonly, getter=isStopped) BOOL stopped;

@end
