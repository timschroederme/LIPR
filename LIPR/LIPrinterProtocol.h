//
//  LIPrinterProtocol.h
//  LIPR
//
//  Created by Tim Schröder on 25.12.13.
//  Copyright (c) 2013 Tim Schröder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LIPrinterProtocol <NSObject>

@optional
-(void)messagePlacedInQueue:(NSString*)messageID;
-(void)printJobInitiated:(NSString*)messageID;
-(void)printJobsucceeded:(NSString*)messageID;
-(void)connectionFailedForJob:(NSString*)messageID withErrorCode:(NSString*)errorCode;

@end
