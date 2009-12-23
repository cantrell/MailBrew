package com.mailbrew.model
{
	import com.adobe.air.notification.Purr;
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.model.IModelLocator;
	import com.mailbrew.data.AccountInfo;
	import com.mailbrew.data.NotificationSounds;
	import com.mailbrew.database.Database;
	import com.mailbrew.events.CheckMailEvent;
	
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;

	public class ModelLocator
		implements com.adobe.cairngorm.model.IModelLocator
	{
		protected static var inst:ModelLocator;
		
		public static const DEFAULT_FRAME_RATE:uint = 24;
		
		// Buttons
		[Bindable] [Embed(source="assets/buttons/list_add.png")] public var listAddIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/list_remove.png")] public var listRemoveIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/configure.png")] public var configureIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/about.png")] public var aboutIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/refresh.png")] public var checkNowIconClass:Class;
		[Bindable] [Embed(source="assets/buttons/play.png")] public var audioIconClass:Class;
		
		// Services (small)
		[Bindable] [Embed(source="assets/services/imap_24x24.png")] public var ImapIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/gmail_24x24.png")] public var GmailIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/wave_24x24.png")] public var WaveIconClassSmall:Class;
		[Bindable] [Embed(source="assets/services/voice_24x24.png")] public var VoiceIconClassSmall:Class;

		// Services (large)
		[Bindable] [Embed(source="assets/services/imap_64x64.png")] public var ImapIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/gmail_64x64.png")] public var GmailIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/wave_64x64.png")] public var WaveIconClassLarge:Class;
		[Bindable] [Embed(source="assets/services/voice_64x64.png")] public var VoiceIconClassLarge:Class;

		public var imapIconBitmapLarge:Bitmap;		
		public var gmailIconBitmapLarge:Bitmap;		
		public var waveIconBitmapLarge:Bitmap;		
		public var voiceIconBitmapLarge:Bitmap;		
		
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
		[Bindable] public var frameRate:uint;
		public var purr:Purr;
		public var prefs:Preference;
		public var checkEmailTimer:Timer;
		public var db:Database;
		public var notificationSounds:NotificationSounds = new NotificationSounds();

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
