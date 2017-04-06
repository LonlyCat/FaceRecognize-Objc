/**
 * This file is generated using the remodel generation script.
 * The name of the input file is BSFace.value
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface BSFaceModel : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger identifier;
@property (nonatomic, readonly) CGRect eyesRect;
@property (nonatomic, readonly) CGRect faceRect;

- (instancetype)initWithIdentifier:(NSUInteger)identifier eyesRect:(CGRect)eyesRect faceRect:(CGRect)faceRect;

@end

