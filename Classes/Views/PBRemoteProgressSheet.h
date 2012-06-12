//
//  PBRemoteProgressSheetController.h
//  GitX
//
//  Created by Nathan Kinsinger on 12/6/09.
//  Copyright 2009 Nathan Kinsinger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RJModalRepoSheet.h"

extern NSString * const kGitXProgressDescription;
extern NSString * const kGitXProgressSuccessDescription;
extern NSString * const kGitXProgressSuccessInfo;
extern NSString * const kGitXProgressErrorDescription;
extern NSString * const kGitXProgressErrorInfo;

@class PBGitWindowController;
@class PBGitRepository;

@interface PBRemoteProgressSheet : NSWindowController {
	NSArray  *arguments;
	NSString *title;
	NSString *description;
	bool hideSuccessScreen;

	NSTask    *gitTask;
	NSInteger  returnCode;

	NSTimer *taskTimer;
}

- (id) initForRepo:(PBGitRepository*)repository;
- (id) initForWindow:(NSWindowController*)parentWindow;

- (void) beginRemoteProgressSheetForArguments:(NSArray *)args
										title:(NSString *)theTitle
								  description:(NSString *)theDescription
							hideSuccessScreen:(bool)hideSucc;


@property (nonatomic, dct_weak) IBOutlet NSTextField         *progressDescription;
@property (nonatomic, dct_weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) PBGitRepository* repository;
@property (nonatomic, strong) NSWindowController* parentWindow;

- (void) show;
- (void) hide;

@end
