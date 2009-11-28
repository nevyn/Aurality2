#define SectionCount 5
#import <QuartzCore/QuartzCore.h>

static inline NSTimeInterval AbsoluteToSeconds(int64_t absolute) {
	const Nanoseconds elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &absolute );
	const uint64_t elapsedNano2 = * (uint64_t *) &elapsedNano;
	return elapsedNano2/1000000000.;
}

static const double GameFreqLow = 1000,
									  GameFreqHigh = 2200;

#define cmagnitude(cplx) (sqrt(creal(cplx)*creal(cplx) + cimag(cplx)*cimag(cplx)))

static const double maxfreq = 22050.;

#define Deg2Rad(Deg) ((Deg * M_PI) / 180.0)
#define Rad2Deg(Rad) ((180.0 * Rad) / M_PI)

static inline NSRect ZeroedRect(NSRect r) {
	return (NSRect){.origin = {0,0}, .size = r.size};
}
static inline CGRect CGZeroedRect(CGRect r) {
	return (CGRect){.origin = {0,0}, .size = r.size};
}

typedef struct {
	uint32_t pointCount;
	CGPoint points[20];
} PathSpec;

static inline CGPathRef cgPathFromSpec(PathSpec spec) {
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, spec.points[0].x, spec.points[0].y);
	for(int i = 1; i < spec.pointCount; i++) {
		CGPathAddLineToPoint(path, NULL, spec.points[i].x, spec.points[i].y);	
	}
	return path;
}