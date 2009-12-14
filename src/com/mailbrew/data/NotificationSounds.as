package com.mailbrew.data
{
	import mx.collections.ArrayCollection;

	public class NotificationSounds
	{
		[Embed(source="assets/sounds/nice_nav_01.mp3")] public var fluteClass:Class;
		[Embed(source="assets/sounds/nice_nav_02.mp3")] public var transporterClass:Class;
		
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
		}
		
		public function getSound(name:String):Class
		{
			return this.soundMap[name] as Class;
		}
	}
}