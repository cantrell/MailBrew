package com.mailbrew.model
{
	import com.adobe.cairngorm.model.IModelLocator;
	import com.mailbrew.data.AccountInfo;
	import com.mailbrew.data.MainAppViews;
	import com.mailbrew.database.Database;
	
	import flash.display.Bitmap;
	
	import mx.collections.ArrayCollection;

	public class ModelLocator
		implements com.adobe.cairngorm.model.IModelLocator
	{
		protected static var inst:ModelLocator;
		
		[Bindable] [Embed(source="assets/list-add.png")] public var listAddClass:Class;
		[Bindable] [Embed(source="assets/list-remove.png")] public var listRemoveClass:Class;
		
        [Embed(source="assets/dynamic_logo_128.png")]
        public var dynamicIconClass:Class;
		public var dynamicAppIcon:Bitmap;

		[Bindable] public var statusMessage:String;
		[Bindable] public var showStatusProgressBar:Boolean;
		[Bindable] public var accounts:ArrayCollection;
		[Bindable] public var mainAppView:String;
		[Bindable] public var accountFormView:String;
		[Bindable] public var accountInfo:AccountInfo;
		[Bindable] public var checkEmailLock:Boolean;
		
		public var db:Database;

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
