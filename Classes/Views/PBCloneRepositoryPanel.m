//
//  PBCloneRepositoryPanel.m
//  GitX
//
//  Created by Nathan Kinsinger on 2/7/10.
//  Copyright 2010 Nathan Kinsinger. All rights reserved.
//

#import "PBCloneRepositoryPanel.h"
#import "PBRemoteProgressSheet.h"
#import "PBGitDefaults.h"

@interface PBCloneRepositoryPanel ()

@property (nonatomic, strong) NSOpenPanel *browseRepositoryPanel;
@property (nonatomic, strong) NSOpenPanel *browseDestinationPanel;
@property (nonatomic, strong) NSString *path;

@end


@implementation PBCloneRepositoryPanel

#pragma mark -
#pragma mark PBCloneRepositoryPanel

+ (id) panel
{
	return [[self alloc] initWithWindowNibName:@"PBCloneRepositoryPanel"];
}

+ (void)beginCloneRepository:(NSString *)repository toURL:(NSURL *)targetURL isBare:(BOOL)bare
{
	if (!repository || [repository isEqualToString:@""] || !targetURL || [[targetURL path] isEqualToString:@""])
		return;

	PBCloneRepositoryPanel *clonePanel = [PBCloneRepositoryPanel panel];
	[clonePanel showWindow:self];

	[clonePanel.repositoryURL setStringValue:repository];
	[clonePanel.destinationPath setStringValue:[targetURL path]];
	clonePanel.isBare = bare;

	[clonePanel clone:self];
}


- (void) awakeFromNib
{
	[self window];
	[self.errorMessage setStringValue:@""];
	self.path = [PBGitDefaults recentCloneDestination];
	if (self.path) {
		[self.destinationPath setStringValue:self.path];
	}
	
	self.browseRepositoryPanel = [NSOpenPanel openPanel];
	[self.browseRepositoryPanel setTitle:@"Browse for git repository"];
	[self.browseRepositoryPanel setMessage:@"Select a folder with a git repository"];
	[self.browseRepositoryPanel setPrompt:@"Select"];
    [self.browseRepositoryPanel setCanChooseFiles:NO];
    [self.browseRepositoryPanel setCanChooseDirectories:YES];
    [self.browseRepositoryPanel setAllowsMultipleSelection:NO];
	[self.browseRepositoryPanel setCanCreateDirectories:NO];
	[self.browseRepositoryPanel setAccessoryView:self.repositoryAccessoryView];
	
	self.browseDestinationPanel = [NSOpenPanel openPanel];
	[self.browseDestinationPanel setTitle:@"Browse clone destination"];
	[self.browseDestinationPanel setMessage:@"Select a folder to clone the git repository into"];
	[self.browseDestinationPanel setPrompt:@"Select"];
    [self.browseDestinationPanel setCanChooseFiles:NO];
    [self.browseDestinationPanel setCanChooseDirectories:YES];
    [self.browseDestinationPanel setAllowsMultipleSelection:NO];
	[self.browseDestinationPanel setCanCreateDirectories:YES];
}


- (void)showErrorSheet:(NSError *)error
{
	[[NSAlert alertWithError:error] beginSheetModalForWindow:[self window]
											   modalDelegate:self
											  didEndSelector:@selector(errorSheetDidEnd:returnCode:contextInfo:)
												 contextInfo:NULL];
}



#pragma mark IBActions

- (IBAction) closeCloneRepositoryPanel:(id)sender
{
	[self close];
}


- (IBAction) clone:(id)sender
{
	[self.errorMessage setStringValue:@""];
	
	NSString *url = [self.repositoryURL stringValue];
	if ([url isEqualToString:@""]) {
		[self.errorMessage setStringValue:@"Repository URL is required"];
		return;
	}
	
	self.path = [self.destinationPath stringValue];
	if ([self.path isEqualToString:@""]) {
		[self.errorMessage setStringValue:@"Destination path is required"];
		return;
	}

	NSMutableArray *arguments = [NSMutableArray arrayWithObjects:@"clone", @"--", url, self.path, nil];
	if (self.isBare) {
		[arguments insertObject:@"--bare" atIndex:1];
	}
	
	NSString *description = [NSString stringWithFormat:@"Cloning repository at: %@", url];
	NSString *title = @"Cloning Repository";
	[PBRemoteProgressSheet beginRemoteProgressSheetForArguments:arguments
														  title:title
													description:description
														  inDir:nil
											   windowController:nil/*self?*/];
}


- (IBAction) browseRepository:(id)sender
{
    [self.browseRepositoryPanel beginSheetModalForWindow:[self window]
                                  completionHandler:^(NSInteger result) {
                                      if (result == NSOKButton) {
                                          NSURL *url = [[self.browseRepositoryPanel URLs] lastObject];
                                          [self.repositoryURL setStringValue:[url path]];
                                      }
                                  }];
}


- (IBAction) showHideHiddenFiles:(id)sender
{
	// This uses undocumented OpenPanel features to show hidden files (required for 10.5 support)
	NSNumber *showHidden = [NSNumber numberWithBool:[sender state] == NSOnState];
	[[self.browseRepositoryPanel valueForKey:@"_navView"] setValue:showHidden forKey:@"showsHiddenFiles"];
}


- (IBAction) browseDestination:(id)sender
{
    [self.browseDestinationPanel beginSheetModalForWindow:[self window]
                                   completionHandler:^(NSInteger result) {
                                       if (result == NSOKButton) {
                                           NSURL *url = [[self.browseDestinationPanel URLs] lastObject];
                                           [self.destinationPath setStringValue:[url path]];
                                       }
                                   }];
}



#pragma mark Callbacks

- (void) messageSheetDidEnd:(NSOpenPanel *)sheet returnCode:(NSInteger)code contextInfo:(void *)info
{
	NSURL *documentURL = [NSURL fileURLWithPath:self.path];
	
	NSError *error = nil;
	id document = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:documentURL display:YES error:&error];
	if (!document && error)
			[self showErrorSheet:error];
	else {
		[self close];
		
		NSString *containingPath = [self.path stringByDeletingLastPathComponent];
		[PBGitDefaults setRecentCloneDestination:containingPath];
		[self.destinationPath setStringValue:containingPath];
		[self.repositoryURL setStringValue:@""];
	}
}


- (void) errorSheetDidEnd:(NSOpenPanel *)sheet returnCode:(NSInteger)code contextInfo:(void *)info
{
	[self close];
}


@end
