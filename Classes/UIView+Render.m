//
//
//  Created by Robert Diamond on 04/03/2011.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import "UIView+Render.h"


@implementation UIView(Render)


- (BOOL) isSuperView:(UIView*)view{
	UIView* superv = self.superview;
	while(superv){
		if (superv == view){
			return YES;
		}
		superv = superv.superview;
	}
	return NO;
}

- (BOOL) hasSuperviewOfClass:(Class) class{
	UIView* superv = self.superview;
	while(superv){
		if ([superv isKindOfClass:class]){
			return YES;
		}
		superv = superv.superview;
	}
	return NO;
}

- (UIImage*) offlineRender{
	// render the view to an offline context
	CGColorSpaceRef csp = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef bmc = CGBitmapContextCreate(NULL, self.bounds.size.width, self.bounds.size.height, 
											 8, self.bounds.size.width * 4, csp, kCGImageAlphaPremultipliedLast);
	
	CGContextTranslateCTM(bmc, 0, self.bounds.size.height);
	CGContextScaleCTM(bmc, 1, -1);
	[self.layer renderInContext:bmc];
	
	CGImageRef renderref = CGBitmapContextCreateImage(bmc);
	UIImage *render = [UIImage imageWithCGImage:renderref scale:1.0 orientation:UIImageOrientationUp];
	CGImageRelease(renderref);																							
	CGContextRelease(bmc);
	CGColorSpaceRelease(csp);
	return render;
}

- (UIImageView*) offlineRenderImageView{
	UIImageView* ret = [[[UIImageView alloc] initWithImage:[self offlineRender]] autorelease];
	return ret;
}


    

@end
