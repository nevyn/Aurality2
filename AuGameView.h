#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "BNZVector.h"

@interface AuLevel : CALayer
@end

@interface AuEntity : CALayer
{
	BNZVector *v, *a;
}
@property (copy) BNZVector *v;
@property (copy) BNZVector *a;
-(void)update:(NSTimeInterval)delta;
@end

@interface AuCannon : CALayer {
	BOOL firing;
	CGColorRef color;
	CAEmitterCell *sparkCell;
	CAEmitterLayer *sparker;
}
@property BOOL firing;
@property (readonly, assign) CGColorRef color;
@end


@interface AuPlayer : AuEntity {
	PathSpec star;
	CAShapeLayer *cannonContainer;
	NSArray *cannons;
	float rv, ra, r;
}
@property float rv;
@property float ra;
@property float r;
-(AuCannon*)objectInCannonsAtIndex:(unsigned)idx;
@end

enum {
	Upkey,
	Downkey,
	Leftkey,
	Rightkey,
	RotateLeft,
	RotateRight,
	ActionKeyCount
};

@interface AuGameView : NSView
{
	CALayer *level;
	AuPlayer *player;
	NSTimer *pollTimer;
	uint64_t lastUpdate;
	BOOL keys[ActionKeyCount];
	
	CGSize actionVector;
	float rotationAction;
}
-(void)startFiring:(unsigned)cannonIdx;
-(void)stopFiring:(unsigned)cannonIdx;
@end