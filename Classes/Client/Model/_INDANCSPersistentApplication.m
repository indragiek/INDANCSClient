// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to INDANCSPersistentApplication.m instead.

#import "_INDANCSPersistentApplication.h"

const struct INDANCSPersistentApplicationAttributes INDANCSPersistentApplicationAttributes = {
	.bundleIdentifier = @"bundleIdentifier",
	.displayName = @"displayName",
};

const struct INDANCSPersistentApplicationRelationships INDANCSPersistentApplicationRelationships = {
};

const struct INDANCSPersistentApplicationFetchedProperties INDANCSPersistentApplicationFetchedProperties = {
};

@implementation INDANCSPersistentApplicationID
@end

@implementation _INDANCSPersistentApplication

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"INDANCSPersistentApplication" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"INDANCSPersistentApplication";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"INDANCSPersistentApplication" inManagedObjectContext:moc_];
}

- (INDANCSPersistentApplicationID*)objectID {
	return (INDANCSPersistentApplicationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic bundleIdentifier;






@dynamic displayName;











@end
