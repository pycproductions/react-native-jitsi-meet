#import "RNJitsiMeetViewManager.h"
#import "RNJitsiMeetView.h"
#import <JitsiMeetSDK/JitsiMeetUserInfo.h>

@implementation RNJitsiMeetViewManager{
    RNJitsiMeetView *jitsiMeetView;
}

RCT_EXPORT_MODULE(RNJitsiMeetView)
RCT_EXPORT_VIEW_PROPERTY(onConferenceJoined, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onConferenceTerminated, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onConferenceWillJoin, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAudioMutedChanged, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onVideoMutedChanged, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEnteredPip, RCTBubblingEventBlock)

- (UIView *)view
{
  jitsiMeetView = [[RNJitsiMeetView alloc] init];
  jitsiMeetView.delegate = self;
  return jitsiMeetView;
}

RCT_EXPORT_METHOD(initialize)
{
    RCTLogInfo(@"Initialize is deprecated in v2");
}

RCT_EXPORT_METHOD(
  call:(NSString *)urlString
  userInfo:(NSDictionary *)userInfo
  meetOptions:(NSDictionary *)meetOptions
  meetFeatureFlags:(NSDictionary *)meetFeatureFlags)
{
    RCTLogInfo(@"Load URL %@", urlString);
    JitsiMeetUserInfo * _userInfo = [[JitsiMeetUserInfo alloc] init];
    if (userInfo != NULL) {
      if (userInfo[@"displayName"] != NULL) {
        _userInfo.displayName = userInfo[@"displayName"];
      }
      if (userInfo[@"email"] != NULL) {
        _userInfo.email = userInfo[@"email"];
      }
      if (userInfo[@"avatar"] != NULL) {
        NSURL *url = [NSURL URLWithString:[userInfo[@"avatar"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        _userInfo.avatar = url;
      }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {        
            builder.room = urlString;

            builder.token = meetOptions[@"token"];
            builder.subject = meetOptions[@"subject"];
            builder.videoMuted = [[meetOptions objectForKey:@"videoMuted"] boolValue];
            builder.audioOnly = [[meetOptions objectForKey:@"audioOnly"] boolValue];
            builder.audioMuted = [[meetOptions objectForKey:@"audioMuted"] boolValue];

            [builder setFeatureFlag:@"add-people.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"add-people.enabled"] boolValue]];
            [builder setFeatureFlag:@"calendar.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"calendar.enabled"] boolValue]];
            [builder setFeatureFlag:@"call-integration.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"call-integration.enabled"] boolValue]];
            [builder setFeatureFlag:@"chat.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"chat.enabled"] boolValue]];
            [builder setFeatureFlag:@"close-captions.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"close-captions.enabled"] boolValue]];
            [builder setFeatureFlag:@"invite.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"invite.enabled"] boolValue]];
            [builder setFeatureFlag:@"ios.recording.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"ios.recording.enabled"] boolValue]];
            [builder setFeatureFlag:@"live-streaming.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"live-streaming.enabled"] boolValue]];
            [builder setFeatureFlag:@"meeting-name.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"meeting-name.enabled"] boolValue]];
            [builder setFeatureFlag:@"meeting-password.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"meeting-password.enabled"] boolValue]];
            [builder setFeatureFlag:@"kick-out.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"kick-out.enabled"] boolValue]];
            [builder setFeatureFlag:@"pip.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"pip.enabled"] boolValue]];
            [builder setFeatureFlag:@"security-options.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"security-options.enabled"] boolValue]];
            [builder setFeatureFlag:@"raise-hand.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"raise-hand.enabled"] boolValue]];
            [builder setFeatureFlag:@"tile-view.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"tile-view.enabled"] boolValue]];
            [builder setFeatureFlag:@"video-share.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"video-share.enabled"] boolValue]];
            [builder setFeatureFlag:@"welcomepage.enabled" withBoolean:[[meetFeatureFlags objectForKey:@"welcomepage.enabled"] boolValue]];





            builder.userInfo = _userInfo;
        }];
        [jitsiMeetView join:options];
    });
}

RCT_EXPORT_METHOD(audioCall:(NSString *)urlString userInfo:(NSDictionary *)userInfo)
{
    RCTLogInfo(@"Load Audio only URL %@", urlString);
    JitsiMeetUserInfo * _userInfo = [[JitsiMeetUserInfo alloc] init];
    if (userInfo != NULL) {
      if (userInfo[@"displayName"] != NULL) {
        _userInfo.displayName = userInfo[@"displayName"];
      }
      if (userInfo[@"email"] != NULL) {
        _userInfo.email = userInfo[@"email"];
      }
      if (userInfo[@"avatar"] != NULL) {
        NSURL *url = [NSURL URLWithString:[userInfo[@"avatar"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        _userInfo.avatar = url;
      }
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {        
            builder.room = urlString;
            builder.userInfo = _userInfo;
            builder.audioOnly = YES;
        }];
        [jitsiMeetView join:options];
    });
}

RCT_EXPORT_METHOD(endCall)
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [jitsiMeetView leave];
    });
}

#pragma mark JitsiMeetViewDelegate

- (void)conferenceJoined:(NSDictionary *)data {
    RCTLogInfo(@"Conference joined");
    if (!jitsiMeetView.onConferenceJoined) {
        return;
    }

    jitsiMeetView.onConferenceJoined(data);
}

- (void)conferenceTerminated:(NSDictionary *)data {
    RCTLogInfo(@"Conference terminated");
    if (!jitsiMeetView.onConferenceTerminated) {
        return;
    }

    jitsiMeetView.onConferenceTerminated(data);
}

- (void)conferenceWillJoin:(NSDictionary *)data {
    RCTLogInfo(@"Conference will join");
    if (!jitsiMeetView.onConferenceWillJoin) {
        return;
    }

    jitsiMeetView.onConferenceWillJoin(data);
}

- (void)audioMutedChanged:(NSDictionary *)data {
    RCTLogInfo(@"Audio Muted Changed");
    if (!jitsiMeetView.onAudioMutedChanged) {
        return;
    }

    jitsiMeetView.onAudioMutedChanged(data);
}

- (void)videoMutedChanged:(NSDictionary *)data {
    RCTLogInfo(@"Video Muted Changed");
    if (!jitsiMeetView.onVideoMutedChanged) {
        return;
    }

    jitsiMeetView.onVideoMutedChanged(data);
}

- (void)enterPictureInPicture:(NSDictionary *)data {
    RCTLogInfo(@"Enter Picture in Picture");
    if (!jitsiMeetView.onEnteredPip) {
        return;
    }

    jitsiMeetView.onEnteredPip(data);
}

@end
