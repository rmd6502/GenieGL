//
// Textureconstants.h
//  Texture
//
//  Created by jeff on 5/23/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//

// How many times a second to refresh the screen
#define kRenderingFrequency 80.0
#define SLICES 45
// in seconds
#define funnelTime .25

// For setting up perspective, define near, far, and angle of view
#define kZNear			0.01
#define kZFar			1000.0
#define kFieldOfView	40.0

// Macros
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)