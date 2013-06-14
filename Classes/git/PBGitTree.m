//
//  PBGitTree.m
//  GitTest
//
//  Created by Pieter de Bie on 15-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBGitTree.h"
#import "PBGitCommit.h"
#import "NSFileHandleExt.h"
#import "PBEasyPipe.h"
#import "PBEasyFS.h"

@interface PBGitTree ()

@property (nonatomic, assign) long long fileSize;
@property (nonatomic, strong) NSString* localFileName;
@property (nonatomic, strong) NSDate* localMtime;
@property (nonatomic, strong) NSArray* children;

@end

@implementation PBGitTree


+ (PBGitTree*) rootForCommit:(id) commit
{
	PBGitCommit* c = commit;
	PBGitTree* tree = [[self alloc] init];
	tree.parent = nil;
	tree.leaf = NO;
	tree.sha = [c realSha];
	tree.repository = c.repository;
	tree.path = @"";
	return tree;
}

+ (PBGitTree*) treeForTree: (PBGitTree*) prev andPath: (NSString*) path;
{
	PBGitTree* tree = [[self alloc] init];
	tree.parent = prev;
	tree.sha = prev.sha;
	tree.repository = prev.repository;
	tree.path = path;
	return tree;
}

- (id)init
{
	self = [super init];
	if (!self) {
		return nil;
	}
	
	self.leaf = YES;
	return self;
}

- (NSString*) refSpec
{
	return [NSString stringWithFormat:@"%@:%@", self.sha, self.fullPath];
}

- (BOOL) isLocallyCached
{
	NSFileManager* fs = [NSFileManager defaultManager];
	if (self.localFileName && [fs fileExistsAtPath:self.localFileName])
	{
		NSDate* mtime = [[fs attributesOfItemAtPath:self.localFileName error: nil] objectForKey:NSFileModificationDate];
		if ([mtime compare:self.localMtime] == 0)
			return YES;
	}
	return NO;
}

- (BOOL)hasBinaryHeader:(NSString*)contents
{
	if (!contents)
		return NO;

	return [contents rangeOfString:@"\0"
						   options:0
							 range:NSMakeRange(0, ([contents length] >= 8000) ? 7999 : [contents length])].location != NSNotFound;
}

- (BOOL)hasBinaryAttributes
{
	@try {
		// First ask git check-attr if the file has a binary attribute custom set
		NSFileHandle *handle = [self.repository handleInWorkDirForArguments:
								[NSArray arrayWithObjects:
								 @"check-attr",
								 @"binary",
								 [self fullPath],
								 nil]];

		NSData *data = [handle readDataToEndOfFile];
		NSString *string = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
		
		if (!string)
			return NO;
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		
		if ([string hasSuffix:@"binary: set"])
			return YES;
		
		if ([string hasSuffix:@"binary: unset"])
			return NO;
		
		// Binary state unknown, do a check on common filename-extensions
		for (NSString *extension in [NSArray arrayWithObjects:@".pdf", @".jpg", @".jpeg", @".png", @".bmp", @".gif", @".o", nil]) {
			if ([[self fullPath] hasSuffix:extension])
				return YES;
		}
		
		return NO;
	}
	@catch (NSException *exception) {
		return NO;
	}
}

- (NSString*) contents
{
	if (!self.leaf) {
		return [NSString stringWithFormat:@"This is a tree with path %@", [self fullPath]];
	}

	if ([self isLocallyCached]) {
		NSData *data = [NSData dataWithContentsOfFile:self.localFileName];
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (!string)
			string = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
		return string;
	}
	
	return [self.repository outputForArguments:[NSArray arrayWithObjects:@"show", [self refSpec], nil]];
}

- (NSString *) blame
{
	if (!self.leaf)
		return [NSString stringWithFormat:@"This is a tree with path %@", [self fullPath]];
	
	if ([self hasBinaryAttributes])
		return [NSString stringWithFormat:@"%@ appears to be a binary file of %lld bytes", [self fullPath], [self fileSize]];
	
	if ([self fileSize] > 52428800) // ~50MB
		return [NSString stringWithFormat:@"%@ is too big to be displayed (%lld bytes)", [self fullPath], [self fileSize]];
	
	NSString *contents=[self.repository outputInWorkdirForArguments:[NSArray arrayWithObjects:@"blame", @"-p", self.sha, @"--", [self fullPath], nil]];
	
	if ([self hasBinaryHeader:contents])
		return [NSString stringWithFormat:@"%@ appears to be a binary file of %lld bytes", [self fullPath], [self fileSize]];
	
	
	return contents;
}

- (NSString *) log:(NSString *)format
{
	if (!self.leaf)
		return [NSString stringWithFormat:@"This is a tree with path %@", [self fullPath]];
	
	if ([self hasBinaryAttributes])
		return [NSString stringWithFormat:@"%@ appears to be a binary file of %lld bytes", [self fullPath], [self fileSize]];
	
	if ([self fileSize] > 52428800) // ~50MB
		return [NSString stringWithFormat:@"%@ is too big to be displayed (%lld bytes)", [self fullPath], [self fileSize]];

	NSString *contents=[self.repository outputInWorkdirForArguments:[NSArray arrayWithObjects:@"log", [NSString stringWithFormat:@"--pretty=format:%@",format], @"--", [self fullPath], nil]];
	
	if ([self hasBinaryHeader:contents])
		return [NSString stringWithFormat:@"%@ appears to be a binary file of %lld bytes", [self fullPath], [self fileSize]];
	
	
	return contents;
}

- (long long)fileSize
{
	if (self->_fileSize) {
		return self->_fileSize;
	}

	NSFileHandle *handle = [self.repository handleForArguments:[NSArray arrayWithObjects:@"cat-file", @"-s", [self refSpec], nil]];
	NSString *sizeString = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSISOLatin1StringEncoding];

	if (!sizeString)
		self.fileSize = -1;
	else
		self.fileSize = [sizeString longLongValue];

	return self->_fileSize;
}

- (NSString *)textContents
{
	if (!self.leaf)
		return [NSString stringWithFormat:@"This is a tree with path %@", [self fullPath]];

	if ([self hasBinaryAttributes])
		return [NSString stringWithFormat:@"%@ appears to be a binary file of %lld bytes", [self fullPath], [self fileSize]];

	if ([self fileSize] > 52428800) // ~50MB
		return [NSString stringWithFormat:@"%@ is too big to be displayed (%lld bytes)", [self fullPath], [self fileSize]];

	NSString* contents = [self contents];

	if ([self hasBinaryHeader:contents])
		return [NSString stringWithFormat:@"%@ appears to be a binary file of %lld bytes", [self fullPath], [self fileSize]];

	return contents;
}

- (void) saveToFolder: (NSString *) dir
{
	NSString* newName = [dir stringByAppendingPathComponent:self.path];

	if (self.leaf) {
		NSFileHandle* handle = [self.repository handleForArguments:[NSArray arrayWithObjects:@"show", [self refSpec], nil]];
		NSData* data = [handle readDataToEndOfFile];
		[data writeToFile:newName atomically:YES];
	} else { // Directory
        NSError *error = nil;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:newName withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error creating directory %@: %@", newName, error);
            return;
        }
		for (PBGitTree* child in [self children])
			[child saveToFolder: newName];
	}
}

- (NSString*) tmpDirWithContents
{
	if (self.leaf) {
		return nil;
	}

	if (!self.localFileName) {
		self.localFileName = [PBEasyFS tmpDirWithPrefix:self.path];
	}

	for (PBGitTree* child in [self children]) {
		[child saveToFolder:self.localFileName];
	}
	
	return self.localFileName;
}

	

- (NSString*) tmpFileNameForContents
{
	if (!self.leaf) {
		return [self tmpDirWithContents];
	}
	
	if ([self isLocallyCached]) {
		return self.localFileName;
	}
	
	if (!self.localFileName)
		self.localFileName = [[PBEasyFS tmpDirWithPrefix:self.sha] stringByAppendingPathComponent:self.path];
	
	NSFileHandle* handle = [self.repository handleForArguments:[NSArray arrayWithObjects:@"show", [self refSpec], nil]];
	NSData* data = [handle readDataToEndOfFile];
	[data writeToFile:self.localFileName atomically:YES];
	
	NSFileManager* fs = [NSFileManager defaultManager];
	self.localMtime = [[fs attributesOfItemAtPath:self.localFileName error: nil] objectForKey:NSFileModificationDate];

	return self.localFileName;
}

- (NSArray*) children
{
	if (self->_children != nil) {
		return self->_children;
	}
	
	NSString* ref = [self refSpec];

	NSFileHandle* handle = [self.repository handleForArguments:[NSArray arrayWithObjects:@"show", ref, nil]];
	[handle readLine];
	[handle readLine];
	
	NSMutableArray* c = [NSMutableArray array];
	
	NSString* p = [handle readLine];
	while (p.length > 0) {
		BOOL isLeaf = ([p characterAtIndex:p.length - 1] != '/');
		if (!isLeaf)
			p = [p substringToIndex:p.length -1];

		PBGitTree* child = [PBGitTree treeForTree:self andPath:p];
		child.leaf = isLeaf;
		[c addObject: child];
		
		p = [handle readLine];
	}
	[c sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		PBGitTree* tree1 = (PBGitTree*)obj1;
		PBGitTree* tree2 = (PBGitTree*)obj2;
		return [[tree1 path] localizedStandardCompare:[tree2 path]];
	}];
	self.children = c;
	return c;
}

- (NSString*) fullPath
{
	if (!self.parent)
		return @"";
	
	if ([self.parent.fullPath isEqualToString:@""])
		return self.path;
	
	return [self.parent.fullPath stringByAppendingPathComponent: self.path];
}

- (void) dealloc
{
	if (self.localFileName) {
        NSError *error = nil;
		if (![[NSFileManager defaultManager] removeItemAtPath:self.localFileName error:&error]) {
            NSLog(@"Failed to remove item %@: %@", self.localFileName, error);
        }
    }
}
@end
