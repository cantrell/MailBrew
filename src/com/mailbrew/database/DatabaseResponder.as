package com.mailbrew.database
{
	import flash.events.EventDispatcher;

	[Event(name="errorEvent",  type="com.mailbrew.DatabaseEvent")]
	[Event(name="resultEvent", type="com.mailbrew.DatabaseEvent")]

	public class DatabaseResponder
		extends EventDispatcher
	{
	}
}