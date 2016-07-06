//
//  AudioEngineManager.m
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/6.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import "AudioEngineManager.h"
//#import "AudioMp3Convent.h"

@interface AudioEngineManager()
//{
//    AudioMp3Convent *conventer;
//}

@end

@implementation AudioEngineManager

- (NSDictionary *)recSettings
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[AVFormatIDKey] = @(kAudioFormatMPEG4AAC);
    dict[AVEncoderAudioQualityKey] = @(AVAudioQualityHigh);
    dict[AVNumberOfChannelsKey] = @1; //iphone 只有一個
    dict[AVSampleRateKey] = @22050.0f;//KHz 音質 廣播
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
    [dirPath addObject:@"rec.aac"];
    
    NSURL *filePath = [NSURL fileURLWithPathComponents:dirPath];
    //NSLog(@"Path :%@",filePath.path);
    return filePath;
}

//- (NSURL *)mp3FileURL
//{
//    NSString *mp3FileName = @"Mp3File";
//    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//    NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:mp3FileName];
//    return [NSURL fileURLWithPath:mp3FilePath];
//}

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
                bufferSize:4096
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
        
//        conventer = [[AudioMp3Convent alloc] init];
//        conventer.inputPath = [self recFileURL].path;
//        conventer.outputPath = [self mp3FileURL].path;
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            [conventer conventToMp3];
//        });
    }
}

- (void)stopRecord
{
    self.status = Default;
    [audioEngine.inputNode removeTapOnBus:0];
    [audioEngine stop];
    
    //conventer.isStopRecorde = YES;
}

- (void)playRecData
{
    //if (outputFile.length == 0) return;
    
    NSURL *url = [self recFileURL];
    
    {//列印檔案大小
        NSDictionary *fileAttributes =
        [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:nil];
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        long long fileSize = [fileSizeNumber longLongValue];
        NSLog(@"fileSize : %lld",fileSize);
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url
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
