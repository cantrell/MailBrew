package com.mailbrew.notify
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.utils.Timer;
	
	[Event(name=NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT, type="com.adobe.air.notification.NotificationClickedEvent")]
	
	public class Notification 
		extends NativeWindow
	{
		public static const TOP_LEFT:String     = "topLeft";
		public static const TOP_RIGHT:String    = "topRight";
		public static const BOTTOM_LEFT:String  = "bottomLeft";
		public static const BOTTOM_RIGHT:String = "bottomRight";
		
		private var duration:uint;
		private var pos:String;
		private var message:String;        
		private var subject:String;
		private var icon:Bitmap;
		private var frameRate:uint;
		private var timer:Timer;
		private var timerListener:Function;
		private var sprite:Sprite;
		private var manager:NotificationManager;
		private var closeTime:uint = 25;
		
		private var LEADING:Number = 1.25;
		private var MAX_TEXT_LINES:uint = 10;
		private static var filters:Array;
		
		public function Notification(subject:String, message:String, position:String, duration:uint, iconClass:Class, frameRate:uint = 24)
		{
			var winOptions: NativeWindowInitOptions = new NativeWindowInitOptions();
			winOptions.maximizable = false;
			winOptions.minimizable = false;
			winOptions.resizable = false;
			winOptions.transparent = true;
			winOptions.systemChrome = NativeWindowSystemChrome.NONE;
			winOptions.type = NativeWindowType.LIGHTWEIGHT;

			super(winOptions);
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			
			this.visible = false;
			
			this.pos = position;
			this.duration = duration;
			this.subject = subject;
			this.message = message;
			this.icon = new iconClass();
			this.frameRate = frameRate;
			
			if (filters == null)
			{
				filters = [new DropShadowFilter(3, 45, 0x000000, .5)];
			}
			
			this.width = 350;
			
			this.draw();
		}
		
		protected function getSprite(): Sprite
		{
			if (this.sprite == null)
			{
				this.sprite = new Sprite();
				this.sprite.alpha = 0;
				this.stage.addChild(this.sprite);
				this.sprite.addEventListener(MouseEvent.CLICK, this.notificationClick);
			}
			return this.sprite;
		}
		
		private function drawBackGround(): void
		{
			this.getSprite().graphics.clear();
			this.getSprite().graphics.beginFill(0x333333);
			this.getSprite().graphics.drawRoundRect(0, 0, (this.width - 4), (this.height - 4), 30, 30);
			this.getSprite().graphics.endFill();
			this.getSprite().filters = filters;
		}

		private function draw():void
		{
			var closeButton:CloseButton = new CloseButton();
			closeButton.x = 2;
			closeButton.y = 2;
			closeButton.addEventListener(MouseEvent.CLICK, this.onCloseButtonClick);
			this.getSprite().addChild(closeButton);
			
			var leftPos:int = 62;
			
			// subject
			var subjectFontDesc:FontDescription = new FontDescription("Verdana", "bold");
			var subjectElementFormat:ElementFormat = new ElementFormat(subjectFontDesc, 12, 0xffffff);
			var subjectTextElement:TextElement = new TextElement(this.subject, subjectElementFormat);
			var subjectTextBlock:TextBlock = new TextBlock(subjectTextElement);
			var subjectTextLine:TextLine = subjectTextBlock.createTextLine();
			subjectTextLine.x = leftPos;
			subjectTextLine.y = 15;
			this.getSprite().addChild(subjectTextLine);
			
			// message
			var messageFontDesc:FontDescription = new FontDescription("Verdana", "normal");
			var messageElementFormat:ElementFormat = new ElementFormat(messageFontDesc, 12, 0xffffff);
			var messageTextElement:TextElement = new TextElement(this.message, messageElementFormat);
			var messageTextBlock:TextBlock = new TextBlock(messageTextElement);
			var yPos:Number = 32;
			var textLine:TextLine;
			var linesAdded:uint = 0;
			var messageTextHeight:uint = 0;
			while (textLine = messageTextBlock.createTextLine(textLine, width - 70, 0, true))
			{
				textLine.x = leftPos;
				textLine.y = yPos;
				yPos += LEADING * textLine.height;
				this.getSprite().addChild(textLine);
				messageTextHeight += (textLine.textHeight * LEADING);
				if (++linesAdded == MAX_TEXT_LINES) break;
			}
			
			var workingHeight:uint = (messageTextHeight + subjectTextLine.textHeight) + 24;
			if (workingHeight < 80)
			{
				this.height = 80;
			}
			else
			{
				this.height = workingHeight;
			}

			this.drawBackGround();

			// icon
			this.icon.x = 6;
			this.icon.y = (this.height / 2) - 25;
			this.getSprite().addChild(this.icon);
		}
		
		internal function set index(index:uint):void
		{
			var indexFontDesc:FontDescription = new FontDescription("Verdana", "normal");
			var indexElementFormat:ElementFormat = new ElementFormat(indexFontDesc, 10, 0xffffff);
			var indexTextElement:TextElement = new TextElement("#" + (index + 1), indexElementFormat);
			var indexTextBlock:TextBlock = new TextBlock(indexTextElement);
			var indexTextLine:TextLine = indexTextBlock.createTextLine();
			indexTextLine.x = (this.icon.x + 25) - (indexTextLine.textWidth / 2);
			indexTextLine.y = (this.icon.y + 50) + 4;
			this.getSprite().addChild(indexTextLine);
		}
		
		private function onCloseButtonClick(event:MouseEvent):void
		{
			var sprite:Sprite = event.currentTarget as Sprite;
			sprite.removeEventListener(MouseEvent.CLICK, this.onCloseButtonClick);
			if (this.manager != null)
			{
				this.manager.clear(this.pos);
			}
		}
		
		private function superClose():void
		{
			this.destroy();
			super.close();
		}
		
		override public function close(): void
		{
			this.frameRateCheck();
			this.cleanUpTimer();
			this.timer = new Timer(this.closeTime);
			this.timerListener = function (e:TimerEvent):void
			{
				timer.stop();
				var nAlpha:Number = getSprite().alpha;
				nAlpha = nAlpha - .01;
				getSprite().alpha = nAlpha;
				if (getSprite().alpha <= 0)
				{
					cleanUpTimer();
					superClose();
				}
				else 
				{
					timer.start();
				}
			};
			this.timer.addEventListener(TimerEvent.TIMER, this.timerListener);
			this.timer.start();
		}
		
		internal function closeNow():void
		{
			this.superClose();
		}
		
		internal function destroy():void
		{
			this.cleanUpTimer();
			this.pos = null;
			this.message = null;        
			this.subject = null;
			this.icon = null;
			this.sprite = null;
			this.manager = null;
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value)
			{
				this.frameRateCheck();
				this.cleanUpTimer();
				this.timer = new Timer(10);
				this.timerListener = function (e:TimerEvent):void
				{
					timer.stop();
					var nAlpha:Number = getSprite().alpha;
					nAlpha = nAlpha + .01;
					getSprite().alpha = nAlpha;
					if (getSprite().alpha < .9)
					{
						timer.start();
					}
					else
					{
						cleanUpTimer();
						startClose();
					}
				};
				this.timer.addEventListener(TimerEvent.TIMER, this.timerListener);
				this.timer.start();
			}
		}
		
		private function startClose():void
		{
			this.cleanUpTimer();
			this.timer = new Timer(this.duration * 1000);
			this.timerListener = function(e:TimerEvent):void
			{
				cleanUpTimer();
				close();
			};
			this.timer.addEventListener(TimerEvent.TIMER, this.timerListener); 
			this.timer.start();
		}
				
		private function notificationClick(event:MouseEvent):void
		{
			var sprite:Sprite = event.currentTarget as Sprite;
			sprite.removeEventListener(MouseEvent.CLICK, this.notificationClick);
			this.dispatchEvent(new NotificationClickedEvent());
			this.closeTime = 5;
			this.close();
		}
		
		internal function get position():String
		{
			return this.pos;
		}

		internal function set notificationManager(manager:NotificationManager):void
		{
			this.manager = manager;
		}
		
		private function cleanUpTimer():void
		{
			if (this.timer != null)
			{
				this.timer.stop();
				this.timer.removeEventListener(TimerEvent.TIMER, this.timerListener);
				this.timer = null;
			}
		}
		
		private function frameRateCheck():void
		{
			if (this.stage.frameRate != this.frameRate)
			{
				this.stage.frameRate = frameRate;
			}
			
		}
	}
}