//
//  FrequencyView.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <complex.h>

#define SectionCount 5

@interface FrequencyView : NSView {
	int numCount;
	complex *fft;
	double max;
	
	double sectionArea[SectionCount];
	uint64_t sectionWasHighAt[SectionCount];
	
}
-(void)newData:(complex*)fft_ count:(int)count_;
@end
