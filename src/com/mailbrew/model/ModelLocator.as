package com.mailbrew.model
{
	import com.adobe.air.notification.Purr;
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.model.IModelLocator;
	import com.mailbrew.data.AccountInfo;
	import com.mailbrew.data.MainAppViews;
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
		
		[Bindable] [Embed(source="assets/list-add.png")] public var listAddIconClass:Class;
		[Bindable] [Embed(source="assets/list-remove.png")] public var listRemoveIconClass:Class;
		[Bindable] [Embed(source="assets/face-smile.png")] public var faceSmileIconClass:Class;
		[Bindable] [Embed(source="assets/face-crying.png")] public var faceCryingIconClass:Class;
		[Bindable] [Embed(source="assets/face-surprise.png")] public var faceSurpriseIconClass:Class;
		[Bindable] [Embed(source="assets/emblem-system.png")] public var configureIconClass:Class;
		[Bindable] [Embed(source="assets/help-browser.png")] public var aboutIconClass:Class;
		[Bindable] [Embed(source="assets/view-refresh.png")] public var checkNowIconClass:Class;
		[Bindable] [Embed(source="assets/audio-x-generic.png")] public var audioIconClass:Class;
		
        [Embed(source="assets/dynamic_logo_128.png")]
        public var DynamicIconClass:Class;
		public var dynamicAppIcon:Bitmap;
		
		[Embed(source="assets/notification_icon.png")]
		public var NotificationIconClass:Class;
		public var notificationIcon:Bitmap;

		[Bindable] public var statusMessage:String;
		[Bindable] public var showStatusProgressBar:Boolean;
		[Bindable] public var accounts:ArrayCollection;
		[Bindable] public var accountInfo:AccountInfo;
		[Bindable] public var mainAppView:String;

		public var checkEmailLock:Boolean;
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
