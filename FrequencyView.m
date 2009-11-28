//
//  FrequencyView.m
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "FrequencyView.h"


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
	
	static const double skip = 2;
	
	[[NSColor clearColor] set];
	NSRectFill(rect);
	
	[[NSColor grayColor] set];
	
	NSDictionary *whiteattr = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor whiteColor], NSForegroundColorAttributeName,
		[NSFont systemFontOfSize:9], NSFontAttributeName,
		nil
	];
	
		
	// y labels
	static const int labelCount = 10;
	float heightPerLabel = self.frame.size.height/labelCount;
	for(int y = 0; y < labelCount; y++) {
		float this = (max/labelCount)*y;
		[(NSString*)[NSString stringWithFormat:@"%.1e", this] drawAtPoint:(NSPoint){5, heightPerLabel*y} withAttributes:whiteattr];
	}
	
	double freqPerIdx = maxfreq/numCount;

	
	for(int i = 0; i < numCount; i++) {
		double mag = cmagnitude(fft[i]);
		
		max = MAX(mag,max);
		
		double height = (mag/max)*self.frame.size.height;
		NSRect r = NSMakeRect(i*skip, 0, skip, height);
		
		
		[[NSColor lightGrayColor] set];
		NSRectFill(r);
	}
	
	const double lowidx = GameFreqLow/freqPerIdx, highidx = GameFreqHigh/freqPerIdx;
	for(int i = 0; i < SectionCount; i++) {
		double alpha = sectionIsHigh[i] ? 0.8 : 0.4;
		const double freqwidth = ((highidx-lowidx)/SectionCount);
		const double freqidx = lowidx + freqwidth*i;

		NSRect r = NSMakeRect(freqidx*skip, 0, freqwidth*skip, self.bounds.size.height);
		[[NSColor colorWithCalibratedHue:i/(float)SectionCount saturation:.6 brightness:.8 alpha:alpha] set];
		NSRectFillUsingOperation(r, NSCompositeSourceOver);
	}
	
	
	// x labels
	float widthPerLabel = self.frame.size.width/labelCount;
	for(int x = 0; x < labelCount; x++) {
		float this = widthPerLabel*x;
		[(NSString*)[NSString stringWithFormat:@"%.0f", this*freqPerIdx/skip] drawAtPoint:(NSPoint){this, 0} withAttributes:whiteattr];

	}
	
	
	[(NSString*)[NSString stringWithFormat:@"%d", numCount] drawAtPoint:(NSPoint){self.bounds.size.width-35, self.bounds.size.height-17} withAttributes:whiteattr];

	
	
}



-(void)newData:(complex*)fft_ count:(int)count_;
{
	fft = fft_;
	numCount = count_;
	[self performSelectorOnMainThread:@selector(setNeedsDisplay:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
}

@end
