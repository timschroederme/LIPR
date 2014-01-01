//
//  LIPrinter.m
//  LIPrinter
//
//  Created by Tim Schröder on 23.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import "LIPrinter.h"
#import "LIPrinterMessage.h"
#import "LIPrinterConnection.h"

@interface LIPrinter ()

@property LIPrinterConnection *printerConnection;

@end

@implementation LIPrinter

#pragma mark -
#pragma mark Initialization

-(id)init{
    return([self initWithPrinterAccessCode:nil]);
}

-(id)initWithPrinterAccessCode:(NSString*)accessCode
{
    if (self = [super init]){
        self.printerAccessCode = accessCode;
        self.printerConnection = [[LIPrinterConnection alloc] initWithPrinterAccessCode:accessCode];
    }
    return self;
}

#pragma mark -
#pragma Properties Customized Setter Methods

-(void)setDelegate:(id)delegate
{
    _delegate = delegate;
    [self.printerConnection setDelegate:delegate];
}

#pragma mark -
#pragma mark Action Methods

-(NSString*) printTextMessage:(NSString*)text
{
    if (!text) return nil;
    LIPrinterMessage *message = [[LIPrinterMessage alloc] initWithText:text];
    [self.printerConnection printMessage:message];
    return (message.ID);
}

-(NSString*) printImageMessage:(NSImage*)image
{
    if (!image) return nil;
    LIPrinterMessage *message = [[LIPrinterMessage alloc] initWithImage:image];
    [self.printerConnection printMessage:message];
    return (message.ID);
}

-(NSString*) printMessageWithHeading:(NSString*)heading andText:(NSString*)text
{
    if ((!heading) || (!text)) return nil;
    LIPrinterMessage *message = [[LIPrinterMessage alloc] initWithHeading:heading andText:text];
    [self.printerConnection printMessage:message];
    return (message.ID);
}

-(NSString*) printHTML:(NSString*)html
{
    if (!html) return nil;
    LIPrinterMessage *message = [[LIPrinterMessage alloc] initWithHTML:html];
    [self.printerConnection printMessage:message];
    return (message.ID);
}

@end
