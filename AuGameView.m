//
//  AuGameView.m
//  Aurality2
//
//  Created by Joachim Bengtsson on 2009-11-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AuGameView.h"

@implementation AuGameView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if(!self) return nil;
	
	[self setWantsLayer:YES];
	
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor redColor] set];
	NSRectFill(dirtyRect);
}

@end
