//
//  MeetingServices.swift
//  MeetingBar
//
//  Created by Andrii Leitsius on 09.04.2022.
//  Copyright © 2022 Andrii Leitsius. All rights reserved.
//

import AppKit
import Foundation

// MARK: - Objective-C Bridge Functions

/// Objective-C compatible function to detect meeting URLs from text
/// Returns a dictionary with keys: "url" (String) and "service" (String)
@_cdecl("meetingDataFromString")
public func meetingDataFromString(_ sourceText: String) -> NSDictionary? {
	guard let link = detectMeetingLink(sourceText) else {
		return nil
	}
	let serviceName = link.service?.rawValue ?? MeetingServices.other.rawValue
	return ["url": link.url.absoluteString, "service": serviceName] as NSDictionary
}

/// Objective-C compatible function to get icon for a meeting URL string
@_cdecl("iconForMeetingURL")
public func iconForMeetingURL(_ urlString: String) -> NSImage? {
	guard let meetingLink = detectMeetingLink(urlString) else {
		return nil
	}
	return getIconForMeetingService(meetingLink.service)
}

enum MeetingServices: String, Codable, CaseIterable {
	case phone = "Phone"
	case meet = "Google Meet"
	case hangouts = "Google Hangouts"
	case zoom = "Zoom"
	case zoom_native = "Zoom native"
	case teams = "Microsoft Teams"
	case webex = "Cisco Webex"
	case jitsi = "Jitsi"
	case chime = "Amazon Chime"
	case ringcentral = "Ring Central"
	case gotomeeting = "GoToMeeting"
	case gotowebinar = "GoToWebinar"
	case bluejeans = "BlueJeans"
	case eight_x_eight = "8x8"
	case demio = "Demio"
	case join_me = "Join.me"
	case zoomgov = "ZoomGov"
	case whereby = "Whereby"
	case uberconference = "Uber Conference"
	case blizz = "Blizz"
	case teamviewer_meeting = "Teamviewer Meeting"
	case vsee = "VSee"
	case starleaf = "StarLeaf"
	case duo = "Google Duo"
	case voov = "Tencent VooV"
	case facebook_workspace = "Facebook Workspace"
	case lifesize = "Lifesize"
	case skype = "Skype"
	case skype4biz = "Skype For Business"
	case skype4biz_selfhosted = "Skype For Business (SH)"
	case facetime = "Facetime"
	case pop = "Pop"
	case chorus = "Chorus"
	case gong = "Gong"
	case livestorm = "Livestorm"
	case facetimeaudio = "Facetime Audio"
	case youtube = "YouTube"
	case vonageMeetings = "Vonage Meetings"
	case meetStream = "Google Meet Stream"
	case around = "Around"
	case jam = "Jam"
	case discord = "Discord"
	case blackboard_collab = "Blackboard Collaborate"
	case url = "Any Link"
	case coscreen = "CoScreen"
	case vowel = "Vowel"
	case zhumu = "Zhumu"
	case lark = "Lark"
	case feishu = "Feishu"
	case vimeo = "Vimeo"
	case ovice = "oVice"
	case luma = "Luma"
	case preply = "Preply"
	case userzoom = "UserZoom"
	case venue = "Venue"
	case teemyco = "Teemyco"
	case demodesk = "Demodesk"
	case zoho_cliq = "Zoho Cliq"
	case slack = "Slack"
	case gather = "Gather"
	case reclaim = "Reclaim.ai"
	case tuple = "Tuple"
	case pumble = "Pumble"
	case suitConference = "Suit Conference"
	case doxyMe = "Doxy.me"
	case calcom = "Cal Video"
	case zmPage = "zm.page"
	case livekit = "LiveKit Meet"
	case meetecho = "Meetecho"
	case other = "Other"
}

public struct MeetingLink: Hashable, Equatable, Sendable {
	let service: MeetingServices?
	var url: URL
}

enum CreateMeetingLinks {
	static let meet = URL(string: "https://meet.google.com/new")!
	static let zoom = URL(string: "https://zoom.us/start?confno=123456789&zc=0")!
	static let teams = URL(string: "https://teams.microsoft.com/l/meeting/new?subject=")!
	static let jam = URL(string: "https://jam.systems/new")!
	static let coscreen = URL(string: "https://cs.new")!
	static let gcalendar = URL(string: "https://calendar.google.com/calendar/u/0/r/eventedit")!
	static let outlook_live = URL(string: "https://outlook.live.com/calendar/0/action/compose")!
	static let outlook_office365 = URL(string: "https://outlook.office365.com/calendar/0/action/compose")!
}

enum CreateMeetingServices: String, Codable, CaseIterable {
	case meet = "Google Meet"
	case zoom = "Zoom"
	case teams = "Microsoft Teams"
	case jam = "Jam"
	case coscreen = "CoScreen"
	case gcalendar = "Google Calendar"
	case outlook_live = "Outlook Live"
	case outlook_office365 = "Outlook Office365"
	case url = "Custom url"
}

// Simplified - customize this based on your needs
func createMeeting(service: CreateMeetingServices, customURL: String? = nil) {
	let url: URL?
	let meetingService: MeetingServices?
	
	switch service {
	case .meet:
		url = CreateMeetingLinks.meet
		meetingService = .meet
	case .zoom:
		url = CreateMeetingLinks.zoom
		meetingService = .zoom
	case .teams:
		url = CreateMeetingLinks.teams
		meetingService = .teams
	case .jam:
		url = CreateMeetingLinks.jam
		meetingService = .jam
	case .coscreen:
		url = CreateMeetingLinks.coscreen
		meetingService = .coscreen
	case .gcalendar:
		url = CreateMeetingLinks.gcalendar
		meetingService = nil
	case .outlook_office365:
		url = CreateMeetingLinks.outlook_office365
		meetingService = nil
	case .outlook_live:
		url = CreateMeetingLinks.outlook_live
		meetingService = nil
	case .url:
		if let customURL = customURL, let customUrl = URL(string: customURL) {
			url = customUrl
			meetingService = nil
		} else {
			return
		}
	}
	
	if let url = url {
		openMeetingURL(meetingService, url, nil)
	}
}

// Simplified - opens URLs with basic app scheme support
func openMeetingURL(_ service: MeetingServices?, _ url: URL, _ browser: Any? = nil) {
	switch service {
	case .teams:
		// Try to open in Teams app
		var teamsAppURL = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		teamsAppURL.scheme = "msteams"
		if let teamsURL = teamsAppURL.url, NSWorkspace.shared.open(teamsURL) {
			return
		}
		// Fall back to browser
		NSWorkspace.shared.open(url)
		
	case .zoom, .zoomgov:
		// Try to open in Zoom app
		let urlString = url.absoluteString.replacingOccurrences(of: "?", with: "&").replacingOccurrences(of: "/j/", with: "/join?confno=")
		if let zoomURL = URL(string: urlString) {
			var zoomAppUrl = URLComponents(url: zoomURL, resolvingAgainstBaseURL: false)!
			zoomAppUrl.scheme = "zoommtg"
			if let appURL = zoomAppUrl.url, NSWorkspace.shared.open(appURL) {
				return
			}
		}
		// Fall back to browser
		NSWorkspace.shared.open(url)
		
	case .zoom_native:
		if !NSWorkspace.shared.open(url) {
			// Convert to browser URL if app fails
			let urlString = url.absoluteString.replacingOccurrences(of: "zoommtg://", with: "https://").replacingOccurrences(of: "/join?confno=", with: "/j/")
			if let browserURL = URL(string: urlString) {
				NSWorkspace.shared.open(browserURL)
			}
		}
		
	case .jitsi:
		// Try to open in Jitsi app
		var jitsiAppUrl = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		jitsiAppUrl.scheme = "jitsi-meet"
		if let jitsiURL = jitsiAppUrl.url, NSWorkspace.shared.open(jitsiURL) {
			return
		}
		// Fall back to browser
		NSWorkspace.shared.open(url)
		
	case .slack:
		// Try to open in Slack app
		if url.pathComponents.count > 3 {
			let teamID = url.pathComponents[2]
			let huddleID = url.pathComponents[3]
			if let slackUrl = URL(string: "slack://join-huddle?team=\(teamID)&id=\(huddleID)"),
				 NSWorkspace.shared.open(slackUrl) {
				return
			}
		}
		// Fall back to browser
		NSWorkspace.shared.open(url)
		
	case .facetime:
		NSWorkspace.shared.open(URL(string: "facetime://" + url.absoluteString)!)
		
	case .facetimeaudio:
		NSWorkspace.shared.open(URL(string: "facetime-audio://" + url.absoluteString)!)
		
	case .phone:
		NSWorkspace.shared.open(URL(string: "tel://" + url.absoluteString)!)
		
	default:
		NSWorkspace.shared.open(url)
	}
}

private let meetingLinkRegexes: [MeetingServices: NSRegularExpression] = [
	.meet: try! NSRegularExpression(pattern: #"https?://meet.google.com/(_meet/)?[a-z-]+"#),
	.zoom: try! NSRegularExpression(pattern: #"https:\/\/(?:[a-zA-Z0-9-.]+)?zoom(-x)?\.(?:us|com|com\.cn|de)\/(?:my|[a-z]{1,2}|webinar)\/[-a-zA-Z0-9()@:%_\+.~#?&=\/]*"#),
	.zoom_native: try! NSRegularExpression(pattern: #"zoommtg://([a-z0-9-.]+)?zoom(-x)?\.(?:us|com|com\.cn|de)/join[-a-zA-Z0-9()@:%_\+.~#?&=\/]*"#),
	.teams: try! NSRegularExpression(pattern: #"https?://(gov.)?teams\.microsoft\.(com|us)/l/meetup-join/[a-zA-Z0-9_%\/=\-\+\.?]+"#),
	.webex: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?webex\.com/[^\s%]*"#),
	.chime: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?chime\.aws/[0-9]*"#),
	.jitsi: try! NSRegularExpression(pattern: #"https?://meet\.jit\.si/[^\s]*"#),
	.ringcentral: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?ringcentral\.com/[^\s]*"#),
	.gotomeeting: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?gotomeeting\.com/[^\s]*"#),
	.gotowebinar: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?gotowebinar\.com/[^\s]*"#),
	.bluejeans: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?bluejeans\.com/[^\s]*"#),
	.eight_x_eight: try! NSRegularExpression(pattern: #"https?://8x8\.vc/[^\s]*"#),
	.demio: try! NSRegularExpression(pattern: #"https?://event\.demio\.com/[^\s]*"#),
	.join_me: try! NSRegularExpression(pattern: #"https?://join\.me/[^\s]*"#),
	.whereby: try! NSRegularExpression(pattern: #"https?://whereby\.com/[^\s]*"#),
	.uberconference: try! NSRegularExpression(pattern: #"https?://uberconference\.com/[^\s]*"#),
	.blizz: try! NSRegularExpression(pattern: #"https?://go\.blizz\.com/[^\s]*"#),
	.teamviewer_meeting: try! NSRegularExpression(pattern: #"https?://go\.teamviewer\.com/[^\s]*"#),
	.vsee: try! NSRegularExpression(pattern: #"https?://vsee\.com/[^\s]*"#),
	.starleaf: try! NSRegularExpression(pattern: #"https?://meet\.starleaf\.com/[^\s]*"#),
	.duo: try! NSRegularExpression(pattern: #"https?://duo\.app\.goo\.gl/[^\s]*"#),
	.voov: try! NSRegularExpression(pattern: #"https?://voovmeeting\.com/[^\s]*"#),
	.facebook_workspace: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?workplace\.com/groupcall/[^\s]+"#),
	.skype: try! NSRegularExpression(pattern: #"https?://join\.skype\.com/[^\s]*"#),
	.lifesize: try! NSRegularExpression(pattern: #"https?://call\.lifesizecloud\.com/[^\s]*"#),
	.youtube: try! NSRegularExpression(pattern: #"https?://((www|m)\.)?(youtube\.com|youtu\.be)/[^\s]*"#),
	.vonageMeetings: try! NSRegularExpression(pattern: #"https?://meetings\.vonage\.com/[0-9]{9}"#),
	.meetStream: try! NSRegularExpression(pattern: #"https?://stream\.meet\.google\.com/stream/[a-z0-9-]+"#),
	.around: try! NSRegularExpression(pattern: #"https?://(meet\.)?around\.co/[^\s]*"#),
	.jam: try! NSRegularExpression(pattern: #"https?://jam\.systems/[^\s]*"#),
	.discord: try! NSRegularExpression(pattern: #"(http|https|discord)://(www\.)?(canary\.)?discord(app)?\.([a-zA-Z]{2,})(.+)?"#),
	.blackboard_collab: try! NSRegularExpression(pattern: #"https?://us\.bbcollab\.com/[^\s]*"#),
	.coscreen: try! NSRegularExpression(pattern: #"https?://join\.coscreen\.co/[^\s]*"#),
	.vowel: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?vowel\.com/#/g/[^\s]*"#),
	.zhumu: try! NSRegularExpression(pattern: #"https://welink\.zhumu\.com/j/[0-9]+?pwd=[a-zA-Z0-9]+"#),
	.lark: try! NSRegularExpression(pattern: #" https://vc\.larksuite\.com/j/[0-9]+"#),
	.feishu: try! NSRegularExpression(pattern: #"https://vc\.feishu\.cn/j/[0-9]+"#),
	.vimeo: try! NSRegularExpression(pattern: #"https://vimeo\.com/(showcase|event)/[0-9]+|https://venues\.vimeo\.com/[^\s]+"#),
	.ovice: try! NSRegularExpression(pattern: #"https://([a-z0-9-.]+)?ovice\.in/[^\s]*"#),
	.facetime: try! NSRegularExpression(pattern: #"https://facetime\.apple\.com/join[^\s]*"#),
	.chorus: try! NSRegularExpression(pattern: #"https?://go\.chorus\.ai/[^\s]+"#),
	.pop: try! NSRegularExpression(pattern: #"https?://pop\.com/j/[0-9-]+"#),
	.gong: try! NSRegularExpression(pattern: #"https?://([a-z0-9-.]+)?join\.gong\.io/[^\s]+"#),
	.livestorm: try! NSRegularExpression(pattern: #"https?://app\.livestorm\.com/p/[^\s]+"#),
	.luma: try! NSRegularExpression(pattern: #"https://lu\.ma/join/[^\s]*"#),
	.preply: try! NSRegularExpression(pattern: #"https://preply\.com/[^\s]*"#),
	.userzoom: try! NSRegularExpression(pattern: #"https://go\.userzoom\.com/participate/[a-z0-9-]+"#),
	.venue: try! NSRegularExpression(pattern: #"https://app\.venue\.live/app/[^\s]*"#),
	.teemyco: try! NSRegularExpression(pattern: #"https://app\.teemyco\.com/room/[^\s]*"#),
	.demodesk: try! NSRegularExpression(pattern: #"https://demodesk\.com/[^\s]*"#),
	.zoho_cliq: try! NSRegularExpression(pattern: #"https://cliq\.zoho\.eu/meetings/[^\s]*"#),
	.zoomgov: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?zoomgov\.com/j/[a-zA-Z0-9?&=]+"#),
	.skype4biz: try! NSRegularExpression(pattern: #"https?://meet\.lync\.com/[^\s]*"#),
	.skype4biz_selfhosted: try! NSRegularExpression(pattern: #"https?:\/\/(meet|join)\.[^\s]*\/[a-z0-9.]+/meet\/[A-Za-z0-9./]+"#),
	.hangouts: try! NSRegularExpression(pattern: #"https?://hangouts\.google\.com/[^\s]*"#),
	.slack: try! NSRegularExpression(pattern: #"https?://app\.slack\.com/huddle/[A-Za-z0-9./]+"#),
	.reclaim: try! NSRegularExpression(pattern: #"https?://reclaim\.ai/z/[A-Za-z0-9./]+"#),
	.tuple: try! NSRegularExpression(pattern: #"https://tuple\.app/c/[^\s]*"#),
	.gather: try! NSRegularExpression(pattern: #"https?://app.gather.town/app/[A-Za-z0-9]+/[A-Za-z0-9_%\-]+\?(spawnToken|meeting)=[^\s]*"#),
	.pumble: try! NSRegularExpression(pattern: #"https?://meet\.pumble\.com/[a-z-]+"#),
	.suitConference: try! NSRegularExpression(pattern: #"https?://([a-z0-9.]+)?conference\.istesuit\.com/[^\s]*+"#),
	.doxyMe: try! NSRegularExpression(pattern: #"https://([a-z0-9.]+)?doxy\.me/[^\s]*"#),
	.calcom: try! NSRegularExpression(pattern: #"https?://app.cal\.com/video/[A-Za-z0-9./]+"#),
	.zmPage: try! NSRegularExpression(pattern: #"https?://([a-zA-Z0-9.]+)\.zm\.page"#),
	.livekit: try! NSRegularExpression(pattern: #"https?://meet[a-zA-Z0-9.]*\.livekit\.io/rooms/[a-zA-Z0-9-#]+"#),
	.meetecho: try! NSRegularExpression(pattern: #"https?://meetings\.conf\.meetecho\.com/.+"#)
]

func regex(for service: MeetingServices) -> NSRegularExpression? {
	meetingLinkRegexes[service]
}

func detectMeetingLink(_ rawText: String, customRegexes: [String] = []) -> MeetingLink? {
	let text = cleanupOutlookSafeLinks(rawText: rawText)
	
	// Check custom regexes first if provided
	for pattern in customRegexes {
		if let regex = try? NSRegularExpression(pattern: pattern) {
			if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
				let link = String(text[Range(match.range, in: text)!])
				if let url = URL(string: link) {
					return MeetingLink(service: MeetingServices.other, url: url)
				}
			}
		}
	}
	
	// Check built-in meeting service patterns
	if text.contains("://") {
		for (svc, regex) in meetingLinkRegexes {
			if let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
				let url = String(text[Range(match.range, in: text)!])
				return MeetingLink(service: svc, url: URL(string: url)!)
			}
		}
	}
	return nil
}

// Helper function for Outlook safe link cleanup
private func cleanupOutlookSafeLinks(rawText: String) -> String {
	// Remove Outlook safe links wrapper if present
	let safeLinksPattern = #"https://[^/]*safelinks\.protection\.outlook\.com/[^&]*url=([^&]+)"#
	if let regex = try? NSRegularExpression(pattern: safeLinksPattern),
		 let match = regex.firstMatch(in: rawText, range: NSRange(rawText.startIndex..., in: rawText)),
		 let urlRange = Range(match.range(at: 1), in: rawText) {
		let encodedURL = String(rawText[urlRange])
		if let decodedURL = encodedURL.removingPercentEncoding {
			return decodedURL
		}
	}
	return rawText
}

private nonisolated(unsafe) var iconCache: [MeetingServices?: NSImage] = [:]

// Helper to load image from the plugin bundle
private func loadImage(named name: String, size: NSSize = NSSize(width: 16, height: 16)) -> NSImage? {
    // Get the plugin bundle by identifier
    guard let bundle = Bundle(identifier: "com.blacktree.Quicksilver.QSiCalModule") else {
        return nil
    }
    if let image = bundle.image(forResource: name) {
        image.size = size
        return image
    }
    return nil
}

func getIconForMeetingService(_ meetingService: MeetingServices?) -> NSImage {
	if let cached = iconCache[meetingService] {
		return cached
	}
	
	var image = loadImage(named: "no_online_session") ?? NSImage(size: NSSize(width: 16, height: 16))
	switch meetingService {
		// tested and verified
	case .some(.teams):
		image = loadImage(named: "ms_teams_icon") ?? image
		
		// tested and verified
	case .some(.meet), .some(.meetStream):
		image = loadImage(named: "google_meet_icon", size: NSSize(width: 16, height: 13.2)) ?? image
		
		// tested and verified -> deprecated, can be removed because hangouts was replaced by google meet
	case .some(.hangouts):
		image = loadImage(named: "google_hangouts_icon") ?? image
		
		// tested and verified
	case .some(.zoom), .some(.zoomgov), .some(.zoom_native):
		image = loadImage(named: "zoom_icon") ?? image
		
	case .some(.reclaim):
		// reclaim only uses its own links when zoom is involved, so they are always zoom links
		// see https://devforum.zoom.us/t/major-zoom-gcal-sync-problems-recent-behavior-change/80912
		image = loadImage(named: "zoom_icon") ?? image
		
		// tested and verified
	case .some(.webex):
		image = loadImage(named: "webex_icon") ?? image
		
		// tested and verified
	case .some(.jitsi):
		image = loadImage(named: "jitsi_icon") ?? image
		
		// tested and verified
	case .some(.chime):
		image = loadImage(named: "amazon_chime_icon") ?? image
		
		// tested and verified
	case .some(.ringcentral):
		image = loadImage(named: "ringcentral_icon") ?? image
		
		// tested and verified
	case .some(.gotomeeting):
		image = loadImage(named: "gotomeeting_icon") ?? image
		
		// tested and verified
	case .some(.gotowebinar):
		image = loadImage(named: "gotowebinar_icon") ?? image
		
		// tested and verified
	case .some(.bluejeans):
		image = loadImage(named: "bluejeans_icon") ?? image
		
		// tested and verified
	case .some(.eight_x_eight):
		image = loadImage(named: "8x8_icon", size: NSSize(width: 16, height: 8)) ?? image
		
		// tested and verified
	case .some(.demio):
		image = loadImage(named: "demio_icon") ?? image
		
		// tested and verified
	case .some(.join_me):
		image = loadImage(named: "joinme_icon", size: NSSize(width: 16, height: 10)) ?? image
		
		// tested and verified
	case .some(.whereby):
		image = loadImage(named: "whereby_icon", size: NSSize(width: 16, height: 18)) ?? image
		
		// tested and verified
	case .some(.uberconference):
		image = loadImage(named: "uberconference_icon") ?? image
		
		// tested and verified
	case .some(.blizz), .some(.teamviewer_meeting):
		image = loadImage(named: "teamviewer_meeting_icon") ?? image
		
		// tested and verified
	case .some(.vsee):
		image = loadImage(named: "vsee_icon") ?? image
		
		// tested and verified
	case .some(.starleaf):
		image = loadImage(named: "starleaf_icon") ?? image
		
		// tested and verified
	case .some(.duo):
		image = loadImage(named: "google_duo_icon") ?? image
		
		// tested and verified
	case .some(.voov):
		image = loadImage(named: "voov_icon") ?? image
		
		// tested and verified
	case .some(.skype):
		image = loadImage(named: "skype_icon") ?? image
		
		// tested and verified
	case .some(.skype4biz), .some(.skype4biz_selfhosted):
		image = loadImage(named: "skype_business_icon") ?? image
		
		// tested and verified
	case .some(.lifesize):
		image = loadImage(named: "lifesize_icon") ?? image
		
		// tested and verified
	case .some(.facebook_workspace):
		image = loadImage(named: "facebook_workplace_icon") ?? image
		
		// tested and verified
	case .some(.youtube):
		image = loadImage(named: "youtube_icon") ?? image
		
		// tested and verified
	case .some(.coscreen):
		image = loadImage(named: "coscreen_icon") ?? image
		
		// tested and verified
	case .some(.vowel):
		image = loadImage(named: "vowel_icon") ?? image
		
		// tested and verified
	case .some(.zhumu):
		image = loadImage(named: "zhumu_icon") ?? image
		
		// tested and verified
	case .some(.lark):
		image = loadImage(named: "lark_icon") ?? image
		
		// tested and verified
	case .some(.feishu):
		image = loadImage(named: "feishu_icon") ?? image
		
		// tested and verified
	case .some(.vimeo):
		image = loadImage(named: "vimeo_icon") ?? image
		
		// tested and verified
	case .some(.ovice):
		image = loadImage(named: "ovice_icon") ?? image
		
	case .some(.facetime), .some(.facetimeaudio):
		image = loadImage(named: "facetime_icon") ?? image
		
	case .some(.pop):
		image = loadImage(named: "pop_icon") ?? image
		
	case .some(.chorus):
		image = loadImage(named: "chorus_icon") ?? image
		
	case .some(.livestorm):
		image = loadImage(named: "livestorm_icon") ?? image
		
	case .some(.gong):
		image = loadImage(named: "gong_icon") ?? image
		
		// tested and verified
	case .some(.preply):
		image = loadImage(named: "preply_icon") ?? image
		
		// tested and verified
	case .some(.userzoom):
		image = loadImage(named: "userzoom_icon") ?? image
		
		// tested and verified
	case .some(.venue):
		image = loadImage(named: "venue_icon", size: NSSize(width: 16, height: 4)) ?? image
		
		// tested and verified
	case .some(.teemyco):
		image = loadImage(named: "teemyco_icon") ?? image
		
		// tested and verified
	case .some(.demodesk):
		image = loadImage(named: "demodesk_icon") ?? image
		
		// tested and verified
	case .some(.zoho_cliq):
		image = loadImage(named: "zoho_cliq_icon") ?? image
		
		// tested and verified
	case .some(.slack):
		image = loadImage(named: "slack_icon") ?? image
		
	case .some(.tuple):
		image = loadImage(named: "tuple_icon") ?? image
		
	case .some(.pumble):
		image = loadImage(named: "pumble_icon") ?? image
		
	case .some(.suitConference):
		image = loadImage(named: "suit_conference_icon") ?? image
		
	case .some(.doxyMe):
		image = loadImage(named: "doxy_me_icon") ?? image
		
	case .some(.zmPage):
		image = loadImage(named: "zm_page_icon") ?? image
		
	case .some(.livekit):
		image = loadImage(named: "livekit_icon") ?? image
		
	case .some(.meetecho):
		image = loadImage(named: "meetecho_icon") ?? image
		
		// tested and verified
	case .none:
		image = loadImage(named: "no_online_session") ?? image
		
		// tested and verified
	case .some(.vonageMeetings):
		image = loadImage(named: "vonage_icon") ?? image
		
	case .some(.gather):
		image = loadImage(named: "gather_icon") ?? image
		
	case .some(.calcom):
		image = loadImage(named: "calcom_icon") ?? image
		
	case .some(.url):
		if let urlImage = NSImage(named: NSImage.touchBarOpenInBrowserTemplateName) {
			urlImage.size = NSSize(width: 16, height: 16)
			image = urlImage
		}
		
	case .some(.phone):
		if let phoneImage = NSImage(named: NSImage.touchBarCommunicationAudioTemplateName) {
			phoneImage.size = NSSize(width: 16, height: 16)
			image = phoneImage
		}
		
	default:
		break
	}
	
	iconCache[meetingService] = image
	return image
}
