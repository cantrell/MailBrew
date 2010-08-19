package com.mailbrew.model
{
	import air.update.ApplicationUpdaterUI;
	
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.model.IModelLocator;
	import com.mailbrew.components.Summary;
	import com.mailbrew.data.AccountInfo;
	import com.mailbrew.data.NotificationSounds;
	import com.mailbrew.database.Database;
	import com.mailbrew.events.CheckMailEvent;
	import com.mailbrew.notify.NotificationManager;
	import com.mailbrew.util.Tracker;
	
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;

	public class ModelLocator
		implements com.adobe.cairngorm.model.IModelLocator
	{
		protected static var inst:ModelLocator;
		
		public static const DEFAULT_FRAME_RATE:uint = 24;
		public static const MAX_NOTIFICATIONS:uint = 10;
		public static const REQUEST_TIMEOUT:uint = 10;  // in seconds
		public static const GA_ACCOUNT:String = "UA-1561219-9";
		[Bindable] public static var testMode:Boolean;
		
		// Buttons
		[Bindable] [Embed(source="assets/buttons/list_add.png")] public var ListAddIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/list_remove.png")] public var ListRemoveIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/configure.png")] public var ConfigureIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/about.png")] public var AboutIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/refresh.png")] public var CheckNowIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/play.png")] public var AudioIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/demo.png")] public var NotificationIconClass:Class;
		
		// Services (small)
		[Bindable] [Embed(source="assets/services/imap_24x24.png")] public var ImapIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/gmail_24x24.png")] public var GmailIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/google_apps_24x24.png")] public var GoogleAppsIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/wave_24x24.png")] public var WaveIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/voice_24x24.png")] public var VoiceIconClassSmall:Class;

		// Services (large)
		[Bindable] [Embed(source="assets/services/imap_50x50.png")] public var ImapIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/gmail_50x50.png")] public var GmailIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/google_apps_50x50.png")] public var GoogleAppsIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/wave_50x50.png")] public var WaveIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/voice_50x50.png")] public var VoiceIconClassLarge:Class;

		// App logos
        [Embed(source="assets/logos/dynamic_logo_128x128.png")] public var Dynamic128IconClass:Class;
		public var dynamicAppIcon:Bitmap;
		[Embed(source="assets/logos/dynamic_logo_16x16.png")] public var Dynamic16IconClass:Class;
		[Bindable] [Embed(source="assets/logos/top_left_24x24.png")] public var TopLeftLogo:Class;

		[Bindable] public var statusMessage:String;
		[Bindable] public var showStatusProgressBar:Boolean;
		[Bindable] public var accounts:ArrayCollection;
		[Bindable] public var accountInfo:AccountInfo;
		[Bindable] public var mainAppView:String;
		[Bindable] public var checkEmailLock:Boolean;
		[Bindable] public var reorderAccountsLock:Boolean;
		[Bindable] public var frameRate:uint;
		[Bindable] public var mainAppWindowVisible:Boolean;
		[Bindable] public var prefs:Preference;
		public var notificationManager:NotificationManager;
		public var checkEmailTimer:Timer;
		public var db:Database;
		public var notificationSounds:NotificationSounds = new NotificationSounds();
		public var summaryWindow:Summary;
		public var appUpdater:ApplicationUpdaterUI;
		public var tracker:Tracker;

		public function checkEmail(e:TimerEvent):void
		{
			new CheckMailEvent().dispatch();
		}
		
		public function ModelLocator()
		{
		}
		
		public static function getInstance():ModelLocator
		{
			if (inst == null)
			{
				inst = new ModelLocator();
			}
			return inst;
		}

	}
}
