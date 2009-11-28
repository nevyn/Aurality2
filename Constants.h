#define SectionCount 5

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
