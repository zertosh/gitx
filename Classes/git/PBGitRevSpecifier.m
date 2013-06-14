//
//  PBGitRevSpecifier.m
//  GitX
//
//  Created by Pieter de Bie on 12-09-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBGitRevSpecifier.h"

@interface PBGitRevSpecifier ()

@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSArray *parameters;
@property(nonatomic, assign) BOOL isSimpleRef;

@end

@implementation PBGitRevSpecifier

// internal designated init
- (id) initWithParameters:(NSArray *)params description:(NSString *)descrip
{
    self = [super init];
	if (!self) {
		return nil;
	}
	
	self.parameters = params;
	self.description = descrip;

	if (([self.parameters count] > 1) || ([self.parameters count] == 0))
		self.isSimpleRef =  NO;
	else {
		NSString *param = [self.parameters objectAtIndex:0];
		if ([param hasPrefix:@"-"] ||
			[param rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"^@{}~:"]].location != NSNotFound ||
			[param rangeOfString:@".."].location != NSNotFound)
			self.isSimpleRef =  NO;
		else
			self.isSimpleRef =  YES;
	}

	return self;
}

- (id) initWithParameters:(NSArray *)params
{
	self = [self initWithParameters:params description:nil];
	return self;
}

- (id) initWithRef:(PBGitRef *)ref
{
	self = [self initWithParameters:[NSArray arrayWithObject:ref.ref] description:ref.shortName];
	return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [self initWithParameters:[coder decodeObjectForKey:@"Parameters"] description:[coder decodeObjectForKey:@"Description"]];
	return self;
}

+ (PBGitRevSpecifier *)allBranchesRevSpec
{
    // Using --all here would include refs like refs/notes/commits, which probably isn't what we want.
	return [[PBGitRevSpecifier alloc] initWithParameters:[NSArray arrayWithObjects:@"--branches", @"--remotes", @"--tags", @"--glob=refs/stash*", nil] description:@"All branches"];
}

+ (PBGitRevSpecifier *)localBranchesRevSpec
{
	return [[PBGitRevSpecifier alloc] initWithParameters:[NSArray arrayWithObject:@"--branches"] description:@"Local branches"];
}

- (NSString*) simpleRef
{
	if (![self isSimpleRef])
		return nil;
	return [self.parameters objectAtIndex:0];
}

- (PBGitRef *) ref
{
	if (![self isSimpleRef])
		return nil;

	return [PBGitRef refFromString:[self simpleRef]];
}

- (NSString *) description
{
	if (!self->_description) {
		return [self.parameters componentsJoinedByString:@" "];
	}
	return self->_description;
}

- (NSString *) title
{
	NSString *title = nil;
	
	if ([self.description isEqualToString:@"HEAD"])
		title = @"detached HEAD";
	else if ([self isSimpleRef])
		title = [[self ref] shortName];
	else if ([self.description hasPrefix:@"-S"])
		title = [self.description substringFromIndex:[@"-S" length]];
	else if ([self.description hasPrefix:@"HEAD -- "])
		title = [self.description substringFromIndex:[@"HEAD -- " length]];
	else if ([self.description hasPrefix:@"-- "])
		title = [self.description substringFromIndex:[@"-- " length]];
	else if ([self.description hasPrefix:@"--left-right "])
		title = [self.description substringFromIndex:[@"--left-right " length]];
	else
		title = self.description;
	
	return [NSString stringWithFormat:@"\"%@\"", title];
}

- (BOOL) hasPathLimiter;
{
	for (NSString* param in self.parameters) {
		if ([param isEqualToString:@"--"]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) hasLeftRight
{
	for (NSString* param in self.parameters) {
		if ([param isEqualToString:@"--left-right"]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) isEqual:(PBGitRevSpecifier *)other
{
	if ([self isSimpleRef] ^ [other isSimpleRef])
		return NO;
	
	if ([self isSimpleRef])
		return [[[self parameters] objectAtIndex:0] isEqualToString:[other.parameters objectAtIndex:0]];

	return [self.description isEqualToString:other.description];
}

- (NSUInteger) hash
{
	if ([self isSimpleRef])
		return [[[self parameters] objectAtIndex:0] hash];

	return [self.description hash];
}

- (BOOL) isAllBranchesRev
{
	return [self isEqual:[PBGitRevSpecifier allBranchesRevSpec]];
}

- (BOOL) isLocalBranchesRev
{
	return [self isEqual:[PBGitRevSpecifier localBranchesRevSpec]];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.description forKey:@"Description"];
	[coder encodeObject:self.parameters forKey:@"Parameters"];
}

- (id)copyWithZone:(NSZone *)zone
{
    PBGitRevSpecifier *copy = [[[self class] allocWithZone:zone] initWithParameters:[self.parameters copy]];
    copy.description = [self.description copy];
	copy.workingDirectory = [self.workingDirectory copy];

    return copy;
}

@end
