//
//  QSiCalModule.m
//  QSiCalModule
//
//  Created by Nicholas Jitkoff on 9/12/04.
//  Updated by Patrick Robertson on 16/08/12
//

#import "QSiCalModule.h"
#import <CalendarStore/CalendarStore.h>


#define dayAttributes [NSDictionary dictionaryWithObjectsAndKeys:style,NSParagraphStyleAttributeName,[NSFont fontWithName:@"Helvetica Bold" size:54], NSFontAttributeName,[NSColor colorWithCalibratedWhite:0.2 alpha:1.0],NSForegroundColorAttributeName,nil]
#define monthAttributes [NSDictionary dictionaryWithObjectsAndKeys:style2,NSParagraphStyleAttributeName,[NSNumber numberWithFloat:0.0],NSKernAttributeName,[NSFont fontWithName:@"Helvetica Bold" size:14], NSFontAttributeName,[NSColor whiteColor],NSForegroundColorAttributeName,nil]

#define kQSiCalCreateToDoAction @"QSiCalCreateToDoAction"

@implementation QSiCalModule

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
    
    NSArray *listOfCalendars = [[CalCalendarStore defaultCalendarStore] calendars];
	
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[listOfCalendars count]];
	if (!listOfCalendars) {
		[[NSAlert alertWithMessageText:@"iCal Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You need to upgrade your calendars to a format compatible with Mac OS X Leopard by opening iCal first"] runModal];
	}
	for (CalCalendar *eachItem in listOfCalendars) {
        if(!([[eachItem type] isEqualToString:@"Birthday"]))
		{
            if ([action isEqualToString:kQSiCalCreateToDoAction]) {
                // some calendars don't support adding todos, they just throw an error when you try to create a task. We have to do a bit of trickery here to determine if they can support tasks or not by attempting to add one and then listening for the err.
                NSError *err = nil;
                CalTask *testTask = [CalTask task];
                [testTask setCalendar:eachItem];
                [[CalCalendarStore defaultCalendarStore] saveTask:testTask error:&err];
                // [err code] gives 1025 when "The xxx calendar does not support tasks"
                if (err) {
                    continue;
                }
            }
            
            QSObject *object = [QSObject objectWithName:[eachItem title]];
            [object setDetails:@"Calendar"];
            [object setIcon:[QSResourceManager imageNamed:@"calendarIcon"]];
            [object setObject:[eachItem title] forType:@"QSICalCalendar"];
            [object setObject:[eachItem uid] forMeta:@"QSiCalCalendarUID"];
            [array addObject:object];
            
            
		}
	}
    return [array autorelease];
    
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
    date=[date dateByAddingTimeInterval:-[[NSTimeZone localTimeZone] secondsFromGMTForDate:date]];
	if (!date) date=[NSDate date];
	
    CalEvent *newEvent = [CalEvent event];
    NSArray *listOfCalendars = [[CalCalendarStore defaultCalendarStore] calendars];
    CalCalendar *theCalendar = nil;
    if (iObject) {
        theCalendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:[iObject objectForMeta:@"QSiCalCalendarUID"]];
    } else if ([listOfCalendars count]) {
        // use a default calendar
        theCalendar = [listOfCalendars objectAtIndex:0];
    } else {
        NSBeep();
        QSiCalNotif(@"Failed to create event", @"No calendars to set the event for");
        return nil;
    }
    
    [newEvent setCalendar:theCalendar];
    [newEvent setTitle:subjectString];
    [newEvent setStartDate:date];
    [newEvent setEndDate:[date dateByAddingTimeInterval:60*60]];
    
    NSError *err = nil;
    [[CalCalendarStore defaultCalendarStore] saveEvent:newEvent span:CalSpanAllEvents error:&err];
    
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
	
    CalTask *newTask = [CalTask task];
    NSArray *listOfCalendars = [[CalCalendarStore defaultCalendarStore] calendars];
    CalCalendar *theCalendar = nil;
    if (iObject) {
        theCalendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:[iObject objectForMeta:@"QSiCalCalendarUID"]];
    } else if ([listOfCalendars count]) {
        // use a default calendar
        theCalendar = [listOfCalendars objectAtIndex:0];
    } else {
        NSBeep();
        QSiCalNotif(@"Action Failed", @"No calendars to set the To-Do");
        return nil;
    }
    
    NSArray *bits = [subjectString componentsSeparatedByString:@"!"];
    
    // convert the number of !! at the start of the todo into a CalPriority obj
    NSUInteger priority = [bits count];
    CalPriority calPriority;
    NSString *todoTitle = [[bits lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (priority == 1) {
        calPriority = CalPriorityNone;
    } else if (priority == 2) {
        calPriority = CalPriorityLow;
    } else if (priority == 3) {
        calPriority = CalPriorityMedium;
    } else {
        calPriority = CalPriorityHigh;
    }
	
    [newTask setCalendar:theCalendar];
    [newTask setTitle:todoTitle];
    [newTask setPriority:calPriority];
    
    NSError *err = nil;
    
    [[CalCalendarStore defaultCalendarStore] saveTask:newTask error:&err];
    
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