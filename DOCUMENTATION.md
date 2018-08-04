# LIPR Documentation

This documentation explains usage of the LIPR framework. 

LIPR is an unofficial Objective-C framework for programmatically addressing BERG'S [Little Printer](http://bergcloud.com/littleprinter/) [Direct Print API](http://remote.bergcloud.com/developers/littleprinter/direct_print_codes). The Little Printer Direct Print API allows to address a specific Little Printer, identified by an unique access code, from a local computer via HTTP requests.

LIPR has been developed for using it with OS X 10.9 Mavericks, but most classes should also work on iOS and with earlier versions of OS X, though I haven't tested this. I should mark that the Little Printer Direct Print API, as it is today, is designated by BERG to only serve as a temporary solution

## Conceptual

The LIPR framework declares one public class, [LIPrinter]. This class allows for communication with BERG cloud, which is BERG'S web-based solution for in turn addressing Little Printers. 

The LIPR framework employs the concept of *messages*, with a message being anything you would like to be printed by a Little Printer. You don't have to explicitly create a message, instead this will be done by the LIPR framework when you pass on what you want to print to it via one of LIPrinter's public methods. 

Internally, the LIPR framework will then create an instance of the *LIPrinterMessage* class. Once the LIPR framework has received your message and is about to deliver it via an instance of the (framework internal) *LIPrinterConnection* class, what shall always happen at once, this message becomes a *print job*. 

While the LIPR framework is still under some development, it already declares, via the [LIPrinter] class, a number of public methods as well as two public properties, which are documented below. In addition, it exposes a public protocol called [LIPrinter Protocol].

## LIPrinter Class

The LIPrinter class is the class you will be interacting with when you want to print something on a Little Printer. It exposes five public methods and two public properties.

### initWithPrinterAccessCode:

This method is the designated initializer of the LIPrinter class.

	- (id)initWithPrinterAccessCode:(NSString*)accessCode;

Invoke it with the Direct Print API access code that may be retrieved from BERG'S [website](http://remote.bergcloud.com/developers/littleprinter/direct_print_codes). A typical use case will be like this:

	LIPrinter* printer = [[LIPrinter alloc] initWithPrinterAccessCode:@"XXXXXXXXXXXX"];
	
If you instead call the -init: method of the LIPrinter class, the object instance will be initiated with the [printerAccessCode property] set to *nil*. You can then later set the property manually.

### printTextMessage:

	- (NSString*)printTextMessage:(NSString*)text;

### printImageMessage:

	- (NSString*)printImageMessage:(NSImage*)image;

### printMessageWithHeading:andText:

	- (NSString*)printMessageWithHeading:(NSString*)heading andText:(NSString*)text;

### printHTML:

	- (NSString*)printHTML:(NSString*)html

### printerAccessCode

	@property NSString* printerAccessCode;

### delegate

	@property id delegate;

## LIPrinter Protocol

The public LIPrinter Protocol defines four delegate methods that are called by the LIPR framework in different situations. All methods are optional to implement. You can subscribe to receiving the delegate methods' calls by setting your controller object instance as a LIPrinterProtocol compliant delegate:

	#import "LIPR/LIPRinter.h" // Also imports LIPrinterProtocol
	
	// ..
	
	@interface MyAppDelegate : NSObject <NSApplicationDelegate, LIPrinterProtocol> 
	{
	
	// ..

### messagePlacedInQueue:

This delegate method is called by the LIPR framework if a message sent to a Little Printer couldn't be printed immediately.

	- (void)messagePlacedInQueue:(NSString*)messageID

This delegate method will be invoked when other messages are still to be printed. Such a situation may arise if you send multiple message to a Little Printer almost at the same time. The method delivers the unique message ID the LIPR framework has assigned to the message, which might prove useful if you want to track the message's fate later on. 

### printJobInitiated:

This delegate method is called by the LIPR framework when a connection to BERG cloud has been successfully initiated. 

	- (void)printJobInitiated:(NSString*)messageID
 
 The reason behind this method is to indicate that there is an Internet connection and that the BERG cloud is reachable. This method will also deliver the unique message ID the LIPR framework has assigned to the message.

### printJobsucceeded:

This delegate method is invoked by the LIPR framework when the BERG cloud has given feedback that the message has been passed on to a Little Printer successfully. 

	- (void)printJobsucceeded:(NSString*)messageID

Call of this method does not necessarily mean the message you've sent to a Little Printer, and whose unique message ID is passed by this method, will actually be printed, or has already been printed. According to my experience with Little Printer's Direct Print API a success message may be delivered though only a few empty lines will actually get printed. Such a situation may arise if the message is to large in terms of memory, with the limit being around 200 KBytes, or if it contains HTML tags not recognized by the Direct Print API.

### connectionFailedForJob:withErrorCode:

This delegate method is called by the LIPR framework when delivering a message to a Little Printer has failed. 

	- (void)connectionFailedForJob:(NSString*)messageID withErrorCode:(NSString*)errorCode

There are numerous reasons why printing a message may fail. Either there is no Internet connection present, or the connection to the BERG couldn't been made, or the BERG cloud delivered an error code after having received the message. In any case, the method will deliver the unique message ID assigned to it by the LIPR framework and any errorCode which it may have received.