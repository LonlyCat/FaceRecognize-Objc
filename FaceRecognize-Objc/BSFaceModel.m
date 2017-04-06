/**
 * This file is generated using the remodel generation script.
 * The name of the input file is BSFace.value
 */

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <UIKit/UIGeometry.h>
#import "BSFaceModel.h"

static NSUInteger HashFloat(float givenFloat) {
  union {
    float key;
    uint32_t bits;
  } u;
  u.key = givenFloat;
  NSUInteger h = (NSUInteger)u.bits;
#if !TARGET_RT_64_BIT
  h = ~h + (h << 15);
  h ^= (h >> 12);
  h += (h << 2);
  h ^= (h >> 4);
  h *= 2057;
  h ^= (h >> 16);
#else
  h += ~h + (h << 21);
  h ^= (h >> 24);
  h = (h + (h << 3)) + (h << 8);
  h ^= (h >> 14);
  h = (h + (h << 2)) + (h << 4);
  h ^= (h >> 28);
  h += (h << 31);
#endif
  return h;
}

static NSUInteger HashDouble(double givenDouble) {
  union {
    double key;
    uint64_t bits;
  } u;
  u.key = givenDouble;
  NSUInteger p = u.bits;
  p = (~p) + (p << 18);
  p ^= (p >> 31);
  p *=  21;
  p ^= (p >> 11);
  p += (p << 6);
  p ^= (p >> 22);
  return (NSUInteger) p;
}

static NSUInteger HashCGFloat(CGFloat givenCGFloat) {
#if CGFLOAT_IS_DOUBLE
    BOOL useDouble = YES;
#else
    BOOL useDouble = NO;
#endif
    if (useDouble) {
      return HashDouble(givenCGFloat);
    } else {
      return HashFloat(givenCGFloat);
    }
}

@implementation BSFaceModel

- (instancetype)initWithIdentifier:(NSUInteger)identifier eyesRect:(CGRect)eyesRect faceRect:(CGRect)faceRect
{
  if ((self = [super init])) {
    _identifier = identifier;
    _eyesRect = eyesRect;
    _faceRect = faceRect;
  }

  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ - \n\t identifier: %tu; \n\t eyesRect: %@; \n\t faceRect: %@; \n", [super description], _identifier, NSStringFromCGRect(_eyesRect), NSStringFromCGRect(_faceRect)];
}

- (NSUInteger)hash
{
  NSUInteger subhashes[] = {_identifier, HashCGFloat(_eyesRect.origin.x), HashCGFloat(_eyesRect.origin.y), HashCGFloat(_eyesRect.size.width), HashCGFloat(_eyesRect.size.height), HashCGFloat(_faceRect.origin.x), HashCGFloat(_faceRect.origin.y), HashCGFloat(_faceRect.size.width), HashCGFloat(_faceRect.size.height)};
  NSUInteger result = subhashes[0];
  for (int ii = 1; ii < 9; ++ii) {
    unsigned long long base = (((unsigned long long)result) << 32 | subhashes[ii]);
    base = (~base) + (base << 18);
    base ^= (base >> 31);
    base *=  21;
    base ^= (base >> 11);
    base += (base << 6);
    base ^= (base >> 22);
    result = base;
  }
  return result;
}

- (BOOL)isEqual:(BSFaceModel *)object
{
  if (self == object) {
    return YES;
  } else if (self == nil || object == nil || ![object isKindOfClass:[self class]]) {
    return NO;
  }
  return
    _identifier == object->_identifier &&
    CGRectEqualToRect(_eyesRect, object->_eyesRect) &&
    CGRectEqualToRect(_faceRect, object->_faceRect);
}

@end

