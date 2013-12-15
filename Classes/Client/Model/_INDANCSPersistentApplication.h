// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to INDANCSPersistentApplication.h instead.

#import <CoreData/CoreData.h>


extern const struct INDANCSPersistentApplicationAttributes {
	__unsafe_unretained NSString *bundleIdentifier;
	__unsafe_unretained NSString *displayName;
} INDANCSPersistentApplicationAttributes;

extern const struct INDANCSPersistentApplicationRelationships {
} INDANCSPersistentApplicationRelationships;

extern const struct INDANCSPersistentApplicationFetchedProperties {
} INDANCSPersistentApplicationFetchedProperties;





@interface INDANCSPersistentApplicationID : NSManagedObjectID {}
@end

@interface _INDANCSPersistentApplication : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (INDANCSPersistentApplicationID*)objectID;





@property (nonatomic, strong) NSString* bundleIdentifier;



//- (BOOL)validateBundleIdentifier:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;






@end

@interface _INDANCSPersistentApplication (CoreDataGeneratedAccessors)

@end

@interface _INDANCSPersistentApplication (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBundleIdentifier;
- (void)setPrimitiveBundleIdentifier:(NSString*)value;




- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




@end
