//
//  AudioMp3Convent.m
//  VoiceRecorder
//
//  Created by w91379137 on 2016/7/6.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import "AudioMp3Convent.h"
#import "lame/lame.h"

//http://www.jianshu.com/p/57f38f075ba0

@implementation AudioMp3Convent

- (float)sampleRate
{
    return 44100.0f;
}

- (void)conventToMp3
{
    NSString *cafFilePath = _inputPath;
    NSString *mp3FilePath = _outputPath;
    
    self.isStopRecorde = NO;
    self.isFinishConvert = NO;
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, self.sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        long curpos;
        BOOL isSkipPCMHeader = NO;
        
        do {
            
            curpos = ftell(pcm);
            
            long startPos = ftell(pcm);
            
            fseek(pcm, 0, SEEK_END);
            long endPos = ftell(pcm);
            
            long length = endPos - startPos;
            
            fseek(pcm, curpos, SEEK_SET);
            
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                
                if (!isSkipPCMHeader) {
                    //Uump audio file header, If you do not skip file header
                    //you will heard some noise at the beginning!!!
                    fseek(pcm, 4 * 1024, SEEK_SET);
                    isSkipPCMHeader = YES;
                }
                
                read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                NSLog(@"gg");
            }
            
            else {
                [NSThread sleepForTimeInterval:0.05];
            }
            
        } while (!self.isStopRecorde);
        
        read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        self.isFinishConvert = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    @finally {
        NSLog(@"convert mp3 finish!!!");
    }
}

@end
