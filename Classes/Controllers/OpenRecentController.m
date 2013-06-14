//
//  OpenRecentController.m
//  GitX
//
//  Created by Hajo Nils Krabbenhöft on 07.10.10.
//  Copyright 2010 spratpix GmbH & Co. KG. All rights reserved.
//

#import "OpenRecentController.h"
#import "PBGitDefaults.h"

@implementation OpenRecentController

- (id)init
{
	self = [super initWithWindowNibName:@"OpenRecentPopup"];
	if (!self)
		return nil;
	
	self.currentResults = [NSMutableArray array];
	
	self.possibleResults = [NSMutableArray array];
	for (NSURL *url in [[NSDocumentController sharedDocumentController] recentDocumentURLs]) {
		[self.possibleResults addObject: url];
	}
	
	
	return self;
}

- (void) show
{
	[self doSearch:self];
	[self.window makeKeyAndOrderFront:self];
}

- (void) hide
{
	[[self window] orderOut:self];
}

- (IBAction)doSearch:(id) sender
{
	NSString *searchString = [searchField stringValue];
	
	[self.currentResults removeAllObjects];
	
    for(NSURL* url in self.possibleResults){
		NSString* label = [url lastPathComponent];
		if([searchString length] > 0) {
			NSRange aRange = [label rangeOfString: searchString options: NSCaseInsensitiveSearch];
			if (aRange.location == NSNotFound) continue;
		}
		[self.currentResults addObject: url];
    }   
	
	if( [self.currentResults count] > 0 ) {
		selectedResult = [self.currentResults objectAtIndex:0];
	} else {
		selectedResult = nil;
	}
	
	[resultViewer reloadData];
}

- (void)awakeFromNib
{
	[super awakeFromNib];
    [resultViewer setTarget:self];
    [resultViewer setDoubleAction:@selector(tableDoubleClick:)];
}

- (IBAction) tableDoubleClick:(id)sender 
{
	[self changeSelection:self];
	if(selectedResult != nil) {
		[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:selectedResult
                                                                               display:YES
                                                                                 error:nil];
	}
	[self hide];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:)) {
		if(selectedResult != nil) {
			[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:selectedResult
                                                                                   display:YES
                                                                                     error:nil];
		}
		[self hide];
//		[searchWindow makeKeyAndOrderFront: nil];
		result = YES;
    }
	else if(commandSelector == @selector(cancelOperation:)) {
		[self hide];
		result = YES;
	}
	else if(commandSelector == @selector(moveUp:)) {
		if(selectedResult != nil) {
			int index = [self.currentResults indexOfObject: selectedResult]-1;
			if(index < 0) index = 0;
			selectedResult = [self.currentResults objectAtIndex:index];
			[resultViewer selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:FALSE];
			[resultViewer scrollRowToVisible:index];
		}
		result = YES;
	}
	else if(commandSelector == @selector(moveDown:)) {
		if(selectedResult != nil) {
			int index = [self.currentResults indexOfObject: selectedResult]+1;
			if(index >= [self.currentResults count]) index = [self.currentResults count] - 1;
			selectedResult = [self.currentResults objectAtIndex:index];
			[resultViewer selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:FALSE];
			[resultViewer scrollRowToVisible:index];
		}
		result = YES;
	}
    return result;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{	
    id theValue = nil;
    NSParameterAssert(rowIndex >= 0 && rowIndex < [self.currentResults count]);
	
    NSURL* row = [self.currentResults objectAtIndex:rowIndex];
	if( [[aTableColumn identifier] isEqualToString: @"icon"] ) {
		id icon;
		NSError* error;
		[row getResourceValue:&icon forKey:NSURLEffectiveIconKey error:&error];
		return icon;
	} else if( [[aTableColumn identifier] isEqualToString: @"label"] ) {
		return [row lastPathComponent];
	}
    return theValue;
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.currentResults count];
}

- (IBAction)changeSelection:(id) sender {
	int i = [resultViewer selectedRow];
	if(i >= 0 && i < [self.currentResults count]) {
		selectedResult = [self.currentResults objectAtIndex: i];
	} else {
		selectedResult = nil;
	}
}

@end
