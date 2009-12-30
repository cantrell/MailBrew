package com.mailbrew.notify
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class CloseButton extends Sprite
	{
		public function CloseButton()
		{
			this.drawControls(0xffffff, 0x000000);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			this.drawControls(0x000000, 0xffffff);
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			this.drawControls(0xffffff, 0x000000);
		}
		
		private function drawControls(background:uint, foreground:uint):void
		{
			this.graphics.clear();
			
			// Circle
			this.graphics.beginFill(background, .5);
			this.graphics.drawCircle(8, 8, 5);
			this.graphics.endFill();
			
			// Draw the "x"
			this.graphics.lineStyle(2, foreground, .5);
			this.graphics.moveTo(10, 6);
			this.graphics.lineTo(6, 10);
			this.graphics.moveTo(6, 6);
			this.graphics.lineTo(10, 10);
		}
	}
}