//
//  Aurality2AppDelegate.m
//  Aurality2
//
//  Created by Joachim Bengtsson on 2009-11-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Aurality2AppDelegate.h"
#include <mach/mach.h>
#include <mach/mach_time.h>


@implementation Aurality2AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	recorder = [[AudioRecorder alloc] init];
	recorder.delegate = self;
	[recorder record];
}

-(void)recorder:(AudioRecorder*)recorder_ updatedFrequencies:(complex *)ffts;
{
	int count = recorder_.bufferSampleCount/2 + 1;
	
	double freqPerIdx = maxfreq/count;
	
	const double lowidx = GameFreqLow/freqPerIdx, highidx = GameFreqHigh/freqPerIdx;
	bzero(sectionArea, SectionCount*sizeof(double));
	for(int i = 0; i < SectionCount; i++) {
		const double freqwidth = ((highidx-lowidx)/SectionCount);
		const double freqidx = lowidx + freqwidth*i;
		for(int j = freqidx; j < freqidx+freqwidth; j++)
			sectionArea[i] += cmagnitude(ffts[j]);
		
		if(sectionArea[i] > 2e7) {
			sectionWasHighAt[i] = mach_absolute_time();
			frequencyView->sectionIsHigh[i] = YES;
		} else if(AbsoluteToSeconds(mach_absolute_time()-sectionWasHighAt[i]) > 0.2) {
			sectionWasHighAt[i] = 0;
			frequencyView->sectionIsHigh[i] = NO;
		}
	}
	

	
	[frequencyView newData:ffts count:count];
}

@end
