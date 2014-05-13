/*
 * AppController.j
 * NewApplication
 *
 * Created by You on November 16, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <Renaissance/Renaissance.j>
@import "AnalogClock.j"

function pad(n) {
    n=Math.floor(n)
    return (n < 10) ? ("0" + n) : n;
}
@implementation AppController : CPObject
{	id clockView1;
	id clockView2;  // zahlenuhr
	id clockView3;
	id clockView4;
	id sheet;
	id	window;
	id tobiimage;
  id digitalclocklabel;
  id digitalclocklabelCurrent;
	id feedbacklabel;
	id	levelindicator;
	id	schiffefenster;
	id pop1;
	id pop2;
	unsigned numberCorrect @accessors;
	unsigned numberWrong @accessors;
  unsigned hours @accessors;
  unsigned minutes @accessors;
}

- (void) applicationDidFinishLaunching:(CPNotification)aNotification
{	[CPBundle loadRessourceNamed: "gui.gsmarkup" owner:self];
	[self setNumberCorrect: [CPNumber numberWithInt: 0] ];
	[self setNumberWrong: [CPNumber numberWithInt: 0]];
  [digitalclocklabel setFont:[CPFont systemFontOfSize:32]];
  [digitalclocklabelCurrent setFont:[CPFont systemFontOfSize:32]];
  [digitalclocklabel setStringValue:"11:00:00"];
    [window setInitialFirstResponder:NO];
    [window makeKeyAndOrderFront:self];

  minutes="00";
  hours="00"
}
-(void) imageDidLoad: someImg
{	[tobiimage setObjectValue: someImg];
}
- (void)closeSheet:(id)sender
{
// neue Aufgabe
	var hour=Math.round(Math.random()*12)+11;
	var min=pad(Math.round(Math.random()*60));
	var sec=pad(Math.round(Math.random()*60));
    [self setHours:"00"]
    [self setMinutes:"00"]
    [clockView1 setObjectValue: hour+":"+min+":00"];
    [clockView1 setObjectValue: hour+":"+min+":00"];
//	[clockView1 setObjectValue: "11:55:00"];
    [sheet orderOut:self];
    [CPApp endSheet:sheet returnCode:[sender tag]];
}
-(void) didEndSheet: someSheet returnCode: someCode contextInfo: someInfo
{
}
-(CPImage) tobiimageForShorthand:(CPString) shorthand
{	var img= [[CPImage alloc] initWithContentsOfFile: [CPString stringWithFormat:@"%@/%@.gif", [[CPBundle mainBundle] resourcePath], shorthand ]];
	[img setDelegate: self];
	return img;
}
-(void) antwortPruefen1: sender
{	var arr=[[clockView1 objectValue] componentsSeparatedByString:":"];
	if(!arr) return;
	arr[0]=arr[0]%12;
	var inputHour=  [[pop2 selectedItem] tag];
	var inputMinute=[[pop1 selectedItem] tag];
	if(inputMinute>=25) inputHour--;
	inputHour=inputHour%12
	var inputValue=[CPString stringWithFormat:"%02d:%02d:00",inputHour,inputMinute];
	var givenValue=[CPString stringWithFormat:"%02d:%02d:00",arr[0],arr[1]];
// alert([[pop2 selectedItem] tag]+"| "+inputHour+" "+inputValue+" "+givenValue);
	var enteredDate=[[CPDate alloc] initWithString: "2009-11-17 "+inputValue+" +0000"];
	var givenDate=[[CPDate alloc] initWithString: "2009-11-17 "+ givenValue+" +0000"];
	var difference=Math.abs([enteredDate timeIntervalSinceDate:givenDate])/(60);
	var inputValueTextual=[[pop1 selectedItem] title]+" "+[[pop2 selectedItem] title];
	[feedbacklabel setStringValue: inputValueTextual];
	[clockView3 setObjectValue: inputValue];
	[clockView4 setObjectValue: [clockView1 objectValue]];

	if(difference<5)
	{	[self setNumberCorrect: parseInt([self numberCorrect])+1];
		img=[self  tobiimageForShorthand:"good"];
	} else
	{	[self setNumberWrong: parseInt([self numberWrong])+1];
		[self tobiimageForShorthand:"bad"];
	}
	[levelindicator setObjectValue: [[self numberWrong] intValue]+[[self numberCorrect] intValue]];
    [CPApp beginSheet:sheet modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void) schiffeVersenken:sender
{
    [CPApp beginSheet: schiffefenster modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}


-(void) setHours:myHours
{  hours=pad(myHours);
  var currentTime=hours+":"+minutes+":00";
  [clockView2 setObjectValue:currentTime];
  [digitalclocklabelCurrent setObjectValue:currentTime]
}
-(void) setMinutes:myMinutes
{  minutes=pad(myMinutes);
  var currentTime=hours+":"+minutes+":00";
  [clockView2 setObjectValue:currentTime];
  [digitalclocklabelCurrent setObjectValue:currentTime]
}
-(void) antwortPruefen2: sender
{	var arr=[[clockView2 objectValue] componentsSeparatedByString:":"];
    var arr2=[[digitalclocklabel objectValue] componentsSeparatedByString:":"];
    if(!arr || !arr2) return;
    arr2[0]=arr2[0]%12;
    arr[0]=arr[0]%12;

    var isWrong=(ABS((arr[0]*60+arr[1])-(arr2[0]*60+arr2[1]))>5); // tolerance is 5 minutes
    if(isWrong)
    {  [self setNumberWrong: parseInt([self numberWrong])+1];
        [self  tobiimageForShorthand:"bad"];
    }
    else
    {  [self setNumberCorrect: parseInt([self numberCorrect])+1];
        [self  tobiimageForShorthand:"good"];
    }
    [levelindicator setObjectValue: 50 - [[self numberWrong] intValue]+[[self numberCorrect] intValue]];
    [clockView4 setObjectValue: [digitalclocklabel objectValue]];
    [clockView3 setObjectValue: [clockView2 objectValue]];
    [CPApp beginSheet:sheet modalForWindow:window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}
@end

@implementation ClockView(RenaissanceAdditions)
- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{	return GSAutoLayoutExpand;
}
- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{	return GSAutoLayoutExpand;
}

@end


@implementation GSMarkupTagClockView:GSMarkupTagControl
+ (CPString) tagName
{	return @"clockView";
}

+ (Class) platformObjectClass
{	return [ClockView class];
}

- (id) initPlatformObject: (id)platformObject
{  [_attributes setObject: @"128" forKey: @"width"];
  [_attributes setObject: @"128" forKey: @"height"];
	platformObject = [super initPlatformObject: platformObject];
  return platformObject;
}
@end
