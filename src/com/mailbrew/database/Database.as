package com.mailbrew.database
{
	
	import flash.data.*;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.*;
	import flash.system.System;

	public class Database
	{
		private var sql:XML;
		private var dbFile:File;
		public var aConn:SQLConnection;
				
		public function Database(sql:XML)
		{
			this.sql = sql;
		}
		
		public function initialize(responder:DatabaseResponder):void
		{
			this.dbFile = File.applicationStorageDirectory.resolvePath("mailbrew.db");	
			this.aConn = new SQLConnection();
			var listener:Function = function(e:SQLEvent):void
			{
				aConn.removeEventListener(SQLEvent.OPEN, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			
			this.aConn.addEventListener(SQLEvent.OPEN, listener);
			this.aConn.openAsync(dbFile, SQLMode.CREATE);
		}
				
		public function shutdown():void
		{
			if (this.aConn.inTransaction)
			{
				this.aConn.rollback();
			}
			if (this.aConn.connected)
			{
				// Let the runtime close the connection
				//this.aConn.close();
			}
		}

		public function createAccountsTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.create;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			
            stmt.addEventListener(SQLEvent.RESULT, listener);
            stmt.execute();
		}

		public function insertAccount(responder:DatabaseResponder,
									  name:String,
									  accountType:String,
									  username:String,
									  password:String,
									  notificationLocation:String,
									  imapServer:String = null,
									  imapPort:int = -1,
									  secure:Boolean = false):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = name;
            stmt.parameters[":account_type"] = accountType;
            stmt.parameters[":username"] = username;
            stmt.parameters[":password"] = password;
            stmt.parameters[":notification_location"] = notificationLocation;
            stmt.parameters[":imap_server"] = imapServer;
            stmt.parameters[":imapPort"] = imapPort;
            stmt.parameters[":secure"] = secure;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = stmt.getResult().lastInsertRowID;
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
            stmt.execute();
		}

		public function updateAccount(responder:DatabaseResponder,
									  accountId:uint,
									  name:String,
									  accountType:String,
									  username:String,
									  password:String,
									  notificationLocation:String,
									  imapServer:String = null,
									  imapPort:int = -1,
									  secure:Boolean = false):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = name;
            stmt.parameters[":account_type"] = accountType;
            stmt.parameters[":username"] = username;
            stmt.parameters[":password"] = password;
            stmt.parameters[":notification_location"] = notificationLocation;
            stmt.parameters[":imap_server"] = imapServer;
            stmt.parameters[":imapPort"] = imapPort;
            stmt.parameters[":secure"] = secure;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function createMessagesTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.messages.create;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		// Private functions
		
		private function getStatement():SQLStatement
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener(SQLErrorEvent.ERROR,
				function(e:SQLErrorEvent):void
				{
					trace("getStatement SQLError event: ", e);
				}, false, 0, true);
			return stmt;
		}
	}
}