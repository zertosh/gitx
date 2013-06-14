//
//  PBGitRevSpecifier.h
//  GitX
//
//  Created by Pieter de Bie on 12-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitRef.h"

@interface PBGitRevSpecifier : NSObject  <NSCopying>

- (id) initWithParameters:(NSArray *)params description:(NSString *)descrip;
- (id) initWithParameters:(NSArray*) params;
- (id) initWithRef: (PBGitRef*) ref;

- (NSString*) simpleRef;
- (PBGitRef *) ref;
- (BOOL) hasPathLimiter;
- (BOOL) hasLeftRight;
- (NSString *) title;

- (BOOL) isEqual: (PBGitRevSpecifier*) other;
- (BOOL) isAllBranchesRev;
- (BOOL) isLocalBranchesRev;

+ (PBGitRevSpecifier *)allBranchesRevSpec;
+ (PBGitRevSpecifier *)localBranchesRevSpec;

@property(nonatomic, strong, readonly) NSString *description;
@property(nonatomic, strong, readonly) NSArray *parameters;
@property(nonatomic, assign, readonly) BOOL isSimpleRef;

@property(nonatomic, strong) NSURL *workingDirectory;

@end
