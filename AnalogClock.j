/*
 * Analog clock view for cappuccino
 * KVC(objectValue): CPString of format HH:MM:SS
 *
 * Created by daboe01 in mid 2012.
 * clock images courtesy of http://en.wikipedia.org/wiki/Everaldo_Coelho.
 */

@import <AppKit/AppKit.j>


@implementation _ClockLayer : CALayer
{	float		_rotationRadians;
	float		_scale;
	CPImage		_image;
	ClockView	_clockView;
}

- (void)imageDidLoad: someImg
{	var mySize=[someImg size];
	if (someImg && mySize)
		[self setBounds:CGRectMake(0,0, mySize.width, mySize.height)];

	[self setNeedsDisplay];
}

- (id)initWithClockView:(ClockView)aClockView andImageNamed: (CPString) someName
{	self = [super init];

	if (self)
	{	_clockView = aClockView;
		_image=[[ClockView class] _loadImageNamed: someName forDelegate: self];
		_rotationRadians = 0.0;
		_scale = 1.0;
		var subview=[[CPView alloc] initWithFrame:[aClockView bounds]];
		[aClockView addSubview: subview];
		[subview setLayer: self];
	}
	return self;
}

- (ClockView)clockView
{	return _clockView;
}

- (void)setBounds:(CGRect)aRect
{	[super setBounds: aRect];
	var imageViewBounds=[_clockView bounds];
	[self setPosition: CGPointMake(CGRectGetMidX(imageViewBounds), CGRectGetMidY(imageViewBounds))]
}


- (int)rotationRadians
{	return _rotationRadians;
}

- (void)setRotationRadians:(float)radians
{	if (_rotationRadians == radians) return;

	_rotationRadians = radians;

	[self setAffineTransform:CGAffineTransformScale(
		CGAffineTransformMakeRotation(_rotationRadians), _scale, _scale)];
}

- (void)setScale:(float)aScale
{	if (_scale == aScale) return;

	_scale = aScale;

	[self setAffineTransform: CGAffineTransformScale(CGAffineTransformMakeRotation(_rotationRadians), _scale, _scale)];
}

- (void)drawInContext:(CGContext)aContext
{	if(!_image) return;
	var bounds = [self bounds];
	CGContextDrawImage(aContext, bounds, _image);
}



@end

@implementation ClockView : CPControl
{	CPImage		_backgroundImageView;
	_ClockLayer _hourHand;
	_ClockLayer _minuteHand;
	_ClockLayer _secondHand;
}

-(void) sizeToFit {}

+(CPString) themeName
{	return "crystaldigits";
}


// make use of [[CPBundle bundleForClass:[CPBrowser class]] pathForResource:"browser-leaf-highlighted.png"

+(CPImage) _loadImageNamed:(CPString) someName forDelegate: someDelegate
{	var url=[CPURL URLWithString:[CPString stringWithFormat:@"%@/%@", [[CPBundle mainBundle] resourcePath], [self themeName]+"-"+someName+".png" ]]
	var image=[[CPImage alloc] initWithContentsOfFile: url];
	[image setDelegate: someDelegate];
	return image;
}
- (void)imageDidLoad: someImg
{	[self setBackgroundImage: someImg];
	_hourHand=[[_ClockLayer alloc] initWithClockView: self andImageNamed: "hour"];
	_minuteHand=[[_ClockLayer alloc] initWithClockView: self andImageNamed: "min"];
	_secondHand= [[_ClockLayer alloc] initWithClockView: self andImageNamed: "sec"];
}

-(void) setBackgroundImage:(CPImage) someImage
{	var mySize=[someImage size];
	if(_backgroundImageView)	[_backgroundImageView removeFromSuperview];
	var myFrame=[self frame];
	myFrame.size.width=  mySize.width;
	myFrame.size.height= mySize.height;
	[self setFrame: myFrame];
	 _backgroundImageView=[[CPImageView alloc] initWithFrame: CGRectMake(0,0, mySize.width, mySize.height)];
	[_backgroundImageView setImage: someImage ];
	[self addSubview: _backgroundImageView];
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {	[[ClockView class] _loadImageNamed: "face" forDelegate: self];	// calls setBackgroundImage
		[self setObjectValue:"12:00:00"];
	}

	return self;
}
-(void) setObjectValue: (CPString) someVal
{	[super setObjectValue: someVal];
	var arr=[someVal componentsSeparatedByString:":"];
	var hour=arr[0]%12;
	[_hourHand setRotationRadians: (hour/12+arr[1]/60/12)*3.14*2];
	[_minuteHand setRotationRadians: arr[1]/60*3.14*2];
	[_secondHand setRotationRadians: arr[2]/60*3.14*2];
}

@end
