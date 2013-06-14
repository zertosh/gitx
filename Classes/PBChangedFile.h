//
//  PBChangedFile.h
//  GitX
//
//  Created by Pieter de Bie on 22-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRepository.h"

typedef enum {
	NEW,
	MODIFIED,
	DELETED
} PBChangedFileStatus;

@interface PBChangedFile : NSObject

@property (copy) NSString *path;
@property (copy) NSString *commitBlobSHA;
@property (copy) NSString *commitBlobMode;
@property (assign) PBChangedFileStatus status;
@property (assign) BOOL hasStagedChanges;
@property (assign) BOOL hasUnstagedChanges;

- (NSImage *)icon;
- (NSString *)indexInfo;

- (id) initWithPath:(NSString *)p;

@end
