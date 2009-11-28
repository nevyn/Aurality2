//
//  Aurality2AppDelegate.h
//  Aurality2
//
//  Created by Joachim Bengtsson on 2009-11-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FrequencyView.h"
#import "AudioRecorder.h"
#import "Constants.h"

@interface Aurality2AppDelegate : NSObject
<NSApplicationDelegate, AudioRecorderDelegate>
{
	NSWindow *window;
	IBOutlet FrequencyView *frequencyView;
	AudioRecorder	*recorder;
	
	double sectionArea[SectionCount];
	uint64_t sectionWasHighAt[SectionCount];

}

@property (assign) IBOutlet NSWindow *window;

@end
