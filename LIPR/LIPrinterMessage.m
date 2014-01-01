//
//  LIPrinterMessage.m
//  LIPR
//
//  Created by Tim Schröder on 25.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import "LIPrinterMessage.h"
#import "NSString+Additions.h"
#import "NSImage+Additions.h"

@interface LIPrinterMessage ()

@property (readwrite) NSString *html;
@property (readwrite) NSString *ID;

@end

@implementation LIPrinterMessage

#pragma mark -
#pragma mark Initialization

-(id)init{
    return([self initWithHTML:nil]);
}

-(id)initWithText:(NSString*)text
{
    NSString *html = [self htmlWrapperForText:text];
    return [self initWithHTML:html];
}

-(id)initWithImage:(NSImage*)image
{
    NSString *html = [self htmlWrapperForImage:image];
    return [self initWithHTML:html];
}

-(id)initWithHeading:(NSString*)heading andText:(NSString*)text
{
    NSString *html = [self htmlWrapperForHeading:heading andText:text];
    return [self initWithHTML:html];
}

// Designated Initializer
-(id)initWithHTML:(NSString*)html
{
    if (self = [super init]){
        NSString *processedHTML = [self processHTMLTagsInString:html];
        self.html = [self htmlWrapperForHTML:processedHTML];
        if (self.html) self.ID = [self calculateHash];
    }
    return self;
}

#pragma mark -
#pragma mark Calculate Hash Methods

-(NSString*)dateHash
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return (dateString);
}

-(NSString*)htmlHash
{
    if (!self.html) return nil;
    NSString *hash = [NSString stringWithFormat:@"%lx", (unsigned long)[self.html hash]];
    return (hash);
}

-(NSString*)calculateHash
{
    NSString *dateHash = [self dateHash];
    NSString *htmlHash = [self htmlHash];
    if ((!dateHash) || (!htmlHash)) return nil;
    NSString *compositeHash = [NSString stringWithFormat:@"%@%@", dateHash, htmlHash];
    return (compositeHash);
}

#pragma mark -
#pragma mark HTML Composition Helper Methods

-(NSString*)head
{
    return (@"html=");
}

-(NSString*)htmlHeader
{
    return (@"<html><head><meta charset=\"utf-8\"></head><body>");
}

-(NSString*)htmlFooter
{
    return (@"</body></html>");
}


#pragma mark -
#pragma mark HTML Composition Methods

-(NSString*)htmlWrapperForHTML:(NSString*)html
{
    if (!html) return nil;
    return ([NSString stringWithFormat:@"%@%@", [self head], [html urlEncodeString]]);
}

-(NSString*)htmlWrapperForBody:(NSString*)body
{
    if (!body) return nil;
    NSString *html = [NSString stringWithFormat:@"%@%@%@", [self htmlHeader], body, [self htmlFooter]];
    return (html);
}

-(NSString*)htmlWrapperForText:(NSString*)text
{
    if (!text) return nil;
    NSString *body;
    body = [NSString stringWithFormat:@"<p style=\"font-size:20px; font-weight:normal\">%@</p>", text];
    return [self htmlWrapperForBody:body];
}

-(NSString*)htmlWrapperForHeading:(NSString*)heading andText:(NSString*)text
{
    if ((!heading) || (!text)) return nil;
    NSString *body, *htmlHeading, *htmlText;
    htmlHeading = [NSString stringWithFormat:@"<h1 style=\"font-size:40px; font-weight:bold\">%@</h1>", heading];
    htmlText = [NSString stringWithFormat:@"<p style=\"font-size:20px; font-weight:normal\">%@</p>", text];
    body = [NSString stringWithFormat:@"%@%@", htmlHeading, htmlText];
    return [self htmlWrapperForBody:body];
}

-(NSString*)htmlWrapperForImage:(NSImage*)image
{
    if (!image) return nil;
    NSImage *tempImage = [image copy];
    NSString *imageTag, *encodedImage;
    encodedImage = [tempImage encode];
    imageTag = [NSString stringWithFormat:@"<p style=\"text-align:center\"><img src=\"data:image/png;base64,%@\"></p>", encodedImage];
    return (imageTag);
}

#pragma mark -
#pragma mark HTML Manipulation Methods


-(NSString*)processHTMLTagsInString:(NSString*)html
{
    NSString *newHtml = html;
    NSUInteger tagPos = 0;
    NSRange aRange;
    do {
        aRange = [newHtml rangeOfString:@"<img " options:NSCaseInsensitiveSearch range:NSMakeRange(tagPos, [newHtml length]-tagPos)];
        if (aRange.location != NSNotFound) {
            tagPos = aRange.location+1;
            NSString *subString = [newHtml substringFromIndex:aRange.location];
            NSRange bRange = [subString rangeOfString:@">"];
            if (bRange.location != NSNotFound) {
                NSString *imgTag = [newHtml substringWithRange:NSMakeRange(aRange.location, bRange.location+1)];
                NSString *imageTagString = [self replacementIMGTagForTag:imgTag];
                NSString *preString = [newHtml substringToIndex:aRange.location];
                NSString *afterString = [newHtml substringFromIndex:aRange.location+bRange.location+1];
                newHtml = [NSString stringWithFormat:@"%@%@%@", preString, imageTagString, afterString];
            } else
            {
                aRange.location = NSNotFound; // Error
            }
        }
    } while (aRange.location != NSNotFound);
    return (newHtml);
}

-(NSString*)replacementIMGTagForTag:(NSString*)imageTag
{
    NSString *replacementTag;
    NSRange aRange = [imageTag rangeOfString:@"src=\""];
    if (aRange.location != NSNotFound) {
        NSString *srcString = [imageTag substringFromIndex:aRange.location+5];
        if ([[srcString substringToIndex:5] isEqualToString:@"data:"]) return (imageTag); // Return input value if image is already encoded
        NSRange bRange = [srcString rangeOfString:@"\""];
        if (bRange.location != NSNotFound) {
            NSString *link = [imageTag substringWithRange:NSMakeRange(aRange.location+5, bRange.location)];
            // Download and process Image
            // If yes, download them
            NSURL *imageURL = [NSURL URLWithString:link];
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL]; // To be replaced with asynchronous image loading later
            NSString *encodedImageString = [image encode];
            replacementTag = [NSString stringWithFormat:@"src=\"data:image/png;base64,%@\"", encodedImageString];
            NSString *preString = [imageTag substringToIndex:aRange.location];
            NSString *afterString = [imageTag substringFromIndex:aRange.location+bRange.location+1];
            replacementTag = [NSString stringWithFormat:@"%@%@%@", preString, replacementTag, afterString];
        }
    }
    return (replacementTag);
}

@end
