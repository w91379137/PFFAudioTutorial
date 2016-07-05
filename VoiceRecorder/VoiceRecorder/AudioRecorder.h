//http://hemantasapkota.github.io/posts/record-audio-in-floatbuffer-using-audioqueue/

#ifndef SpeechBookWormSwift_AudioRecorder_h
#define SpeechBookWormSwift_AudioRecorder_h

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 1

typedef struct
{
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         buffers[NUM_BUFFERS];
    AudioFileID                 audioFile;
    SInt64                      currentPacket;
    bool                        recording;
}RecordState;

void AudioInputCallback(void * inUserData,  // Custom audio metadata
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp * inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription * inPacketDescs);

@interface AudioRecorder : NSObject {
    RecordState recordState;
}

@property (nonatomic, copy) void (^callBackBlock)(float);

//- (void)setupAudioFormat:(AudioStreamBasicDescription*)format;
- (void)startRecording;
- (void)stopRecording;
//- (void)feedSamplesToEngine:(UInt32)audioDataBytesCapacity audioData:(void *)audioData;

@end
#endif
