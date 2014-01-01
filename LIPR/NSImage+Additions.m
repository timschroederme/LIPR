//
//  NSImage+Additions.m
//  LIPR
//
//  Created by Tim Schröder on 23.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import "NSImage+Additions.h"
#import "NSImageRep+Additions.h"
#import "NSData+Additions.h"

@implementation NSImage (Additions)

NSInteger const maxImageWidth = 384.0; // max width of image Little Printer can print

#pragma mark -
#pragma Private Image Resizing Methods

// Returns width of the receiver, measured in pixels
-(NSInteger)imageWidth
{
    NSImageRep *rep = [[self representations] objectAtIndex:0]; // Not using [image size] here, not reliable
    NSInteger imageWidth = [rep pixelsWide];
    return (imageWidth);
}

#pragma mark -
#pragma Public Image Resizing Methods

// Returns whether the receiver is too wide for Little Printer
// Measured against the maxImageWidth constant defined above
-(BOOL)imageTooWide
{
    BOOL result;
    if ([self imageWidth] > maxImageWidth) {
        result = YES;
    } else {
        result = NO;
    }
    return (result);
}

// Returns a resized copy of the receiver
// Which is resized to a maximum width as defined via the maxImageWidth constant
-(NSImage *)resizeToMaxSize
{
    if (![self imageTooWide]) return (nil);
    NSImage *resizedImage;
    NSSize currentSize = [self size];
    NSSize newSize;
    newSize.width = maxImageWidth;
    newSize.height = currentSize.height * (maxImageWidth/currentSize.width);
    NSImage *sourceImage = self;
    [sourceImage setScalesWhenResized:YES];

    // Report an error if the source isn't a valid image
    if (![sourceImage isValid])
    {
        NSLog(@"Invalid Image");
    } else
    {
        resizedImage = [[NSImage alloc] initWithSize: newSize];
        [resizedImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
        [resizedImage unlockFocus];
    }
    return (resizedImage);
}


#pragma mark -
#pragma mark Public Conversion Method

// Converts the receiver for printing on Little Printer
// And returns an encoded string data structure
// Does the following conversion steps
// (1) Image is resized, if necessary
// (2) Image is converted to gray-scale
// (3) Image is rasterized through minimized average error dithering
// (4) Image is encoded in base64 format
-(NSString*)encode
{
    NSImage *tempImage = self;
    if ([self imageTooWide]) tempImage = [self resizeToMaxSize];
    // Create grayscale dithered image version
    NSData *imageData;
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[tempImage TIFFRepresentation]];
    imageRep = [[imageRep grayRepresentation] binaryRepresentation];
    imageData = [imageRep representationUsingType: NSPNGFileType properties: nil];
    
    // Create Base 64 String
    NSString *base64ImageString;
    if (imageData) base64ImageString = [imageData base64EncodedString];
    return (base64ImageString);
}

@end
