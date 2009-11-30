package com.mailbrew.email
{
	public interface IEmailService
	{
		function testAccount():void;
		function getUnseenEmailCount():void;
		function getUnseenEmailHeaders():void;
		function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
}