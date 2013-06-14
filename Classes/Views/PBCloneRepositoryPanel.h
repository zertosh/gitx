//
//  PBCloneRepositoryPanel.h
//  GitX
//
//  Created by Nathan Kinsinger on 2/7/10.
//  Copyright 2010 Nathan Kinsinger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PBCloneRepositoryPanel : NSWindowController+ (id) panel;
+ (void)beginCloneRepository:(NSString *)repository toURL:(NSURL *)targetURL isBare:(BOOL)bare;

- (void)showErrorSheet:(NSError *)error;

- (IBAction) closeCloneRepositoryPanel:(id)sender;
- (IBAction) clone:(id)sender;
- (IBAction) browseRepository:(id)sender;
- (IBAction) showHideHiddenFiles:(id)sender;
- (IBAction) browseDestination:(id)sender;

@property (nonatomic, weak) IBOutlet NSTextField *repositoryURL;
@property (nonatomic, weak) IBOutlet NSTextField *destinationPath;
@property (nonatomic, weak) IBOutlet NSTextField *errorMessage;
@property (nonatomic, weak) IBOutlet NSView      *repositoryAccessoryView;

@property (nonatomic, assign) BOOL isBare;

@end
