package com.mailbrew.notify
{
	import flash.desktop.DockIcon;
	import flash.desktop.InteractiveIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class NotificationManager
	{
		private var topLeftQ:NotificationQueue;
		private var topRightQ:NotificationQueue;
		private var bottomLeftQ:NotificationQueue;
		private var bottomRightQ:NotificationQueue;
		private var paused:Boolean;
		
		public function NotificationManager(idleThreshold:int = -1)
		{
			this.topLeftQ = new NotificationQueue();
			this.topRightQ = new NotificationQueue();
			this.bottomLeftQ = new NotificationQueue();
			this.bottomRightQ = new NotificationQueue();
			
			this.paused = false;
			
			if (idleThreshold == -1) idleThreshold = 10;
			
			NativeApplication.nativeApplication.idleThreshold = idleThreshold * 60;
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, function(e: Event): void { pause(); });
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, function(e: Event): void { resume(); });
		}
		
		public function alert(alertType:String, nativeWindow:NativeWindow):void
		{
			if (NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).bounce(alertType);
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				if (nativeWindow != null)
				{
					nativeWindow.notifyUser(alertType);
				}
			}
		}
		
		public function setIdleThreshold(idle:int):void
		{
			NativeApplication.nativeApplication.idleThreshold = idle * 60;
		}
		
		public function addNotification(n:Notification):void
		{
			n.notificationManager = this;
			switch (n.position)
			{
				case Notification.TOP_LEFT:
					this.topLeftQ.addNotification(n);
					break;
				case Notification.TOP_RIGHT:
					this.topRightQ.addNotification(n);
					break;
				case Notification.BOTTOM_LEFT:
					this.bottomLeftQ.addNotification(n);
					break;
				case Notification.BOTTOM_RIGHT:
					this.bottomRightQ.addNotification(n);
					break;
			}			
		}
		
		public function setMenu(menu:NativeMenu): void
		{
			if (NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
		}
		
		public function getMenu():NativeMenu
		{
			if (NativeApplication.supportsDockIcon)
			{
				return DockIcon(NativeApplication.nativeApplication.icon).menu;
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).menu;
			}
			return null;
		}
		
		public function setIcons(icons:Array, tooltip:String = null):void
		{
			if (NativeApplication.nativeApplication.icon is InteractiveIcon)
			{
				InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps = icons;
			}
			if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = tooltip;
			}
		}
		
		public function getIcons():Array
		{
			if (NativeApplication.nativeApplication.icon is InteractiveIcon)
			{
				return InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps;
			}
			return null;
		}
		
		public function getToolTip():String
		{
			if (NativeApplication.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip;
			}
			return null;
		}
		
		public function clear(where:String = null): void
		{
			switch (where)
			{
				case Notification.TOP_LEFT || null:
					this.topLeftQ.clear();
				case Notification.TOP_RIGHT || null:
					this.topRightQ.clear();
				case Notification.BOTTOM_LEFT || null:
					this.bottomLeftQ.clear();
				case Notification.BOTTOM_RIGHT || null:
					this.bottomRightQ.clear();
			}
		}
		
		public function pause():void
		{
			this.topLeftQ.pause();
			this.topRightQ.pause();
			this.bottomLeftQ.pause();
			this.bottomRightQ.pause();
			this.paused = true;
		}
		
		public function resume():void
		{
			this.topLeftQ.resume();
			this.topRightQ.resume();
			this.bottomLeftQ.resume();
			this.bottomRightQ.resume();
			this.paused = false;
		}
		
		public function isPaused():Boolean
		{
			return this.paused;
		}
		
		public function get length():uint
		{
			return (this.topLeftQ.length + this.topRightQ.length + this.bottomLeftQ.length + this.bottomRightQ.length);
		}
	}
}