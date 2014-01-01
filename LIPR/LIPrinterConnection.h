//
//  LIPrinterConnection.h
//  LIPR
//
//  Created by Tim Schröder on 25.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LIPrinterMessage;

@interface LIPrinterConnection : NSObject <NSURLConnectionDelegate>

-(id)initWithPrinterAccessCode:(NSString*)accessCode;
-(void)printMessage:(LIPrinterMessage*)printerMessage;

@property NSString* printerAccessCode;
@property LIPrinterMessage* printerMessage;
@property (assign) id delegate;
@property NSMutableArray *printerQueue;
@property BOOL isPrinting;

@end
