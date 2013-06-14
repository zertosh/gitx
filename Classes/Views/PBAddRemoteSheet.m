//
//  PBAddRemoteSheet.m
//  GitX
//
//  Created by Nathan Kinsinger on 12/8/09.
//  Copyright 2009 Nathan Kinsinger. All rights reserved.
//

#import "PBAddRemoteSheet.h"
#import "PBGitWindowController.h"
#import "PBGitRepository.h"

@implementation PBAddRemoteSheet

#pragma mark -
#pragma mark PBAddRemoteSheet

- (id) initWithRepository:(PBGitRepository *)repo
{
	self = [super initWithWindowNibName:@"PBAddRemoteSheet" forRepo:repo];
	if (!self)
		return nil;

	return self;
}

- (void) show
{
	[self.errorMessage setStringValue:@""];
	[super show];
}

#pragma mark IBActions

- (IBAction) browseFolders:(id)sender
{
	[self hide];

    self.browseSheet = [NSOpenPanel openPanel];

	[self.browseSheet setTitle:@"Add remote"];
    [self.browseSheet setMessage:@"Select a folder with a git repository"];
    [self.browseSheet setCanChooseFiles:NO];
    [self.browseSheet setCanChooseDirectories:YES];
    [self.browseSheet setAllowsMultipleSelection:NO];
    [self.browseSheet setCanCreateDirectories:NO];
	[self.browseSheet setAccessoryView:self.browseAccessoryView];

    [self.browseSheet beginSheetModalForWindow:self.repoWindow.window
                        completionHandler:^(NSInteger result) {
                            [self hide];
                            if (result == NSOKButton) {
                                NSString* directory = self.browseSheet.directoryURL.path;
                                [self.remoteURL setStringValue:directory];
                            }
                            [self show];
                        }];
}


- (IBAction) addRemote:(id)sender
{
	[self.errorMessage setStringValue:@""];

	NSString *name = [[self.remoteName stringValue] copy];

	if ([name isEqualToString:@""]) {
		[self.errorMessage setStringValue:@"Remote name is required"];
		return;
	}

	if (![self.repository checkRefFormat:[@"refs/remotes/" stringByAppendingString:name]]) {
		[self.errorMessage setStringValue:@"Invalid remote name"];
		return;
	}

	NSString *url = [[self.remoteURL stringValue] copy];
	if ([url isEqualToString:@""]) {
		[self.errorMessage setStringValue:@"Remote URL is required"];
		return;
	}

	PBGitRepository* repo = self.repository;
	[self hide]; // may deallocate self
	[repo beginAddRemote:name forURL:url];
}

- (IBAction) showHideHiddenFiles:(id)sender
{
    [self.browseSheet setShowsHiddenFiles:[sender state] == NSOnState];
}

- (IBAction) cancelOperation:(id)sender
{
//	[super cancelOperation:sender];
	[self hide];
}

@end
