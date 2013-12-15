//
//  INDANCSPersistentApplicationStorage.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/14/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSPersistentApplicationStorage.h"
#import <CoreData/CoreData.h>

static NSString * const INDANCSDatabaseFilename = @"ANCSApplications.db";
static NSString * const INDANCSMOMDFilename = @"INDANCSPersistentApplicationStorage";

@interface INDANCSPersistentApplicationStorage ()
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainQueueContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSMutableArray *activeContexts;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@end

@implementation INDANCSPersistentApplicationStorage

#pragma mark - Initialization

- (id)init
{
	if ((self = [super init])) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:INDANCSMOMDFilename withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		NSURL *dataURL = [self.class applicationSupportDirectoryURL];
		NSURL *storeURL = [dataURL URLByAppendingPathComponent:INDANCSDatabaseFilename];
		NSError *coreDataError = nil;
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
		
		NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
								  NSInferMappingModelAutomaticallyOption : @YES,
								  NSSQLitePragmasOption : @{@"journal_mode" : @"WAL"}};
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&coreDataError]) {
			NSLog(@"Error adding persistent store: %@", coreDataError);
			return nil;
		}
		_mainQueueContext = [self newContextWithType:NSMainQueueConcurrencyType];
		_activeContexts = [NSMutableArray array];
		NSLog(@"%@", self.mainQueueContext);
	}
	return self;
}

+ (NSURL *)applicationSupportDirectoryURL
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *appSupportURL = [[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSString *bundleName = NSBundle.mainBundle.infoDictionary[@"CFBundleName"];
	NSURL *dataURL = [appSupportURL URLByAppendingPathComponent:bundleName];
	[fm createDirectoryAtURL:dataURL withIntermediateDirectories:YES attributes:nil error:nil];
	return dataURL;
}

- (NSManagedObjectContext *)newContextWithType:(NSManagedObjectContextConcurrencyType)type
{
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
	[context performBlockAndWait:^{
		context.undoManager = nil;
		context.persistentStoreCoordinator = self.persistentStoreCoordinator;
	}];
	return context;
}

#pragma mark - Fetching




@end
