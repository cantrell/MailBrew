package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.events.UpdateAppIconEvent;
	import com.mailbrew.model.ModelLocator;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	public class UpdateAppIconCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var uaie:UpdateAppIconEvent = UpdateAppIconEvent(e);
			var ml:ModelLocator = ModelLocator.getInstance();
			var unreadCountSprite:Sprite = new Sprite();
			unreadCountSprite.width = 128;
			unreadCountSprite.height = 128;
			unreadCountSprite.x = 0;
			unreadCountSprite.y = 0;
			var padding:uint = 10;
			var fontDesc:FontDescription = new FontDescription("Arial", "bold");
			var elementFormat:ElementFormat = new ElementFormat(fontDesc, 30, 0xFFFFFF);
			var textElement:TextElement = new TextElement(String(uaie.unseenCount), elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);
			var textLine:TextLine = textBlock.createTextLine();
			textLine.x = (((128 - textLine.textWidth) - padding) + 2);
			textLine.y = 30;
			unreadCountSprite.graphics.beginFill(0xAA0000);
			unreadCountSprite.graphics.drawEllipse((((128 - textLine.textWidth) - padding) - 3), 0, textLine.textWidth + padding, textLine.textHeight + padding);
			unreadCountSprite.graphics.endFill();
			unreadCountSprite.addChild(textLine);
			var unreadCountData:BitmapData = new BitmapData(128, 128, true, 0x00000000);
			unreadCountData.draw(unreadCountSprite);
			var appData:BitmapData = new ml.DynamicIconClass().bitmapData;
			appData.copyPixels(unreadCountData,
				new Rectangle(0, 0, unreadCountData.width, unreadCountData.height),
				new Point(0, 0),
				null, null, true);
			var appIcon:Bitmap = new Bitmap(appData);
			ml.purr.setIcons([appIcon]);
			// TBD: Set menu
		}
	}
}