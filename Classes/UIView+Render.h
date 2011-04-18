//
//  Created by Robert Diamond on 04/03/2011.
//  Copyright 2011 Robert M. Diamond. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView(Render)

- (BOOL) hasSuperviewOfClass:(Class) class;

- (BOOL) isSuperView:(UIView*)view;

- (UIImage*) offlineRender;

- (UIImageView*) offlineRenderImageView;

@end
