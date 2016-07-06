//
//  AudioWrapper.m
//  Lame
//
//  Created by w91379137 on 2016/6/20.
//  Copyright © 2016年 w91379137. All rights reserved.
//

#import "AudioWrapper.h"
#import "lame/lame.h"

@implementation AudioWrapper

//http://stackoverflow.com/questions/31452202/ios-swift-merge-and-convert-wav-files-to-mp3

//http://stackoverflow.com/questions/26835891/encoding-audio-with-lame-converting-32bit-float-to-mp3

+ (void)convertFromWavToMp3:(NSString *)filePath
{
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:mp3FileName];
    
    NSLog(@"%@", mp3FilePath);
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192 * 4;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100 / 32);
        lame_set_VBR(lame, vbr_default);
        //lame_set_out_samplerate(lame, 48000);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
//        [self performSelectorOnMainThread:@selector(convertMp3Finish)
//                               withObject:nil
//                            waitUntilDone:YES];
    }
}
@end

