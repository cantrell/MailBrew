package com.mailbrew.commands
{
	import com.adobe.air.notification.Purr;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.CheckMailEvent;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.model.ModelLocator;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class InitCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var ml:ModelLocator = ModelLocator.getInstance();
			
			ml.purr = new Purr(10);
			
			ml.notificationIcon = new ml.NotificationIconClass();
			
			var sqlFile:File = File.applicationDirectory.resolvePath("sql.xml");
			var sqlFileStream:FileStream = new FileStream();
			sqlFileStream.open(sqlFile, FileMode.READ);
			var sql:XML = new XML(sqlFileStream.readUTFBytes(sqlFileStream.bytesAvailable));
			sqlFileStream.close();
			var db:Database = new Database(sql);
			var responder:DatabaseResponder = new DatabaseResponder();
			var resultListener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, resultListener);
				ml.db = db;
				createAccountsTable();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, resultListener);
			db.initialize(responder);
		}
		
		private function createAccountsTable():void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, createMessagesTable);
			ModelLocator.getInstance().db.createAccountsTable(responder);			
		}
		
		private function createMessagesTable(e:Event):void
		{
			var oldResponder:DatabaseResponder = e.target as DatabaseResponder;
			oldResponder.removeEventListener(DatabaseEvent.RESULT_EVENT, createMessagesTable);
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, start);
			ModelLocator.getInstance().db.createMessagesTable(responder);			
		}
		
		private function start(e:Event):void
		{
			var oldResponder:DatabaseResponder = e.target as DatabaseResponder;
			oldResponder.removeEventListener(DatabaseEvent.RESULT_EVENT, start);
			new PopulateAccountListEvent().dispatch();
			//new CheckMailEvent().dispatch();
		}
	}
}
