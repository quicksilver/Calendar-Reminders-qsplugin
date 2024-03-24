//
//  Chrono.m
//  Calendar Plugin
//
//  Created by Patrick Robertson on 24/03/2024.
//

#import "Chrono.h"

@implementation Chrono

- (id)init {
    if (self = [super init]) {
        vm = [[JSVirtualMachine alloc] init];
        c = [[JSContext alloc] initWithVirtualMachine:vm];
        jscode = [[NSString alloc] initWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Chrono.bundle" withExtension:@"js"]  encoding:NSUTF8StringEncoding error:nil];
        [c evaluateScript:jscode];
    }
    return self;
}

+(id)sharedInstance{
    static id _sharedInstance;
    if (!_sharedInstance){
        _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
        
    }
    return _sharedInstance;
}

-(NSDate *)parse:(NSString *)phrase {
    JSValue *v = [[c objectForKeyedSubscript:@"Chrono"] objectForKeyedSubscript:@"Chrono"];
    JSValue *result = [v invokeMethod:@"parse" withArguments:@[phrase]];
    return [result toDate];

}
@end
