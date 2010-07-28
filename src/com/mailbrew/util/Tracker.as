package com.mailbrew.util
{
	import com.google.analytics.GATracker;
	import com.mailbrew.model.ModelLocator;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;

	public class Tracker
	{
		private var gaTracker:GATracker;
		
		public function Tracker()
		{
			var displayObject:DisplayObject = NativeWindow(NativeApplication.nativeApplication.openedWindows[0]).stage;
			this.gaTracker = new GATracker(displayObject, ModelLocator.GA_ACCOUNT, "AS3", ModelLocator.testMode, null, null);
		}
		
		// Page Views
		
		private static const PAGE_INDEX:String       = "/app/index";
		private static const PAGE_NEW_ACCOUNT:String = "/app/new";
		private static const PAGE_DETAILS:String     = "/app/details";
		private static const PAGE_SETTINGS:String    = "/app/settings";
		private static const PAGE_ABOUT:String       = "/app/about";
		
		public function pageViewIndex():void
		{
			this.trackPageview(PAGE_INDEX);
		}
		
		public function pageViewNewAccount():void
		{
			this.trackPageview(PAGE_NEW_ACCOUNT);
		}
		
		public function pageViewDetails():void
		{
			this.trackPageview(PAGE_DETAILS);
		}
		
		public function pageViewSettings():void
		{
			this.trackPageview(PAGE_SETTINGS);
		}
		
		public function pageViewAbout():void
		{
			this.trackPageview(PAGE_ABOUT);
		}

		// Events
		
		private static const CATEGORY_APPLICATION:String = "Application";
		private static const CATEGORY_ACCOUNT:String     = "Account";
		
		// Application Events
		
		private static const EVENT_INSTALL:String        = "install";
		private static const EVENT_LAUNCH:String         = "launch";
		private static const EVENT_CHECK_ALL:String      = "check_all";
		private static const EVENT_SHOW_SUMMARY:String   = "show_summary";
		private static const EVENT_EASTER_EGG:String     = "easter_egg";
		private static const EVENT_MONTHLY_REPORT:String = "monthly_report";
		
		public function eventInstall():void
		{
			this.trackEvent(CATEGORY_APPLICATION, EVENT_INSTALL);
		}
		
		public function eventLaunch():void
		{
			this.trackEvent(CATEGORY_APPLICATION, EVENT_LAUNCH);
		}
		
		public function eventCheckAllNow():void
		{
			this.trackEvent(CATEGORY_APPLICATION, EVENT_CHECK_ALL);
		}
		
		public function eventShowSummary():void
		{
			this.trackEvent(CATEGORY_APPLICATION, EVENT_SHOW_SUMMARY);
		}
		
		public function eventEasterEgg():void
		{
			this.trackEvent(CATEGORY_APPLICATION, EVENT_EASTER_EGG);
		}
		
		public function eventMonthlyReport(imap:uint, gmail:uint, googleWave:uint, googleVoice:uint):void
		{
			this.trackEvent(CATEGORY_APPLICATION, EVENT_MONTHLY_REPORT, "imap", imap);
			this.trackEvent(CATEGORY_APPLICATION, EVENT_MONTHLY_REPORT, "gmail", gmail);
			this.trackEvent(CATEGORY_APPLICATION, EVENT_MONTHLY_REPORT, "googleWave", googleWave);
			this.trackEvent(CATEGORY_APPLICATION, EVENT_MONTHLY_REPORT, "googleVoice", googleVoice);
		}

		// Account Events
		
		private static const EVENT_CHECK:String             = "check";
		private static const EVENT_VERIFY:String            = "verify";
		private static const EVENT_DEMO_NOTIFICATION:String = "demo_notification";
		private static const EVENT_TEST_SOUND:String        = "test_sound";
		private static const EVENT_ADD_ACCOUNT:String       = "add";
		private static const EVENT_EDIT_ACCOUNT:String      = "edit";
		private static const EVENT_DELETE_ACCOUNT:String    = "delete";

		public function eventCheckNow():void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_CHECK);
		}
		
		public function eventVerifyAccount():void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_VERIFY);
		}
		
		public function eventDemoNotification():void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_DEMO_NOTIFICATION);
		}
		
		public function eventTestSound():void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_TEST_SOUND);
		}
		
		public function eventAddAccount(accountType:String):void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_ADD_ACCOUNT, accountType);
		}
		
		public function eventEditAccount(accountType:String):void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_EDIT_ACCOUNT, accountType);
		}
		
		public function eventDeleteAccount(accountType:String):void
		{
			this.trackEvent(CATEGORY_ACCOUNT, EVENT_DELETE_ACCOUNT, accountType);
		}
		
		// Private functions
		
		private function trackPageview(pageURL:String):void
		{
			this.gaTracker.trackPageview(pageURL);
		}
		
		private function trackEvent(category:String, action:String, label:String = null, value:Number = NaN):void
		{
			this.gaTracker.trackEvent(category, action, label, value);
		}
	}
}