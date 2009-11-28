//
//  FrequencyView.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "FrequencyView.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

NSTimeInterval AbsoluteToSeconds(int64_t absolute) {
	const Nanoseconds elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &absolute );
	const uint64_t elapsedNano2 = * (uint64_t *) &elapsedNano;
	return elapsedNano2/1000000000.;
}


@implementation FrequencyView


- (id)initWithFrame:(NSRect)frame {
    if ( ! [super initWithFrame:frame]) return nil;
	
	fft = NULL;
	numCount = 0;
	max = 400;
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(NSRect)rect {
	if( ! numCount ) return;
	
	static const double skip = 6;
	
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	[[NSColor grayColor] set];
	
		
	// y labels
	static const int labelCount = 10;
	float heightPerLabel = self.frame.size.height/labelCount;
	for(int y = 0; y < labelCount; y++) {
		float this = (max/labelCount)*y;
		[(NSString*)[NSString stringWithFormat:@"%.0e", this] drawAtPoint:(NSPoint){5, heightPerLabel*y} withAttributes:nil];
	}
	
	static const double maxfreq = 22050.;
	double freqPerIdx = maxfreq/numCount;

	#define magat(idx) sqrt(creal(fft[idx])*creal(fft[idx]) + cimag(fft[idx])*cimag(fft[idx]));
	
	for(int i = 0; i < numCount; i++) {
		double mag = magat(i);
		
		max = MAX(mag,max);
		
		double height = (mag/max)*self.frame.size.height;
		NSRect r = NSMakeRect(i*skip, 0, skip, height);
		
		
		[[NSColor grayColor] set];
		NSRectFill(r);
	}
	
	static const double low = 1000, high = 2200;
	const double lowidx = low/freqPerIdx, highidx = high/freqPerIdx;
	bzero(sectionArea, SectionCount*sizeof(double));
	for(int i = 0; i < SectionCount; i++) {
		const double freqwidth = ((highidx-lowidx)/SectionCount);
		const double freqidx = lowidx + freqwidth*i;
		for(int j = freqidx; j < freqidx+freqwidth; j++)
			sectionArea[i] += magat(j);
		
		if(sectionArea[i] > 2e7)
			sectionWasHighAt[i] = mach_absolute_time();
		else if(AbsoluteToSeconds(mach_absolute_time()-sectionWasHighAt[i]) > 0.2)
			sectionWasHighAt[i] = 0;
		
		double alpha = sectionWasHighAt[i] ? .8 : .4;

		
		NSRect r = NSMakeRect(freqidx*skip, 0, freqwidth*skip, self.bounds.size.height);
		[[NSColor colorWithCalibratedHue:i/(float)SectionCount saturation:.6 brightness:.8 alpha:alpha] set];
		NSRectFillUsingOperation(r, NSCompositeSourceOver);
		
		[(NSString*)[NSString stringWithFormat:@"%.1e", sectionArea[i]] drawAtPoint:(NSPoint){r.origin.x, r.size.height-17} withAttributes:nil];

	}
	
	
	// x labels
	float widthPerLabel = self.frame.size.width/labelCount;
	for(int x = 0; x < labelCount; x++) {
		float this = widthPerLabel*x;
		[(NSString*)[NSString stringWithFormat:@"%.0f", this*freqPerIdx/skip] drawAtPoint:(NSPoint){this, 0} withAttributes:[NSDictionary dictionaryWithObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName]];

	}
	
	
	[(NSString*)[NSString stringWithFormat:@"%d", numCount] drawAtPoint:(NSPoint){self.bounds.size.width-35, self.bounds.size.height-17} withAttributes:nil];

	
	
}



-(void)newData:(complex*)fft_ count:(int)count_;
{
	fft = fft_;
	numCount = count_;
	[self performSelectorOnMainThread:@selector(setNeedsDisplay:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
}

@end
