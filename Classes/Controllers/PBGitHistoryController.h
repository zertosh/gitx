//
//  PBGitHistoryView.h
//  GitX
//
//  Created by Pieter de Bie on 19-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitCommit.h"
#import "PBGitTree.h"
#import "PBViewController.h"
#import "PBCollapsibleSplitView.h"

@class PBGitSidebarController;
@class PBWebHistoryController;
@class PBGitGradientBarView;
@class PBRefController;
@class QLPreviewPanel;
@class PBCommitList;
@class GLFileView;
@class PBGitSHA;
@class PBHistorySearchController;

@interface PBGitHistoryController : PBViewController {
	IBOutlet NSSearchField *searchField;
	IBOutlet NSOutlineView* fileBrowser;
	NSArray *currentFileBrowserSelectionPath;
	IBOutlet PBCollapsibleSplitView *historySplitView;
	IBOutlet PBWebHistoryController *webHistoryController;
    QLPreviewPanel* previewPanel;
	IBOutlet GLFileView *fileView;

	IBOutlet PBGitGradientBarView *upperToolbarView;
	IBOutlet NSButton *mergeButton;
	IBOutlet NSButton *cherryPickButton;
	IBOutlet NSButton *rebaseButton;

	IBOutlet PBGitGradientBarView *scopeBarView;
	IBOutlet NSButton *allBranchesFilterItem;
	IBOutlet NSButton *localRemoteBranchesFilterItem;
	IBOutlet NSButton *selectedBranchFilterItem;

	IBOutlet id webView;
	int selectedCommitDetailsIndex;
	BOOL forceSelectionUpdate;
	
	PBGitCommit *selectedCommit;
}

@property (readonly) NSTreeController* treeController;
@property (assign) int selectedCommitDetailsIndex;
@property  PBGitCommit *webCommit;
@property  PBGitTree* gitTree;
@property (nonatomic, strong) IBOutlet NSArrayController *commitController;
@property (nonatomic, strong) IBOutlet PBRefController *refController;
@property (nonatomic, strong) IBOutlet PBHistorySearchController *searchController;
@property (nonatomic, strong) IBOutlet PBCommitList *commitList;

- (IBAction) setDetailedView:(id)sender;
- (IBAction) setTreeView:(id)sender;
- (IBAction) setBranchFilter:(id)sender;

- (void)selectCommit:(PBGitSHA *)commit;
- (IBAction) refresh:(id)sender;
- (IBAction) toggleQLPreviewPanel:(id)sender;
- (IBAction) openSelectedFile:(id)sender;
- (void) updateQuicklookForce: (BOOL) force;

// Context menu methods
- (NSMenu *)contextMenuForTreeView;
- (NSArray *)menuItemsForPaths:(NSArray *)paths;
- (void)showCommitsFromTree:(id)sender;
- (void)showInFinderAction:(id)sender;
- (void)openFilesAction:(id)sender;

// Repository Methods
- (IBAction) createBranch:(id)sender;
- (IBAction) createTag:(id)sender;
- (IBAction) showAddRemoteSheet:(id)sender;
- (IBAction) merge:(id)sender;
- (IBAction) cherryPick:(id)sender;
- (IBAction) rebase:(id)sender;

// Find/Search methods
- (IBAction)selectNext:(id)sender;
- (IBAction)selectPrevious:(id)sender;

- (void) copyCommitInfo;
- (void) copyCommitSHA;

- (BOOL) hasNonlinearPath;

- (NSMenu *)tableColumnMenu;

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview;
- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex;
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset;
- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset;

@end
