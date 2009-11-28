//
//  FrequencyView.h
//  Aurality
//
//  Created by Joachim Bengtsson on 2009-04-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <complex.h>
#import "Constants.h"


@interface FrequencyView : NSView {
	int numCount;
	complex *fft;
	double max;
	
@public
	BOOL sectionIsHigh[SectionCount];
	
}
-(void)newData:(complex*)fft_ count:(int)count_;
@end
