//
//  NSColor+CGColor.m
//  Aurality2
//
//  Created by Joachim Bengtsson on 2009-11-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "NSColor+CGColor.h"


@implementation NSColor(CGColorConversion)
- (CGColorRef)CGColor {
    CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
    NSInteger componentCount = [self numberOfComponents];
    CGFloat *components = (CGFloat *)calloc(componentCount, sizeof(CGFloat));
    [self getComponents:components];
    CGColorRef color = CGColorCreate(colorSpace, components);
    free((void*)components);
    return color;
}
@end
