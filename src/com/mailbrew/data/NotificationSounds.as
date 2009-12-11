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
			this.soundData.addItem({label:"None", soundClass:null});
			this.soundData.addItem({label:"Four", soundClass:fourSoundClass});
		}
	}
}