//
//  PBGitCommit.h
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRepository.h"
#import "PBGitTree.h"
#import "PBGitRefish.h"
#import "PBGitSHA.h"


extern NSString * const kGitXCommitType;


@interface PBGitCommit : NSObject <PBGitRefish>

+ (PBGitCommit *)commitWithRepository:(PBGitRepository*)repo andSha:(PBGitSHA *)newSha;

- (id)initWithRepository:(PBGitRepository *)repo andSha:(PBGitSHA *)newSha;

- (void) addRef:(PBGitRef *)ref;
- (void) removeRef:(id)ref;
- (BOOL) hasRef:(PBGitRef *)ref;

- (BOOL) isOnSameBranchAs:(PBGitCommit *)other;
- (BOOL) isOnHeadBranch;

// <PBGitRefish>
- (NSString *) refishName;
- (NSString *) shortName;
- (NSString *) refishType;

@property (nonatomic, strong, readonly) PBGitSHA *sha;
@property (readonly) NSString *realSha;
@property (copy) NSString* subject;
@property (copy) NSString* author;
@property (copy) NSString *committer;
@property (copy) NSString *SVNRevision;
@property  NSArray *parents;

@property (assign) int timestamp;

@property  NSMutableArray* refs;
@property (readonly) NSDate *date;
@property (readonly) NSString* dateString;
@property (nonatomic, strong, readonly) NSString* patch;
@property (assign) char sign;

@property (readonly) NSString* details;
@property (readonly) PBGitTree* tree;
@property (readonly) NSArray* treeContents;
@property (nonatomic, weak) PBGitRepository* repository;
@property  id lineInfo;
@end
