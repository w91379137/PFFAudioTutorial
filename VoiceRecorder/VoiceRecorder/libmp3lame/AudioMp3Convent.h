//
//  AudioMp3Convent.h
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/6.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioMp3Convent : NSObject

@property(nonatomic, strong) NSString *inputPath;
@property(nonatomic, strong) NSString *outputPath;
@property(nonatomic) BOOL isStopRecorde;
@property(nonatomic) BOOL isFinishConvert;

- (void)conventToMp3;

@end
