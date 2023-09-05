//
//  QSiCalModule.h
//  QSiCalModule
//
//  Created by Nicholas Jitkoff on 9/12/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSiCalModule.h"
#import <EventKit/EventKit.h>
@interface QSiCalModule : QSObjectSource
{
	EKEventStore *eventStore;
    NSArray *_eventsCalendars;
    NSArray *_remindersCalendars;
}
+(id)sharedInstance;
- (NSArray *)eventsCalendars;
- (NSArray *)remindersCalendars;
@end

