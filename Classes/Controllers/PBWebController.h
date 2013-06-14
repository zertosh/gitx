//
//  PBWebController.h
//  GitX
//
//  Created by Pieter de Bie on 08-10-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class PBGitRepository;

@interface PBWebController : NSObject {
	IBOutlet WebView* view;
	BOOL finishedLoading;

	// For async git reading
	NSMapTable *callbacks;
}

@property (nonatomic, strong) NSString *startFile;
@property (nonatomic, strong) IBOutlet PBGitRepository *repository;

- (WebScriptObject *) script;
- (void) closeView;
@end
