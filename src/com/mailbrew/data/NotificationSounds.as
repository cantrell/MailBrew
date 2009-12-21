package com.mailbrew.data
{
	import mx.collections.ArrayCollection;

	public class NotificationSounds
	{
		[Embed(source="assets/sounds/nice_nav_01.mp3")] public var fluteClass:Class;
		[Embed(source="assets/sounds/nice_nav_02.mp3")] public var transporterClass:Class;
		[Embed(source="assets/sounds/nice_nav_16.mp3")] public var coinClass:Class;
		[Embed(source="assets/sounds/nice_nav_31.mp3")] public var harmonyClass:Class;
		[Embed(source="assets/sounds/alert_01_ascending.mp3")] public var tadaClass:Class;
		
		public var soundData:ArrayCollection;
		private var soundMap:Object;
		
		public function NotificationSounds()
		{
			this.soundData = new ArrayCollection();
			this.soundMap = new Object();

			soundData.addItem({label:"None", soundClass:null});

			soundData.addItem({label:"Flute", soundClass:fluteClass});
			soundMap["Flute"] = fluteClass;

			soundData.addItem({label:"Transporter", soundClass:transporterClass});
			soundMap["Transporter"] = transporterClass;

			soundData.addItem({label:"Coin", soundClass:coinClass});
			soundMap["Coin"] = coinClass;

			soundData.addItem({label:"Harmony", soundClass:harmonyClass});
			soundMap["Harmony"] = harmonyClass;

			soundData.addItem({label:"Ta-da", soundClass:tadaClass});
			soundMap["Ta-da"] = tadaClass;
		}
		
		public function getSound(name:String):Class
		{
			return this.soundMap[name] as Class;
		}
	}
}