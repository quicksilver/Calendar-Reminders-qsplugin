//
//  QSiCalModule.h
//  QSiCalModule
//
//  Created by Nicholas Jitkoff on 9/12/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSiCalModule.h"
#import <EventKit/EventKit.h>
@interface QSiCalModule : NSObject
{
	EKEventStore *eventStore;
	NSArray * _remindersCalendars;
	NSArray * _eventsCalendars;
}
@end

