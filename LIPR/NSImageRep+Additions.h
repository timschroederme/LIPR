//
//  NSImageRep+Additions.h
//  LIPR
//
//  Created by Tim Schröder on 23.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//  

#import <Cocoa/Cocoa.h>

@interface NSImageRep (Additions)

- (NSBitmapImageRep *) grayRepresentation;
- (NSBitmapImageRep *) binaryRepresentation;

@end
