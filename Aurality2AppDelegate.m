//
//  Aurality2AppDelegate.m
//  Aurality2
//
//  Created by Joachim Bengtsson on 2009-11-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Aurality2AppDelegate.h"

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
	[frequencyView newData:ffts count:count];
}

@end
