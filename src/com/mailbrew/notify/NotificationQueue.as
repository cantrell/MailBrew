package com.mailbrew.notify
{           
	import flash.display.Screen;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.system.System;
	
	public class NotificationQueue
	{
		
		private var queue:Array;
		private var playing:Boolean;
		private var paused:Boolean;
		
		public function NotificationQueue()
		{
			this.queue = new Array();
			this.playing = false;
			this.paused = false;
		}
		
		public function get length():uint
		{
			return this.queue.length;
		}
		
		public function addNotification(notification:Notification):void
		{
			this.queue.push(notification);
			if (this.queue.length == 1 && !this.playing)
			{
				this.playing = true;
				this.run();
			}
		}
		
		public function clear(): void
		{
			while (this.queue.length > 0)
			{
				var n: Notification = this.queue.shift() as Notification;
				n.closeNow();
				n.destroy();
				n = null;
			}
			if (this.playing)
			{
				this.playing = false;
			}
		}
		
		public function pause():void
		{
			this.paused = true;
		}
		
		public function resume():void
		{
			this.paused = false;
			this.run();
		}
		
		private function run(): void
		{
			if (this.paused || this.queue.length == 0) return;
			var n:Notification = this.queue.shift() as Notification;
			var listener:Function = function(e: Event): void
			{
				n.removeEventListener(Event.CLOSE, listener);
				if (queue.length > 0)
				{
					run();
				}
				else
				{
					playing = false;
				}
			}; 
			n.addEventListener(Event.CLOSE, listener);
			var screen:Screen = Screen.mainScreen;
			switch (n.position)
			{
				case Notification.TOP_LEFT:
					n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.y + 3, n.width, n.height);
					break;
				case Notification.TOP_RIGHT:
					n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2), screen.visibleBounds.y + 3, n.width, n.height);
					break;
				case Notification.BOTTOM_LEFT:
					n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.height - (n.height + 2), n.width, n.height);
					break;
				case Notification.BOTTOM_RIGHT:
					n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2) , screen.visibleBounds.height - (n.height + 2), n.width, n.height);
					break;
			}
			n.alwaysInFront = true;
			n.visible = true;
		}
	}
}
