//
//  LIPrinterMessage.h
//  LIPR
//
//  Created by Tim Schröder on 25.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LIPrinterMessage : NSObject

-(id)initWithHTML:(NSString*)html;
-(id)initWithText:(NSString*)text;
-(id)initWithImage:(NSImage*)image;
-(id)initWithHeading:(NSString*)heading andText:(NSString*)text;

@property (readonly) NSString *html;
@property (readonly) NSString *ID;

@end
