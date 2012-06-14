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


@implementation AppController : CPObject
{	id clockView1;
	id clockView2;
	id clockView3;
	id clockView4;
	id sheet;
	id	window;
	id tobiimage;
	id digitalclocklabel;
	id feedbacklabel;
	id	levelindicator;
	id	schiffefenster;
	id pop1;
	id pop2;
	unsigned numberCorrect @accessors;
	unsigned numberWrong @accessors;
}

- (void) applicationDidFinishLaunching:(CPNotification)aNotification
{	[CPBundle loadRessourceNamed: "gui.gsmarkup" owner:self];
	[self setNumberCorrect: [CPNumber numberWithInt: 0] ];
	[self setNumberWrong: [CPNumber numberWithInt: 0]];
	[digitalclocklabel setFont:[CPFont systemFontOfSize:32]];
}
-(void) imageDidLoad: someImg
{	[tobiimage setObjectValue: someImg];
}
- (void)closeSheet:(id)sender
{
// neue Aufgabe
	var hour=Math.round(Math.random()*12+12);
	var min=Math.round(Math.random()*60);
	var sec=Math.round(Math.random()*60);
	[clockView1 setObjectValue: hour+":"+min+":00"];
//	[clockView1 setObjectValue: "11:55:00"];
    [CPApp endSheet:sheet returnCode:[sender tag]];
}
-(void) didEndSheet: someSheet returnCode: someCode contextInfo: someInfo
{
}
-(CPImage) tobiimageForShorthand:(CPString) shorthand
{	var img= [[CPImage alloc] initWithContentsOfFile: [CPString stringWithFormat:@"%@/%@.png", [[CPBundle mainBundle] resourcePath], shorthand ]];
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
		img=[self tobiimageForShorthand:"good"];
	} else if(difference<10)
	{	[self tobiimageForShorthand:"medium"];
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

