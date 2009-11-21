package com.mailbrew.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	
	import flash.display.Bitmap;

	public class ModelLocator
		implements com.adobe.cairngorm.model.IModelLocator
	{
		protected static var inst:ModelLocator;
		
        [Embed(source="assets/dynamic_logo_128.png")]
        public var dynamicIconClass:Class;
		public var dynamicAppIcon:Bitmap;

		[Bindable] public var statusMessage:String;
		[Bindable] public var showStatusProgressBar:Boolean;

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
