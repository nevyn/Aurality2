//
//  AuGameView.m
//  Aurality2
//
//  Created by Joachim Bengtsson on 2009-11-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AuGameView.h"
#import "Constants.h"
#import "NSColor+CGColor.h"
#import <mach/mach.h>
#import <mach/mach_time.h>


@implementation AuEntity
@synthesize a,v;
-(id)init;
{
	if(![super init]) return nil;
	
	self.v = [BNZVector vectorX:0 y:0];
	self.a = [BNZVector vectorX:0 y:0];
	
	return self;
}
-(void)update:(NSTimeInterval)delta;
{
	BNZVector *pos = VecCG(self.position);
	self.v = [[self.v sumWithVector:[self.a vectorScaledBy:delta]] vectorScaledBy:0.95];
	
	pos = [pos sumWithVector:[self.v vectorScaledBy:delta]];
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	self.position = pos.asCGPoint;
	[CATransaction commit];
}
@end

@interface AuCannon ()
@property (readwrite, assign) CGColorRef color;
@property (retain) CAEmitterLayer *sparker;
@end
@implementation AuCannon
@synthesize firing, color, sparker;
-(id)init;
{
	if(![super init]) return nil;
	
	sparkCell = [[CAEmitterCell emitterCell] retain];
	const char* fileName = [[[NSBundle mainBundle] pathForResource:@"tspark" ofType:@"png"] UTF8String];
	CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename(fileName);
	CGImageRef img = CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);

	sparkCell = [[CAEmitterCell emitterCell] retain];
	sparkCell.contents = (id)img;
	CGDataProviderRelease(dataProvider);
	CGImageRelease(img);
	
	sparkCell.birthRate = 100;
	sparkCell.emissionRange = Deg2Rad(15.);
	sparkCell.scale = 0.4;
	sparkCell.velocityRange = 10;
	sparkCell.lifetime = 1;
	sparkCell.alphaSpeed = -2.0;
	sparkCell.beginTime = 0;
	sparkCell.duration = 0.1;
	sparkCell.emissionRange = 2 * M_PI;
	sparkCell.scaleSpeed = -0.1;
	sparkCell.spinRange = 10;
	sparkCell.emissionLatitude = 0;

	
	return self;
}
-(void)setColor:(CGColorRef)col;
{
	color = col;
	sparkCell.color = col;
}
-(void)dealloc;
{
	CGColorRelease(color);
	[sparkCell release];
	[sparker release];
	[super dealloc];
}
-(void)setFiring:(BOOL)fire;
{
	if(fire == firing) return;
	firing = fire;
	
	if(fire) {
		BNZVector *o = VecXY(64,64);
		BNZVector *dir = [VecCG(self.position) differenceFromVector:o];
		BNZVector *vec = [dir productWithScalar:10];
		sparkCell.emissionLongitude = [vec angle];
		sparkCell.xAcceleration = vec.x;
		sparkCell.yAcceleration = vec.y;
		
		self.sparker = [CAEmitterLayer layer];
		
		sparker.renderMode = kCAEmitterLayerAdditive;
		sparker.emitterCells = [NSArray arrayWithObject:sparkCell];
		
		[self addSublayer:sparker];	
	} else {
		[self.sparker removeFromSuperlayer];
		self.sparker = nil;
	}
		
	
}
@end



@implementation AuPlayer
@synthesize ra, rv, r;
-(id)init;
{
	if(![super init]) return nil;
	self.frame = (CGRect){.size = {128,128}};
	
	CAShapeLayer *bottom = [CAShapeLayer layer]; bottom.frame = self.frame;
	bottom.path = cgPathFromSpec((PathSpec){
		4,
		{
			{64, 32}, {96, 64}, {64, 96}, {32, 64}
		}
	});
	bottom.fillColor = CGColorCreateGenericRGB(0.6, 0.4, 0.4, 1.0);
	
	static const float l = 96, s = 30;
	cannonContainer = [CALayer layer]; cannonContainer.frame = self.frame;
	CALayer *cannonMount = [CALayer layer]; cannonMount.frame = self.frame;
	[cannonContainer addSublayer:cannonMount];
	CAShapeLayer *cannonMask = [CAShapeLayer layer];
	cannonMount.mask = cannonMask;
	cannonMask.path = cgPathFromSpec(star = (PathSpec){
		10,
		{
			#define edge(i, sz) {cos(Deg2Rad(-36*i))*(sz/2)+128/2, sin(Deg2Rad(-36*i))*(sz/2)+128/2}
			edge(0, l),
			edge(1, s),
			edge(2, l),
			edge(3, s),
			edge(4, l),
			edge(5, s),
			edge(6, l),
			edge(7, s),
			edge(8, l),
			edge(9, s),
		}
	});
	cannonMount.masksToBounds = YES;
	cannonMount.contents = (id)[[NSImage imageNamed:@"cannon.png"] CGImageForProposedRect:NULL context:NULL hints:nil];
	
	CAShapeLayer *top = [CAShapeLayer layer]; top.frame = self.frame;
	top.path = cgPathFromSpec((PathSpec){
		4,
		{
			{64, 40}, {88, 64}, {64, 88}, {40, 64}
		}
	});
	top.fillColor = CGColorCreateGenericRGB(0.4, 0.0, 0.6, 1.0);
	
	[self addSublayer:bottom];
	[self addSublayer:cannonContainer];
	[self addSublayer:top];
	
	cannons = [[NSArray alloc] initWithObjects:
		[AuCannon layer], [AuCannon layer], [AuCannon layer],
		[AuCannon layer], [AuCannon layer],
	nil];
	for(int i = 0; i < 5; i++) {
		AuCannon *cannon = [cannons objectAtIndex:i];
		cannon.position = star.points[i*2];
		cannon.color = [[NSColor colorWithCalibratedHue:i/(float)SectionCount saturation:.6 brightness:.8 alpha:1.0] CGColor];
		[cannonContainer addSublayer:cannon];
	}
		
	return self;
}
-(void)dealloc;
{
	[cannons release];
	[super dealloc];
}
-(void)update:(NSTimeInterval)delta;
{
	[super update:delta];
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	rv = (rv + ra*delta)*0.9;
	r += rv*delta;
	
	cannonContainer.transform = CATransform3DMakeRotation(r, 0, 0, 1);	
	[CATransaction commit];

}
-(AuCannon*)objectInCannonsAtIndex:(unsigned)idx;
{
	return [cannons objectAtIndex:idx];
}
@end

@implementation AuLevel

@end



@implementation AuGameView

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if(!self) return nil;
	
	[self setWantsLayer:YES];
	
	level = [AuLevel layer];
	[self.layer addSublayer:level];
	level.frame = NSRectToCGRect(ZeroedRect(frame));
	level.autoresizingMask = kCALayerWidthSizable|kCALayerHeightSizable;
	level.backgroundColor = CGColorCreateGenericRGB(0.5, 0.5, 0.7, 1.0);
	
	player = [AuPlayer layer];
	[level addSublayer:player];
	player.position = (CGPoint){300, 300};
	
	pollTimer = [NSTimer scheduledTimerWithTimeInterval:1./60. target:self selector:@selector(update) userInfo:nil repeats:YES];
	lastUpdate = mach_absolute_time();
	
	return self;
}
-(void)dealloc;
{
	[pollTimer invalidate];
	[super dealloc];
}
-(BOOL)acceptsFirstResponder;
{
	return YES;
}

-(void)update;
{
	uint64_t now = mach_absolute_time();
	NSTimeInterval delta = AbsoluteToSeconds(now-lastUpdate);
	lastUpdate = now;
	[player update:delta];
}

-(void)setActionVector;
{
	actionVector.width = keys[Leftkey] ? -1 : (keys[Rightkey] ? 1 : 0);
	actionVector.height = keys[Downkey] ? -1 : (keys[Upkey] ? 1 : 0);
	rotationAction = keys[RotateRight] ? -1 : (keys[RotateLeft] ? 1 : 0);
	
	player.a = VecXY(actionVector.width*450, actionVector.height*450);
	player.ra = rotationAction*M_PI*6.;
}
#define setkeys(keychar, keyname, value) 	if([[theEvent charactersIgnoringModifiers] rangeOfString:keychar].location != NSNotFound) keys[keyname] = value;
- (void)keyDown:(NSEvent *)theEvent;
{
	setkeys(@"a", Leftkey, YES);
	setkeys(@"d", Rightkey, YES);
	setkeys(@"w", Upkey, YES);
	setkeys(@"s", Downkey, YES);
	setkeys(@"q", RotateLeft, YES);
	setkeys(@"e", RotateRight, YES);

	[self setActionVector];
}
- (void)keyUp:(NSEvent *)theEvent;
{
	setkeys(@"a", Leftkey, NO);
	setkeys(@"d", Rightkey, NO);
	setkeys(@"w", Upkey, NO);
	setkeys(@"s", Downkey, NO);
	setkeys(@"q", RotateLeft, NO);
	setkeys(@"e", RotateRight, NO);
	[self setActionVector];
}
-(void)mouseDown:(NSEvent*)evt;
{
	[self startFiring:0];
}
-(void)mouseUp:(NSEvent *)theEvent;
{
	[self stopFiring:0];
}

-(void)startFiring:(unsigned)cannonIdx;
{
	[player objectInCannonsAtIndex:cannonIdx].firing = YES;
}
-(void)stopFiring:(unsigned)cannonIdx;
{
	[player objectInCannonsAtIndex:cannonIdx].firing = NO;
}
@end
