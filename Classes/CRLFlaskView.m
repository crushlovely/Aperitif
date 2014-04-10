// Aperitif
// Copyright (c) 2014, Crush & Lovely <engineering@crushlovely.com>
// Under the MIT License; see LICENSE file for details.

#import "CRLFlaskView.h"


@interface CRLFlaskView ()

@property (nonatomic, strong) UIImage *dot;

@end


@implementation CRLFlaskView

+(Class)layerClass
{
    return [CAEmitterLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
        [self reallyInit];

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
       [self reallyInit];

    return self;
}

-(void)reallyInit
{
    [self initLayer];
    self.userInteractionEnabled = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ((CAEmitterLayer *)self.layer).birthRate += 0.5;
}

-(void)createDot
{
    // Circle for the emitter cell. We make it slightly off-center, so that the
    // spin on the particle makes it wobble a bit.
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(80.0, 80.0), NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0, 0.0, 77.0, 77.0)];
    [[UIColor whiteColor] setFill];
    [path fill];
    self.dot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)drawRect:(CGRect)rect
{
    // This is exported from PaintCode, with minor edits.

    CGFloat dimension = MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));

    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0.66349 * dimension,  0.90234 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.33651 * dimension,  0.90234 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.28228 * dimension,  0.81609 * dimension) controlPoint1: CGPointMake(0.29223 * dimension,  0.90234 * dimension) controlPoint2: CGPointMake(0.26309 * dimension,  0.85600 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.37531 * dimension,  0.62261 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.41464 * dimension,  0.45005 * dimension) controlPoint1: CGPointMake(0.40120 * dimension,  0.56877 * dimension) controlPoint2: CGPointMake(0.41464 * dimension,  0.50979 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.41464 * dimension,  0.41169 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.47162 * dimension,  0.41169 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.44005 * dimension,  0.61780 * dimension) controlPoint1: CGPointMake(0.47162 * dimension,  0.45240 * dimension) controlPoint2: CGPointMake(0.47646 * dimension,  0.52635 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.52009 * dimension,  0.61780 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.62178 * dimension,  0.83125 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.65454 * dimension,  0.81789 * dimension) controlPoint1: CGPointMake(0.63300 * dimension,  0.85472 * dimension) controlPoint2: CGPointMake(0.66617 * dimension,  0.84205 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.57297 * dimension,  0.64747 * dimension) controlPoint1: CGPointMake(0.64410 * dimension,  0.79620 * dimension) controlPoint2: CGPointMake(0.62467 * dimension,  0.75500 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.52829 * dimension,  0.41169 * dimension) controlPoint1: CGPointMake(0.52143 * dimension,  0.54028 * dimension) controlPoint2: CGPointMake(0.52829 * dimension,  0.45234 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.58536 * dimension,  0.41169 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.58536 * dimension,  0.45005 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.62469 * dimension,  0.62261 * dimension) controlPoint1: CGPointMake(0.58536 * dimension,  0.50979 * dimension) controlPoint2: CGPointMake(0.59880 * dimension,  0.56877 * dimension)];
    [bezierPath addLineToPoint: CGPointMake(0.71772 * dimension,  0.81609 * dimension)];
    [bezierPath addCurveToPoint: CGPointMake(0.66349 * dimension,  0.90234 * dimension) controlPoint1: CGPointMake(0.73691 * dimension,  0.85600 * dimension) controlPoint2: CGPointMake(0.70777 * dimension,  0.90234 * dimension)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    [[UIColor blackColor] setFill];
    [bezierPath fill];
}

-(void)initLayer
{
    [self createDot];

    // Exported from ParticlePlayground, with minor edits.

    CAEmitterLayer *emitterLayer = (CAEmitterLayer *)self.layer;
    emitterLayer.name = @"emitterLayer";
    CGPoint emitterPosition = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) / 3.2);
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) emitterPosition.y -= 10.0;
    emitterLayer.emitterPosition = emitterPosition;
    emitterLayer.emitterZPosition = 0;

    emitterLayer.emitterSize = CGSizeMake(CGRectGetWidth(self.frame) / 8.0, MAX(CGRectGetHeight(self.frame) / 30.0, 1.0));
    emitterLayer.emitterDepth = 0.00;

    emitterLayer.emitterShape = kCAEmitterLayerRectangle;

    emitterLayer.renderMode = kCAEmitterLayerAdditive;

    emitterLayer.seed = 4176518701;

    // Create the emitter Cell
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];

    emitterCell.enabled = YES;

    emitterCell.contents = (id)self.dot.CGImage;
    emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);

    emitterCell.magnificationFilter = kCAFilterLinear;
    emitterCell.minificationFilter = kCAFilterLinear;
    emitterCell.minificationFilterBias = 0.00;

    emitterCell.scale = CGRectGetWidth(self.frame) / 1000.0;
    emitterCell.scaleRange = emitterCell.scale * 0.75;
    emitterCell.scaleSpeed = -0.03;

    emitterCell.color = [[UIColor blackColor] CGColor];
    emitterCell.redRange = .01;
    emitterCell.greenRange = 0.01;
    emitterCell.blueRange = .01;
    emitterCell.alphaRange = 0.47;

    emitterCell.redSpeed = .01;
    emitterCell.greenSpeed = .2;
    emitterCell.blueSpeed = .3;
    emitterCell.alphaSpeed = -0.30;

    emitterCell.lifetime = 3.00;
    emitterCell.lifetimeRange = 0.50;
    emitterCell.birthRate = 1.5;
    emitterCell.velocity = 4.00;
    emitterCell.velocityRange = 1.00;
    emitterCell.xAcceleration = 0.00;
    emitterCell.yAcceleration = -30.00;
    emitterCell.zAcceleration = 0.00;

    emitterCell.spin = 6.109;
    emitterCell.spinRange = 11.397;
    emitterCell.emissionLatitude = 2.915;
    emitterCell.emissionLongitude = 2.775;
    emitterCell.emissionRange = 3.489;

    emitterLayer.emitterCells = @[emitterCell];
}

@end
