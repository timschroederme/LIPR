//
//  NSString+Additions.m
//  LIPR
//
//  Created by Tim Schröder on 24.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//
// // Based on code by heather92115 available at http://stackoverflow.com/questions/8693923/what-are-the-characters-that-stringbyaddingpercentescapesusingencoding-escapes/9781712#9781712


#import "NSString+Additions.h"

@implementation NSString (Additions)

// Provides for Percent-Encoding of Receiver and returns result as a new string
// See also http://en.wikipedia.org/wiki/Percent-encoding
-(NSString*)urlEncodeString
{
    CFStringRef escapeChars = (CFStringRef)@"%;/?¿:@&=$+,[]#!'()*<>¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ \"\n";
    NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge_retained CFStringRef) self, NULL, escapeChars, kCFStringEncodingUTF8);
    return (result);
}

@end
