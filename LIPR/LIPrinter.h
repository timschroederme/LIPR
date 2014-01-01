// 
//  LIPrinter.h  
//  LIPrinter
//
//  Created by Tim Schröder on 23.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import "LIPrinterProtocol.h"

@interface LIPrinter : NSObject

-(id)initWithPrinterAccessCode:(NSString*)accessCode;
-(NSString*) printTextMessage:(NSString*)text;
-(NSString*) printImageMessage:(NSImage*)image;
-(NSString*) printMessageWithHeading:(NSString*)heading andText:(NSString*)text;
-(NSString*) printHTML:(NSString*)html;

@property NSString *printerAccessCode;
@property (assign, nonatomic) id delegate;

@end
