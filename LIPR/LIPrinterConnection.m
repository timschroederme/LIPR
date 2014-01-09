//
//  LIPrinterConnection.m
//  LIPR
//
//  Created by Tim Schröder on 25.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import "LIPrinterConnection.h"
#import "LIPrinterProtocol.h"
#import "LIPrinterMessage.h"

@implementation LIPrinterConnection

NSString *const BergCloudURL = @"http://remote.bergcloud.com/playground/direct_print/"; // As found on http://remote.bergcloud.com/developers/littleprinter/direct_print_codes
NSMutableData *webData;


#pragma mark -
#pragma mark Initialization

-(id)init{
    return([self initWithPrinterAccessCode:nil]);
}

-(id)initWithPrinterAccessCode:(NSString*)accessCode
{
    if (self = [super init]){
        self.printerAccessCode = accessCode;
        self.printerQueue = [NSMutableArray arrayWithCapacity:0];
        self.isPrinting = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Action Methods

-(void)printMessage:(LIPrinterMessage*)printerMessage
{
    if (self.isPrinting) { // already printing?
        [self addMessageToPrinterQueue:printerMessage]; // place message in queue
    } else {
        [self sendMessageToPrinter:printerMessage]; // print message
    }
}

#pragma mark -
#pragma mark Internal Helper Methods

-(NSURL*)printerURL
{
    if (!self.printerAccessCode) return nil;
    NSString *printerAddress = [NSString stringWithFormat:@"%@%@", BergCloudURL, self.printerAccessCode];
    return ([NSURL URLWithString:printerAddress]);
}

-(NSURLRequest*)prepareURLRequest
{
    NSString *content = [self.printerMessage html];
    if (!content) return nil;
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSURL *printerURL = [self printerURL];
    if (!printerURL) return nil;
    [request setURL:printerURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[contentData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:contentData];
    return (request);
}

-(void)sendMessageToPrinter:(LIPrinterMessage*)printerMessage
{
    self.isPrinting = YES;
    self.printerMessage = printerMessage;
    NSURLRequest *request = [self prepareURLRequest];
    if (!request) {
        [self reportConnectionFailedToDelegateWithErrorCode:nil];
        self.isPrinting = NO;
        [self processPrinterQueue];
    } else {
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (theConnection) {
            webData = [NSMutableData data];
            [self reportConnectionInitiatedToDelegate];
        } else {
            [self reportConnectionFailedToDelegateWithErrorCode:nil];
            self.isPrinting = NO;
            [self processPrinterQueue];
        }
    }
}

#pragma mark -
#pragma mark PrinterQueue Methods

-(void)addMessageToPrinterQueue:(LIPrinterMessage*)printerMessage
{
    [self.printerQueue addObject:printerMessage];
    [self reportMessagePlacedInQueueForMessage:printerMessage];
}

-(void)processPrinterQueue
{
    if ([self.printerQueue count]==0) return; // Do nothing if there's nothing in the queue
    LIPrinterMessage *message = [self.printerQueue objectAtIndex:0];
    [self.printerQueue removeObjectAtIndex:0];
    [self sendMessageToPrinter:message];
}

#pragma mark -
#pragma mark LIPrinterProtocol Delegate Communication Methods

-(void)reportMessagePlacedInQueueForMessage:(LIPrinterMessage*)printerMessage
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(LIPrinterProtocol)] && [self.delegate respondsToSelector:@selector(messagePlacedInQueue:)]) {
        [self.delegate messagePlacedInQueue:[printerMessage ID]];
    }
}

-(void)reportConnectionInitiatedToDelegate
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(LIPrinterProtocol)] && [self.delegate respondsToSelector:@selector(printJobInitiated:)]) {
        [self.delegate printJobInitiated:[self.printerMessage ID]];
    }
}

-(void)reportConnectionSuccessFulToDelegate
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(LIPrinterProtocol)] && [self.delegate respondsToSelector:@selector(printJobsucceeded:)]) {
        [self.delegate printJobsucceeded:[self.printerMessage ID]];
    }
}

-(void)reportConnectionFailedToDelegateWithErrorCode:(NSString*)errorCode
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(LIPrinterProtocol)] && [self.delegate respondsToSelector:@selector(connectionFailedForJob:withErrorCode:)]) {
        [self.delegate connectionFailedForJob:[self.printerMessage ID] withErrorCode:errorCode];
    }
}

#pragma mark -
#pragma mark Web Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *ne = (NSHTTPURLResponse *)response;
    if([ne statusCode] != 200) {
        NSString *errorCode = [NSString stringWithFormat:@"%li", [ne statusCode]];
        [self reportConnectionFailedToDelegateWithErrorCode:errorCode];
        [connection cancel];
        self.isPrinting = NO;
        [self processPrinterQueue];
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *errorCode = [NSString stringWithFormat:@"%li", [error code]];
    [self reportConnectionFailedToDelegateWithErrorCode:errorCode];
    [connection cancel];
    self.isPrinting = NO;
    [self processPrinterQueue];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *html = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
    if ([html isEqualToString:@"OK"]) {
        [self reportConnectionSuccessFulToDelegate];
    } else {
        [self reportConnectionFailedToDelegateWithErrorCode:html];
    }
    self.isPrinting = NO;
    [self processPrinterQueue];
}


@end
