//
//  PBGitSubmodule.m
//  GitX
//
//  Created by Seth Raphael on 9/14/12.
//
//

#import "PBGitSubmodule.h"

@implementation PBGitSubmodule

- (NSString*) path
{
    if (self.submodule) {
        NSString * root = @"";
        if (self.workingDirectory) {
            root = self.workingDirectory;
        }
        return [root stringByAppendingPathComponent:[NSString stringWithUTF8String:git_submodule_path(self.submodule)]];
    } else {
        return nil;
    }
}

- (NSString*) name
{
    if (self.submodule) {
        return [NSString stringWithUTF8String:git_submodule_name(self.submodule)];
    } else {
        return nil;
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Submodule %@ is at %@", [self name], [self path]];
}

@end
