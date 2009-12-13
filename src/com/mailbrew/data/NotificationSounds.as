package com.mailbrew.data
{
	import mx.collections.ArrayCollection;

	public class NotificationSounds
	{
		[Embed(source="assets/sounds/four.mp3")] public var fourSoundClass:Class;
		
		public var soundData:ArrayCollection;
		private var soundMap:Object;
		
		public function NotificationSounds()
		{
			this.soundData = new ArrayCollection();
			this.soundMap = new Object();

			soundData.addItem({label:"None", soundClass:null});

			soundData.addItem({label:"Four", soundClass:fourSoundClass});
			soundMap["Four"] = fourSoundClass;
		}
		
		public function getSound(name:String):Class
		{
			return this.soundMap[name] as Class;
		}
	}
}