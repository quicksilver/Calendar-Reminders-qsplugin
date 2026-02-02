//
//  ZoomSource.h
//  Zoom
//
//  Created by Rob McBroom
//

#define ZoomURLFormat @"zoommtg://%@/join?action=join&confno=%@"
#define MeetingEventFormat @"CalendarMeeting:%@"

#import <EventKit/EventKit.h>
#import <AppKit/AppKit.h>

QSObject *objectFromEvent(EKEvent *event, NSDictionary *eventData);
NSDictionary *meetingDataFromString(NSString *sourceText);
NSDictionary *meetingDataFromEvent(EKEvent *event);
NSImage *iconForMeetingURL(NSString *urlString);
