package com.mailbrew.data
{
	import mx.collections.ArrayCollection;

	public class NotificationSounds
	{
		[Embed(source="assets/sounds/four.mp3")] public var fourSoundClass:Class;
		
		public var soundData:ArrayCollection;
		
		public function NotificationSounds()
		{
			this.soundData = new ArrayCollection();
			soundData.addItem({label:"None", soundClass:null});
			soundData.addItem({label:"Four", soundClass:fourSoundClass});
		}
	}
}