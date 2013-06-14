//
//  PBGitSHA.m
//  GitX
//
//  Created by BrotherBard on 3/28/10.
//  Copyright 2010 BrotherBard. All rights reserved.
//

#import "PBGitSHA.h"

#import <git2/errors.h>

@interface PBGitSHA ()

@property (nonatomic, assign) git_oid oid;
@property (nonatomic, strong) NSString *string;

- (id)initWithOID:(git_oid)g_oid;

@end


@implementation PBGitSHA


+ (PBGitSHA *)shaWithOID:(git_oid)oid
{
	return [[PBGitSHA alloc] initWithOID:oid];
}


+ (PBGitSHA *)shaWithString:(NSString *)shaString
{
	git_oid oid;
	int err = git_oid_fromstr(&oid, [shaString UTF8String]);
	if (err != GIT_OK)
		return nil;

	return [self shaWithOID:oid];
}


+ (PBGitSHA *)shaWithCString:(const char *)shaCString
{
	git_oid oid;
	int err = git_oid_fromstr(&oid, shaCString);
	if (err != GIT_OK)
		return nil;

	return [self shaWithOID:oid];
}


+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
	return NO;
}


+ (BOOL)isKeyExcludedFromWebScript:(const char *)name
{
	return NO;
}



#pragma mark -
#pragma mark PBGitSHA

- (id)initWithOID:(git_oid)g_oid
{
	self = [super init];
	if (!self)
		return nil;

	self.oid = g_oid;

	return self;
}


- (NSString *)string
{
	if (self->_string) {
		return self->_string;
	}
	const size_t buffer_size = GIT_OID_HEXSZ + 1;
	char hex[buffer_size] = {0};
	
	const char* result = git_oid_tostr(hex, buffer_size, &_oid);
	self.string = [NSString stringWithUTF8String:result];
	return self->_string;
}


- (BOOL)isEqual:(id)otherSHA
{
	if (self == otherSHA)
		return YES;

	if  (!otherSHA)
		return NO;

	git_oid other_oid = ((PBGitSHA *)otherSHA)->_oid;
	return git_oid_cmp(&_oid, &other_oid) == 0;
}


- (BOOL)isEqualToOID:(git_oid)other_oid
{
	return git_oid_cmp(&_oid, &other_oid) == 0;
}


- (NSUInteger)hash
{
	NSUInteger hash;
	memcpy(&hash, &(_oid.id), sizeof(NSUInteger));

	return hash;
}


- (NSString *)description
{
	return [self string];
}



#pragma mark <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    PBGitSHA *copy = [[[self class] allocWithZone:zone] initWithOID:_oid];

	return copy;
}

@end
