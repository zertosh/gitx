//
//  PBGitSidebar.h
//  GitX
//
//  Created by Pieter de Bie on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBViewController.h"

@class PBSourceViewItem;
@class PBGitHistoryController;
@class PBGitCommitController;

@interface PBGitSidebarController : PBViewController<NSOutlineViewDelegate> {
	IBOutlet NSWindow *window;
	IBOutlet NSOutlineView *sourceView;
	IBOutlet NSPopUpButton *actionButton;
	IBOutlet NSSegmentedControl *remoteControls;

	/* Specific things */
	PBSourceViewItem *stage;

	PBSourceViewItem *branches, *remotes, *tags, *others, *submodules;
}

- (void) selectStage;
- (void) selectCurrentBranch;

- (NSMenu *) menuForRow:(NSInteger)row;
- (void) menuNeedsUpdate:(NSMenu *)menu;

- (IBAction) fetchPullPushAction:(id)sender;

- (void)setHistorySearch:(NSString *)searchString mode:(NSInteger)mode;

@property(nonatomic, strong, readonly) NSMutableArray *items;
@property(nonatomic, strong) IBOutlet NSView *sourceListControlsView;
@property(nonatomic, strong) IBOutlet PBGitHistoryController *historyViewController;
@property(nonatomic, strong) IBOutlet PBGitCommitController *commitViewController;

@end
