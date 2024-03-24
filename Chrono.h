//
//  Chrono.h
//  Calendar Plugin
//
//  Created by Patrick Robertson on 24/03/2024.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface Chrono : NSObject {
    JSVirtualMachine *vm;
    NSString *jscode;
    JSContext *c;
}

+(id)sharedInstance;
-(NSDate *)parse:(NSString *)phrase;

@end

NS_ASSUME_NONNULL_END
