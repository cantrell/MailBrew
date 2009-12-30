package com.mailbrew.notify
{
	import flash.events.Event;
	
	public class NotificationClickedEvent extends Event
	{
		public static const NOTIFICATION_CLICKED_EVENT:String = "notificationClickedEvent";
		
		public function NotificationClickedEvent() 
		{
			super(NOTIFICATION_CLICKED_EVENT);
		}
	}
}