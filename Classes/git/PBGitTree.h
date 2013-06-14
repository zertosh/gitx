//
//  PBGitTree.h
//  GitTest
//
//  Created by Pieter de Bie on 15-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRepository.h"

@interface PBGitTree : NSObject

+ (PBGitTree*) rootForCommit: (id) commit;
+ (PBGitTree*) treeForTree: (PBGitTree*) tree andPath: (NSString*) path;
- (void) saveToFolder: (NSString *) directory;
- (NSString *)textContents;
- (NSString *)blame;
- (NSString *) log:(NSString *)format;

- (NSString*) tmpFileNameForContents;
- (long long)fileSize;

@property (nonatomic, copy) NSString* sha;
@property (nonatomic, copy) NSString* path;
@property (nonatomic, assign) BOOL leaf;
@property (nonatomic, weak) PBGitRepository* repository;
@property (nonatomic, weak) PBGitTree* parent;

@property (nonatomic, strong, readonly) NSArray* children;
@property (nonatomic, readonly) NSString* fullPath;
@property (nonatomic, readonly) NSString* contents;

@end
