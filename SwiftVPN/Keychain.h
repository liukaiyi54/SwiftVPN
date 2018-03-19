//
//  Keychain.h
//  SwiftVPN
//
//  Created by Michael on 15/03/2018.
//  Copyright © 2018 Michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject

+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier;

+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;

+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;

@end
