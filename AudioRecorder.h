/*
	Adapted from Apple sample code "AudioRecorder". Not an AudioRecorder anymore.

*/


#import <Foundation/Foundation.h>
#import	"AudioQueueObject.h"
#include <complex.h>
#include "fftw3.h"

@class AudioRecorder;
@protocol AudioRecorderDelegate
@optional
// Called on worker thread:
-(void)recorder:(AudioRecorder*)recorder updatedFrequencies:(complex *)ffts;
// Called on main thread:
-(void)recorder:(AudioRecorder*)recorder updatedHighFrequency:(double)frequence amplitude:(double)amp;
@end


@interface AudioRecorder : AudioQueueObject <AudioRecorderDelegate> {
@public
	fftw_plan plan;
	double *fft_in;
	complex *fft_out;
	double frequencyRangeCoveredByOneBuffer;
	BOOL delegateWantsFrequencies;
	BOOL delegateWantsHighFrequency;

@protected
	BOOL	stopping;
	int bufferByteSize;
	id<AudioRecorderDelegate, NSObject> delegate;
}
@property int bufferSampleCount;
@property (readwrite) BOOL	stopping;
@property (assign, nonatomic) id<AudioRecorderDelegate, NSObject> delegate;

- (void) copyEncoderMagicCookieToFile: (AudioFileID) file fromQueue: (AudioQueueRef) queue;
- (void) setupAudioFormat: (UInt32) formatID;
- (void) setupRecording;

- (void) record;
- (void) stop;

@end
