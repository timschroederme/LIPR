//
//  NSImageRep+Additions.m
//  LIPR
//
//  Created by Tim Schröder on 23.12.13. 
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//
//  Uses example code by Heinrich Giesen available at http://stackoverflow.com/questions/13391379/create-monochrome-cgimageref-1-bit-per-pixel-bitmap/13406532#13406532


#import "NSImageRep+Additions.h"

@implementation NSImageRep (Additions)


- (NSBitmapImageRep *) grayRepresentation
{
    NSBitmapImageRep *newRep =
    [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                            pixelsWide:[self pixelsWide]
                                            pixelsHigh:[self pixelsHigh]
                                         bitsPerSample:8
                                       samplesPerPixel:1
                                              hasAlpha:NO
                                              isPlanar:NO
                                        colorSpaceName:NSCalibratedWhiteColorSpace
                                           bytesPerRow:0
                                          bitsPerPixel:0 ];
    
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:newRep];
    if( context==nil ){
        NSLog( @"***  %s context is nil", __FUNCTION__ );
        return nil;
    }
    [NSGraphicsContext setCurrentContext:context];
    [self drawInRect:NSMakeRect( 0, 0, [newRep pixelsWide], [newRep pixelsHigh] )];
    [NSGraphicsContext restoreGraphicsState];
    return (newRep);
}

#define clamp(z) ( (z>255)?255 : ((z<0)?0:z) )
- (NSBitmapImageRep *) binaryRepresentation
{
    NSBitmapImageRep *grayRep = [self grayRepresentation];
    if( grayRep==nil ) return nil;
    
    NSInteger numberOfRows = [grayRep pixelsHigh];
    NSInteger numberOfCols = [grayRep pixelsWide];
    
    NSBitmapImageRep *newRep =
    [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                            pixelsWide:numberOfCols
                                            pixelsHigh:numberOfRows
                                         bitsPerSample:1
                                       samplesPerPixel:1
                                              hasAlpha:NO
                                              isPlanar:NO
                                        colorSpaceName:NSCalibratedWhiteColorSpace
                                          bitmapFormat:0
                                           bytesPerRow:0
                                          bitsPerPixel:0 ];
    
    unsigned char *bitmapDataSource = [grayRep bitmapData];
    unsigned char *bitmapDataDest = [newRep bitmapData];
    
    NSInteger grayBPR = [grayRep bytesPerRow];
    NSInteger binBPR = [newRep bytesPerRow];
    NSInteger pWide = [newRep pixelsWide];
    
    // Original Floyd and Steinberg (see http://en.wikipedia.org/wiki/Error_diffusion) and http://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
    
    // Minimized Average Error (see http://en.wikipedia.org/wiki/Error_diffusion)
    
    int corrfactor=48;
    NSInteger error_sum = 0;
    NSInteger error_cnt = 0;
    for( NSInteger row=0; row<numberOfRows-1; row++ ){
        unsigned char *currentRowData = bitmapDataSource + row*grayBPR;
        unsigned char *nextRowData = currentRowData + grayBPR;
        unsigned char *overNextRowData = currentRowData + (grayBPR*2);
        for( NSInteger col = 1; (col<numberOfCols); col++ ){
            NSInteger origValue = currentRowData[col];
            NSInteger newValue = (origValue>127) ? 255 : 0;
            NSInteger error = -(newValue - origValue);
            if (error > 0) {
                error_cnt++;
                error_sum+=error;
                NSInteger average = (error_sum/error_cnt);
                if (error > 0) error+=average*1.5;
            }
            currentRowData[col] = newValue;
            
            currentRowData[col+1] = clamp(currentRowData[col+1] + (7*error/corrfactor));
            if ((col+2)<numberOfCols) {
                currentRowData[col+2] = clamp(currentRowData[col+2] + (5*error/corrfactor));
            }
            
            // Next Row
            if ((col-2)>=0) {
                nextRowData[col-2] = clamp(nextRowData[col-2] + (3*error/corrfactor) );
            }
            nextRowData[col-1] = clamp( nextRowData[col-1] + (5*error/corrfactor) );
            nextRowData[col] = clamp( nextRowData[col] + (7*error/corrfactor) );
            nextRowData[col+1] = clamp( nextRowData[col+1] + (5*error/corrfactor) );
            if ((col+2)<numberOfCols) {
                nextRowData[col+2] = clamp( nextRowData[col+2] + (3*error/corrfactor) );
            }
            
            // Overnext Row
            if (row<(numberOfRows-2)) {
                if ((col-2)>=0) {
                    overNextRowData[col-2] = clamp(overNextRowData[col-2] + (1*error/corrfactor) );
                }
                overNextRowData[col-1] = clamp( overNextRowData[col-1] + (3*error/corrfactor) );
                overNextRowData[col] = clamp( overNextRowData[col] + (5*error/corrfactor) );
                overNextRowData[col+1] = clamp( overNextRowData[col+1] + (3*error/corrfactor) );
                if ((col+2)<numberOfCols) {
                    overNextRowData[col+2] = clamp( overNextRowData[col+2] + (1*error/corrfactor) );
                }
            }
        }
    }
    
    // iterate over all pixels
    for( NSInteger row=0; row<numberOfRows; row++ ){
        unsigned char *rowDataSource = bitmapDataSource + row*grayBPR;
        unsigned char *rowDataDest = bitmapDataDest + row*binBPR;
        
        NSInteger destCol = 0;
        unsigned char bw = 0;
        for( NSInteger col = 0; col<pWide; ){
            unsigned char gray = rowDataSource[col];
            if( gray>127 ) {bw |= (1<<(7-col%8)); };
            col++;
            if( (col%8 == 0) || (col==pWide) ){
                rowDataDest[destCol] = bw;
                bw = 0;
                destCol++;
            }
        }
    }
    
    return (newRep);
}



@end
