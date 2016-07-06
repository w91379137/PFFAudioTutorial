//
//  ViewController.m
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/5.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

#import "AudioRecorder.h"
#import "KKSimplePlayer.h"
#import "AudioEngineManager.h"

#define weakSelfMake(weakSelf) __weak __typeof(self)weakSelf = self;
#define weakMake(object,weakObject) __weak __typeof(object)weakObject = object;

@interface ViewController ()
{
    KKSimplePlayer *player;
    AudioRecorder *recorder;
    IBOutlet UILabel *displayLabel;
    
    AudioEngineManager *engineManager;
    
    IBOutlet UIButton *recButton;
    IBOutlet UIButton *playButton;
}

@end

@implementation ViewController

#pragma mark - Init
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    engineManager = [[AudioEngineManager alloc] init];
    [engineManager setup];
}

#pragma mark - Path
- (NSString *)path
{
    NSString *fileName = @"vfile";
    fileName = [fileName stringByAppendingString:@".wav"];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

#pragma mark - AudioQueuePlayer
- (IBAction)startPlayAction:(id)sender
{
    if (player) return;
    
    //測試連結
    //https://archive.org/details/testmp3testfile
    NSURL *url = [NSURL URLWithString:@"https://archive.org/download/testmp3testfile/mpthreetest.mp3"];
    player = [[KKSimplePlayer alloc] initWithURL:url];
    [player play];
}

- (IBAction)stopPlayAction:(id)sender
{
    [player pause];
    player = nil;
}

#pragma mark - AudioQueueRecorder
- (IBAction)startRecordAction:(id)sender
{
    if (recorder) return;
    
    recorder = [[AudioRecorder alloc] init];
    
    weakMake(displayLabel, weakObject);
    [recorder setCallBackBlock:^(float value) {
        weakObject.text = [NSString stringWithFormat:@"%f", value];
    }];
    [recorder startRecording];
}

- (IBAction)stopRecordAction:(id)sender
{
    [recorder stopRecording];
    recorder = nil;
}

#pragma mark - AudioEngineRecorder
- (IBAction)recButtonPushed
{
    if (engineManager.status == isPlaying) return;
    
    switch (engineManager.status) {
        case Default:
        {
            [engineManager record];
            [recButton setTitle:@"Rec Stop" forState:UIControlStateNormal];
        }
            break;
        case isRecording:
        {
            [engineManager stopRecord];
            [recButton setTitle:@"Rec Start" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

- (IBAction)playButtonPushed
{
    if (engineManager.status == isRecording) return;
    
    switch (engineManager.status) {
        case Default:
        {
            [engineManager playRecData];
            [playButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
            break;
        case isPlaying:
        {
            [engineManager stopRecData];
            [playButton setTitle:@"Play" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

@end
