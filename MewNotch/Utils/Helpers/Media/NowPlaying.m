//
//  NowPlaying.m
//  MewNotch
//
//  Created by MewNotch Team on 14/09/25.
//

#import "NowPlaying.h"
#import <dlfcn.h>

NSString *NowPlayingNotification = @"NowPlaying";

@interface NowPlaying ()
@property (atomic, readwrite) double elapsedTime;
@property (atomic, readwrite) double duration;
@property (atomic, readwrite) BOOL isPlaying;
@property (atomic, readwrite) BOOL isVideo;
@property (atomic, copy, readwrite) NSString * clientBundleIdentifier;
@property (nonatomic, strong) NSTimer * timer;
@end

// Minimal MediaRemote private API bridge (weak linked via dlsym)
typedef void (*MRMediaRemoteGetNowPlayingInfo_f)(dispatch_queue_t, void (^)(CFDictionaryRef));
typedef void (*MRMediaRemoteRegisterForNowPlayingNotifications_f)(dispatch_queue_t);
typedef id (*MRMediaRemoteCopyNowPlayingClient_f)(void);

static MRMediaRemoteGetNowPlayingInfo_f MRMediaRemoteGetNowPlayingInfo_ptr;
static MRMediaRemoteRegisterForNowPlayingNotifications_f MRMediaRemoteRegisterForNowPlayingNotifications_ptr;
static MRMediaRemoteCopyNowPlayingClient_f MRMediaRemoteCopyNowPlayingClient_ptr;

// CFString keys from MediaRemote (resolved via dlsym)
static CFStringRef kElapsedKey;
static CFStringRef kDurationKey;
static CFStringRef kPlaybackRateKey;
static CFStringRef kMediaTypeKey;
static CFStringRef kSupportsVideoKey;

@implementation NowPlaying

+ (NowPlaying *)sharedInstance
{
    static NowPlaying *instance = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NowPlaying alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (nil == self)
        return nil;

    _elapsedTime = NAN;
    _duration = NAN;
    _isPlaying = NO;
    _isVideo = NO;
    _clientBundleIdentifier = @"";

    [self setupMediaRemote];
    [self startTimer];
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)setupMediaRemote
{
    void *handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY);
    if (!handle) {
        return;
    }
    MRMediaRemoteGetNowPlayingInfo_ptr = (MRMediaRemoteGetNowPlayingInfo_f)dlsym(handle, "MRMediaRemoteGetNowPlayingInfo");
    MRMediaRemoteRegisterForNowPlayingNotifications_ptr = (MRMediaRemoteRegisterForNowPlayingNotifications_f)dlsym(handle, "MRMediaRemoteRegisterForNowPlayingNotifications");
    MRMediaRemoteCopyNowPlayingClient_ptr = (MRMediaRemoteCopyNowPlayingClient_f)dlsym(handle, "MRMediaRemoteCopyNowPlayingClient");

    if (MRMediaRemoteRegisterForNowPlayingNotifications_ptr) {
        MRMediaRemoteRegisterForNowPlayingNotifications_ptr(dispatch_get_main_queue());
    }

    // Resolve CFString keys safely
    void *sym;
    sym = dlsym(handle, "kMRMediaRemoteNowPlayingInfoElapsedTime");
    kElapsedKey = sym ? *(CFStringRef *)sym : NULL;
    sym = dlsym(handle, "kMRMediaRemoteNowPlayingInfoDuration");
    kDurationKey = sym ? *(CFStringRef *)sym : NULL;
    sym = dlsym(handle, "kMRMediaRemoteNowPlayingInfoPlaybackRate");
    kPlaybackRateKey = sym ? *(CFStringRef *)sym : NULL;
    sym = dlsym(handle, "kMRMediaRemoteNowPlayingInfoMediaType");
    kMediaTypeKey = sym ? *(CFStringRef *)sym : NULL;
    sym = dlsym(handle, "kMRMediaRemoteNowPlayingInfoSupportsVideo");
    kSupportsVideoKey = sym ? *(CFStringRef *)sym : NULL;
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(pollNowPlaying)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)pollNowPlaying
{
    if (!MRMediaRemoteGetNowPlayingInfo_ptr) {
        return;
    }
    MRMediaRemoteGetNowPlayingInfo_ptr(dispatch_get_main_queue(), ^(CFDictionaryRef dictRef){
        if (!dictRef) return;
        NSDictionary *info = (__bridge NSDictionary *)dictRef;

        id elapsedObj = kElapsedKey ? info[(__bridge id)kElapsedKey] : nil;
        id durationObj = kDurationKey ? info[(__bridge id)kDurationKey] : nil;
        id rateObj = kPlaybackRateKey ? info[(__bridge id)kPlaybackRateKey] : nil;
        id mediaTypeObj = kMediaTypeKey ? info[(__bridge id)kMediaTypeKey] : nil;
        id supportsVideoObj = kSupportsVideoKey ? info[(__bridge id)kSupportsVideoKey] : nil;

        // Fallback to string keys if CFString constants unavailable
        if (!elapsedObj) elapsedObj = info[@"kMRMediaRemoteNowPlayingInfoElapsedTime"];
        if (!durationObj) durationObj = info[@"kMRMediaRemoteNowPlayingInfoDuration"];
        if (!rateObj) rateObj = info[@"kMRMediaRemoteNowPlayingInfoPlaybackRate"];
        if (!mediaTypeObj) mediaTypeObj = info[@"kMRMediaRemoteNowPlayingInfoMediaType"];
        if (!supportsVideoObj) supportsVideoObj = info[@"kMRMediaRemoteNowPlayingInfoSupportsVideo"];

        id client = MRMediaRemoteCopyNowPlayingClient_ptr ? MRMediaRemoteCopyNowPlayingClient_ptr() : nil;
        NSString *bundleId = @"";
        if (client && [client respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
            bundleId = [client valueForKey:@"bundleIdentifier"] ?: @"";
        }
        if (bundleId.length == 0) {
            bundleId = [NSWorkspace sharedWorkspace].frontmostApplication.bundleIdentifier ?: @"";
        }
        double rateVal = 0.0;
        if ([rateObj respondsToSelector:@selector(doubleValue)]) {
            rateVal = [rateObj doubleValue];
        }
        BOOL playing = rateVal > 0.05;

        BOOL video = NO;
        if ([supportsVideoObj respondsToSelector:@selector(boolValue)]) {
            video = [supportsVideoObj boolValue];
        } else if ([mediaTypeObj respondsToSelector:@selector(intValue)]) {
            // Empirical: mediaType >= 2 indicates video in many builds
            video = [mediaTypeObj intValue] >= 2;
        } else if ([mediaTypeObj isKindOfClass:[NSString class]]) {
            video = [[[mediaTypeObj description] lowercaseString] containsString:@"video"];
        }

        double e = [elapsedObj respondsToSelector:@selector(doubleValue)] ? [elapsedObj doubleValue] : NAN;
        double d = [durationObj respondsToSelector:@selector(doubleValue)] ? [durationObj doubleValue] : NAN;

        // Fallback heuristic for browsers: if playing from a browser bundle and duration is present
        if (!video && playing && d > 0 && ( [bundleId containsString:@".google.Chrome"] || [bundleId containsString:@"chromium"] || [bundleId containsString:@"yandex"] || [bundleId containsString:@"Safari"] || [bundleId.lowercaseString containsString:@"comet"])) {
            video = YES;
        }

        BOOL changed = NO;
        if (_isPlaying != playing) { _isPlaying = playing; changed = YES; }
        if (_isVideo != video) { _isVideo = video; changed = YES; }
        if (!(_elapsedTime == e || (isnan(_elapsedTime) && isnan(e)))) { _elapsedTime = e; changed = YES; }
        if (!(_duration == d || (isnan(_duration) && isnan(d)))) { _duration = d; changed = YES; }
        if (![_clientBundleIdentifier isEqualToString:bundleId ?: @""]) { _clientBundleIdentifier = bundleId ?: @""; changed = YES; }

        if (changed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NowPlayingNotification object:self userInfo:nil];
        }
    });
}

@end


