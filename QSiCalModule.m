//
//  QSiCalModule.m
//  QSiCalModule
//
//  Created by Nicholas Jitkoff on 9/12/04.
//  Updated by Patrick Robertson on 16/08/12
//

#import "QSiCalModule.h"


#define dayAttributes [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[NSFont fontWithName:@"Helvetica Bold" size:54], NSFontAttributeName,[NSColor colorWithCalibratedWhite:0.2 alpha:1.0],NSForegroundColorAttributeName,nil]
#define monthAttributes [NSDictionary dictionaryWithObjectsAndKeys:style2,NSParagraphStyleAttributeName,[NSNumber numberWithFloat:0.0],NSKernAttributeName,[NSFont fontWithName:@"Helvetica Bold" size:14], NSFontAttributeName,[NSColor whiteColor],NSForegroundColorAttributeName,nil]

#define kQSiCalCreateToDoAction @"QSiCalCreateToDoAction"

@implementation QSiCalModule

- (id)init {
	if (self = [super init]) {
		eventStore = [[EKEventStore alloc] initWithAccessToEntityTypes:(EKEntityMaskEvent | EKEntityMaskReminder)];
		_eventsCalendars = nil;
		_remindersCalendars = nil;
	}
	return self;
}

- (void)dealloc {
	[eventStore release];
	[super dealloc];
}

- (void)requestAccessForType:(EKEntityType) type {
	[eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError *error){
        if (!granted) {
            // Display a message if the user has denied or restricted access to Calendar
			NSBeep();
			NSString *message = [NSString stringWithFormat:@"Quicksilver requires access to your %@ to edit and add %@. System preferences will now be opened for you to grant access.", type == EKEntityTypeEvent ? @"Calendars" : @"Reminders", type == EKEntityTypeEvent ? @"calendar events" : @"reminders"];
			QSGCDMainSync(^{
				[[NSAlert alertWithMessageText:@"Access Required" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:message] runModal];
				NSString *url = [NSString stringWithFormat:@"x-apple.systempreferences:com.apple.preference.security?Privacy_%@", (type == EKEntityTypeEvent ? @"Calendars" : @"Reminders")];
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
			});

        }
    }];
}
- (NSArray *)remindersCalendars {
	[self requestAccessForType:EKEntityTypeReminder];
	if (!_remindersCalendars) {
		NSArray *reminders = [[eventStore calendarsForEntityType:EKEntityTypeReminder] arrayByEnumeratingArrayUsingBlock:^id(EKCalendar *cal) {
			if (!cal.allowsContentModifications || (cal.allowedEntityTypes & EKEntityMaskReminder) != EKEntityMaskReminder) {
				return nil;
			}
			return cal;
		}];
		[reminders retain];
		_remindersCalendars = reminders;
	}
	return _remindersCalendars;
}

- (NSArray *)eventsCalendars {
	[self requestAccessForType:EKEntityTypeEvent];
	if (!_eventsCalendars) {
		NSArray *calendars = [[eventStore calendarsForEntityType:EKEntityTypeEvent] arrayByEnumeratingArrayUsingBlock:^id(EKCalendar *cal) {
			if (cal.type == EKCalendarTypeBirthday || !cal.allowsContentModifications || (cal.allowedEntityTypes & EKEntityMaskEvent) != EKEntityMaskEvent) {
				return nil;
			}
			return cal;
		}];
		[calendars retain];
		_eventsCalendars = calendars;
	}
	return _eventsCalendars;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{

	if ([action isEqualToString:kQSiCalCreateToDoAction]) {
		NSArray *reminderCalendars = [self remindersCalendars];
		NSArray *objs = [reminderCalendars arrayByEnumeratingArrayUsingBlock:^id(EKCalendar *cal) {
			QSObject *object = [QSObject objectWithName:cal.title];
			[object setDetails:@"Calendar"];
			[object setIcon:[QSResourceManager imageNamed:@"calendarIcon"]];
			[object setObject:cal.title forType:@"QSICalCalendar"];
			[object setPrimaryType:@"QSICalCalendar"];
			[object setObject:cal.calendarIdentifier forMeta:@"QSiCalCalendarUID"];
			return object;
		}];
		return objs;
	} else if ([action isEqualToString:@"QSiCalCreateEventAction"]) {
		NSArray *eventsCalendars = [self eventsCalendars];
		NSArray *objs = [eventsCalendars arrayByEnumeratingArrayUsingBlock:^id(EKCalendar *cal) {
			QSObject *object = [QSObject objectWithName:cal.title];
			[object setDetails:@"Calendar"];
			[object setIcon:[QSResourceManager imageNamed:@"calendarIcon"]];
			[object setObject:cal.title forType:@"QSICalCalendar"];
			[object setPrimaryType:@"QSICalCalendar"];
			[object setObject:cal.calendarIdentifier forMeta:@"QSiCalCalendarUID"];
			return object;
		}];
		return objs;
	}
	return nil;
}

//NSLog(@"objects %@ %@",dObject,iObject);
-(QSObject *)createEvent:(QSObject *)dObject inCalendar:(QSObject *)iObject{
    //	NSString *calendar=iObject?[iObject objectForType:@"QSICalCalendar"]:@"";
	NSString *dateString=[dObject stringValue];
	NSString *subjectString=dateString;
	NSArray *components=[dateString componentsSeparatedByString:@"--"];
	if ([components count]>1){
		dateString=[components objectAtIndex:0];
		subjectString=[[components objectAtIndex:1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	NSDate *date=[NSCalendarDate dateWithNaturalLanguageString:dateString];
	if (!date) date=[NSDate date];
	
    EKEvent *newEvent = [EKEvent eventWithEventStore:eventStore];
    EKCalendar *theCalendar = nil;
    if (iObject) {
        theCalendar = [eventStore calendarWithIdentifier:[iObject objectForMeta:@"QSiCalCalendarUID"]];
    } else if ([[self eventsCalendars] count]) {
        // use a default calendar
        theCalendar = [[self eventsCalendars] objectAtIndex:0];
    } else {
        NSBeep();
        QSiCalNotif(@"Failed to create event", @"No calendars to set the event for. Make sure Quicksilver has access to your Calendars from System Preferences → Security & Privacy");
        return nil;
    }
    
    newEvent.calendar = theCalendar;
    newEvent.title = subjectString;
    newEvent.startDate = date;
    newEvent.endDate = [date dateByAddingTimeInterval:60*60];
    
    NSError *err = nil;
	[eventStore saveEvent:newEvent span:EKSpanThisEvent commit:YES error:&err];
    
    if (err) {
        NSBeep();
        NSLog(@"Error: %@",err);
        return nil;
    }
    
    QSiCalNotif(@"Event Created",subjectString);
    
    
	//-----
	return nil;
}

-(QSObject *)createToDo:(QSObject *)dObject inCalendar:(QSObject *)iObject{

	NSString *subjectString = [dObject stringValue];
	
    EKReminder *newTask = [EKReminder reminderWithEventStore:eventStore];
    EKCalendar *theCalendar = nil;
    if (iObject) {
        theCalendar = [eventStore calendarWithIdentifier:[iObject objectForMeta:@"QSiCalCalendarUID"]];
    } else if ([[self remindersCalendars] count]) {
        // use a default calendar
        theCalendar = [[self remindersCalendars] objectAtIndex:0];
    } else {
        NSBeep();
        QSiCalNotif(@"Action Failed", @"No Reminders list available to add the reminder. Make sure Quicksilver has access to Reminders from System Preferences → Security & Privacy");
        return nil;
    }
    
    NSArray *bits = [subjectString componentsSeparatedByString:@"!"];
    
    // convert the number of !! at the start of the todo into a CalPriority obj
    NSUInteger exclamations = [bits count] - 1;
    NSUInteger calPriority;
    NSString *todoTitle = [[bits lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (exclamations == 0) {
        calPriority = 0;
    } else if (exclamations == 1) {
        calPriority = 9;
    } else if (exclamations == 2) {
        calPriority = 5;
    } else {
        calPriority = 1;
    }
	
    newTask.calendar = theCalendar;
    newTask.title = todoTitle;
    newTask.priority = calPriority;
    
    NSError *err = nil;
	[eventStore saveReminder:newTask commit:YES error:&err];
    
    if (err) {
        NSBeep();
        NSLog(@"Error: %@",err);
        return nil;
    }
    
    QSiCalNotif(@"To-Do Created",todoTitle);
	
	return nil;
}

void QSiCalNotif(NSString *title, NSString *message) {
    QSShowNotifierWithAttributes([NSDictionary dictionaryWithObjectsAndKeys:@"iCalPluginNotif", QSNotifierType, [QSResourceManager imageNamed:@"com.apple.iCal"], QSNotifierIcon, NSLocalizedString(title, nil), QSNotifierTitle, NSLocalizedString(message, nil), QSNotifierText, nil]);
    
}

@end
