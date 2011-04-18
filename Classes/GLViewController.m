//
//  GLViewController.h
//  Texture
//
//  Created by jeff on 5/23/09.
//  Copyright Jeff LaMarche 2009. All rights reserved.
//

#import <math.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Render.h"
#import "GLViewController.h"
#import "GLView.h"
#import "OpenGLCommon.h"
#import "ConstantsAndMacros.h"

Vertex2D Vertex2DMake(GLfloat x, GLfloat y) {
    Vertex2D ret;
    ret.x = x; ret.y = y; return ret;
}

static Vertex2D addPoints(Vertex2D a,Vertex2D other) {
	return Vertex2DMake(a.x+other.x, a.y+other.y);
}

static Vertex2D scalarMult(Vertex2D a, double sc) {
	return Vertex2DMake(a.x*sc, a.y*sc);
}

static Vertex2D bezier(Vertex2D a,Vertex2D b,Vertex2D c,Vertex2D d,double t) // Parameter 0 <= t <= 1
{
    double s = 1 - t;
	Vertex2D AB = addPoints(scalarMult(a,s), scalarMult(b, t));
	Vertex2D BC = addPoints(scalarMult(b,s), scalarMult(c, t));
	Vertex2D CD = addPoints(scalarMult(c,s), scalarMult(d, t));
	Vertex2D ABC = addPoints(scalarMult(AB,s), scalarMult(BC, t));
	Vertex2D BCD = addPoints(scalarMult(BC,s), scalarMult(CD, t));
    return addPoints(scalarMult(ABC,s), scalarMult(BCD, t));
}

static GLuint nextPowerOfTwo(CGFloat num) {
	static CGFloat log2 = 0.0;
	if (log2 == 0.0) {
		log2 = log(2.0f);
	}
	CGFloat logval = ceil(log(num)/log2);
	return pow(2,logval);
}

@implementation GLViewController

@synthesize hideButton;
@synthesize hideView;

- (void)viewDidLoad {
	[super viewDidLoad];
	((GLView *)self.view).animationInterval = 1.0 / kRenderingFrequency;
	((GLView *)self.view).controller = self;
}

- (IBAction)clickButton:(id)sender {
	[self setupView:(GLView *)self.view];
	[(GLView *)self.view startAnimation];
}

- (void)drawView:(GLView*)view;
{
    glColor4f(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glLoadIdentity();
    glTranslatef(0.0, 0.0, -3.0);
    
    //glBindTexture(GL_TEXTURE_2D, texture[0]);
    glVertexPointer(3, GL_FLOAT, 0, bezierVertices + pos);
    glNormalPointer(GL_FLOAT, 0, normals);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, SLICES*2 - pos);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	pos += 2;
    if (pos >= SLICES * 2) {
		hideView.hidden = NO;
		glDeleteTextures(1, &texture[0]);
		texture[0] = 0;
        [view stopAnimation];
		glDisable(GL_DEPTH_TEST);
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
		glDisable(GL_LIGHT0);		
		glDisable(GL_LIGHTING);
    }	
}

-(void)setupView:(GLView*)view
{
	const GLfloat zNear = 0.01, zFar = 1000.0, fieldOfView = 45.0; 
	GLfloat size;
	
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0); 
	CGRect rect = view.bounds; 
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / 
			   (rect.size.width / rect.size.height), zNear, zFar); 
	glViewport(0, 0, rect.size.width, rect.size.height);  
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    // Turn necessary features on
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_SRC_COLOR);
    
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);  
    
    // Bind the number of textures we need, in this case one.
    glGenTextures(1, &texture[0]);
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    GLenum error = glGetError();
    if (error) {
		NSLog(@"error %d", error);
	}
	
	// render the view into an image
    UIImage *img = [self.hideView offlineRender];
	NSLog(@"img %@", img);
 	GLuint width = nextPowerOfTwo(hideView.bounds.size.width);
    GLuint height = nextPowerOfTwo(hideView.bounds.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );

    // Flip the Y-axis
    CGContextTranslateCTM (context, 0, height);
    CGContextScaleCTM (context, 1.0, -1.0);
    
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), img.CGImage );
   
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    CGContextRelease(context);
    
    free(imageData);
	hideView.hidden = YES;

    glEnable(GL_LIGHTING);
    
    // Turn the first light on
    glEnable(GL_LIGHT0);
    
    // Define the ambient component of the first light
    static const Color3D light0Ambient[] = {{0.9, 0.9, 0.9, 1.0}};
	glLightfv(GL_LIGHT0, GL_AMBIENT, (const GLfloat *)light0Ambient);
    
    // Define the diffuse component of the first light
    static const Color3D light0Diffuse[] = {{1.0, 1.0, 1.0, 1.0}};
	glLightfv(GL_LIGHT0, GL_DIFFUSE, (const GLfloat *)light0Diffuse);
    
    // Define the position of the first light
    //const GLfloat light0Position[] = {10.0, 10.0, 10.0}; 
    static const Vertex3D light0Position[] = {{10.0, 10.0, 10.0}};
	glLightfv(GL_LIGHT0, GL_POSITION, (const GLfloat *)light0Position); 
    
    Vertex2D a1,b1,c1,d1;
    Vertex2D a2,b2,c2,d2;    
    Vector3D *vertexPointer = (Vector3D *)bezierVertices;
    
	CGRect vb = self.view.bounds;
	CGRect bb = hideButton.frame;
	
    a1.x = 1.0f;
    a1.y = 1.0f;
	
    c1.x = ((bb.origin.x + bb.size.width) / vb.size.width) * 2.0f - 1.0f;
    c1.y = -1.0f;
	
    b1.x = a1.x * .9 + c1.x * .1;
    b1.y = a1.y * .5 + c1.y * .5;
    d1.x = c1.x * .9 + a1.x * .1;
    d1.y = c1.y * .5 + a1.y * .5;
    
    a2.x = -1.0f;
    a2.y = 1.0f;
	
    c2.x = (bb.origin.x / vb.size.width) * 2.0f - 1.0f;
    c2.y = -1.0f;
	
    b2.x = a2.x * .9 + c2.x * .1;
    b2.y = a2.y * .5 + c2.y * .5;
    d2.x = c2.x * .9 + a2.x * .1;
    d2.y = c2.y * .5 + a2.y * .5;
    
    //NSLog(@"a1.x %f a1.y %f b1.x %f b1.y %f c1.x %f c1.y %f d1.x %f d1.y %f", a1.x,a1.y,b1.x,b1.y,c1.x,c1.y,d1.x,d1.y);
    //NSLog(@"a2.x %f a2.y %f b2.x %f b2.y %f c2.x %f c2.y %f d2.x %f d2.y %f", a2.x,a2.y,b2.x,b2.y,c2.x,c2.y,d2.x,d2.y);
    static const Vector3D cnormals[] = {
        {0.0, 0.0, 1.0},
    };
    int ct = 0;
    for (GLfloat t = 0.0f; t <= 1.0f; t += (1.0f/SLICES)) {
		// No, not a typo, I got the control points' orders different
        Vertex2D p1 = bezier(a1, b1, d1, c1, t);
        Vertex2D p2 = bezier(a2, b2, d2, c2, t);
        vertexPointer->x = p1.x;
        vertexPointer->y = p1.y;
        vertexPointer->z = -0.0;
        ++vertexPointer;
        vertexPointer->x = p2.x;
        vertexPointer->y = p2.y;
        vertexPointer->z = -0.0;
        ++vertexPointer;
        
        memcpy(&normals[ct], cnormals, sizeof(Vector3D));
        texCoords[ct].x = 1.0;
        texCoords[ct].y = p1.y/2.0+.5;
        ++ct;
        memcpy(&normals[ct], cnormals, sizeof(Vector3D));
        texCoords[ct].x = 0.0;
        texCoords[ct].y = p2.y/2.0+.5;
        ++ct;
        
        //NSLog(@"ct %d p1.x %f p1.y %f p2.x %f p2.y %f t %f", ct, p1.x, p1.y, p2.x, p2.y, t);
    }
    pos = 0;
    //NSLog(@"A place to stop");
}
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc 
{
    [super dealloc];
}

@end
