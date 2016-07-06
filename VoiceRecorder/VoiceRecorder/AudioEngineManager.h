//
//  AudioEngineManager.h
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/6.
//  Copyright © 2016年 w91379137. All rights reserved.
//

//https://github.com/ahirusun/AVAudioEngineSample
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, State) {
    Default,
    isRecording,
    isPlaying
};

@interface AudioEngineManager : NSObject
{
    AVAudioEngine *audioEngine;
    AVAudioFile *outputFile;
}

@property(nonatomic) State status;
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;

- (void)setup;
- (NSURL *)recFileURL;
- (void)removeRecFile;
- (void)record;
- (void)stopRecord;
- (void)playRecData;
- (void)stopRecData;

@end
