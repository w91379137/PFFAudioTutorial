//
//  AudioEngineManager.m
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/6.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import "AudioEngineManager.h"

@implementation AudioEngineManager

- (NSDictionary *)recSettings
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[AVFormatIDKey] = @(kAudioFormatLinearPCM);
    dict[AVEncoderAudioQualityKey] = @(AVAudioQualityHigh);
    dict[AVNumberOfChannelsKey] = @1;
    dict[AVSampleRateKey] = @44100.0f;
    dict[AVLinearPCMBitDepthKey] = @16;
    
    return dict;
}

- (void)setup
{
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:&error];
    if (error) NSLog(@"%@",error);
    
    audioEngine = [[AVAudioEngine alloc] init];
    
    AVAudioInputNode *input = audioEngine.inputNode;
    AVAudioMixerNode *mixer = audioEngine.mainMixerNode;
    
    AVAudioUnitDistortion *distortion = [[AVAudioUnitDistortion alloc] init];
    [distortion loadFactoryPreset:AVAudioUnitDistortionPresetDrumsLoFi];
    
    [audioEngine attachNode:distortion];
    [audioEngine connect:input
                      to:distortion
                  format:[input inputFormatForBus:0]];
    [audioEngine connect:distortion
                      to:mixer
                  format:[input inputFormatForBus:0]];
}

- (NSURL *)recFileURL
{
    NSMutableArray *dirPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) mutableCopy];
    [dirPath addObject:@"rec.caf"];
    
    NSURL *filePath = [NSURL fileURLWithPathComponents:dirPath];
    //NSLog(@"Path :%@",filePath.path);
    return filePath;
}

- (void)removeRecFile
{
    NSString *path = [self recFileURL].path;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
}

- (void)record
{
    self.status = isRecording;
    [self removeRecFile];
    
    NSError *error = nil;
    outputFile = [[AVAudioFile alloc] initForWriting:[self recFileURL]
                                            settings:[self recSettings]
                                               error:&error];
    
    AVAudioInputNode *input = audioEngine.inputNode;
    input.volume = 0;
    [input installTapOnBus:0
                bufferSize:1024//4096
                    format:[input inputFormatForBus:0]
                     block:^(AVAudioPCMBuffer * _Nonnull buffer,
                             AVAudioTime * _Nonnull when) {
                         
                         NSError *error = nil;
                         [outputFile writeFromBuffer:buffer error:nil];
                         if (error) NSLog(@"%@",error);
                         
                         NSLog(@"AudioEngineManager 錄音中");
                     }];
    
    if (!audioEngine.running) {
        NSError *error = nil;
        //[audioEngine prepare];
        [audioEngine startAndReturnError:&error];
        if (error) NSLog(@"%@",error);
    }
}

- (void)stopRecord
{
    self.status = Default;
    [audioEngine.inputNode removeTapOnBus:0];
    [audioEngine stop];
}

- (void)playRecData
{
    if (outputFile.length == 0) return;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self recFileURL]
                                                              error:nil];
    
    self.audioPlayer.volume = 1.0;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
    self.status = isPlaying;
}

- (void)stopRecData
{
    [self.audioPlayer stop];
    self.status = Default;
}

@end
