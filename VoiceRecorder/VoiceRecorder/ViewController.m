//
//  ViewController.m
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/5.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import "ViewController.h"
#import "AudioRecorder.h"
#import "KKSimplePlayer.h"

#define weakSelfMake(weakSelf) __weak __typeof(self)weakSelf = self;
#define weakMake(object,weakObject) __weak __typeof(object)weakObject = object;

@interface ViewController ()
{
    KKSimplePlayer *player;
    AudioRecorder *recorder;
    IBOutlet UILabel *displayLabel;
}

@end

@implementation ViewController

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

@end
