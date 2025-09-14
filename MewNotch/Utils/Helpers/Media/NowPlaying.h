//
//  NowPlaying.h
//  MewNotch
//
//  Created by MewNotch Team on 14/09/25.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NowPlaying : NSObject

+ (NowPlaying *)sharedInstance;

// Current values (updated periodically)
@property (atomic, readonly) double elapsedTime;
@property (atomic, readonly) double duration;
@property (atomic, readonly) BOOL isPlaying;
@property (atomic, readonly) BOOL isVideo;
@property (atomic, copy, readonly) NSString * _Nullable clientBundleIdentifier;

@end

extern NSString *NowPlayingNotification;

NS_ASSUME_NONNULL_END


