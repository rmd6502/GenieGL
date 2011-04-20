//
//  GLViewController.h
//  Texture
//
//  Created by jeff on 5/23/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "OpenGLCommon.h"
#import "ConstantsAndMacros.h"

// Set this value to 1 to use PVRTC compressed texture, 0 to use a PNG
//#define USE_PVRTC_TEXTURE   1
typedef struct {GLfloat x; GLfloat y;} Vertex2D;

@class GLView;
@interface GLViewController : UIViewController {
    GLuint		texture[1];
    Vector3D bezierVertices[2 * (SLICES + 1)];
    Vector3D normals[2*(SLICES+1)];
    Vertex2D texCoords[2*(SLICES+1)];
    GLint pos;
	GLfloat final1x, final2x;
	GLfloat c1x, c2x;
	GLfloat d1x, d2x;
}

@property (nonatomic,assign) IBOutlet UIButton *hideButton;
@property (nonatomic,assign) IBOutlet UIView *hideView;
@property (nonatomic,assign) IBOutlet UITextField *textField;

- (void)drawView:(GLView*)view;
- (void)setupView:(GLView*)view;
- (void)calcVertices;

- (IBAction)clickButton:(id)sender;

@end
