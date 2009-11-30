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

		// Accounts
		
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
									  imapServer:String,
									  imapPort:Number,
									  secure:Boolean,
									  notificationLocation:String,
									  sound:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.insert;
            stmt.parameters[":name"] = name;
            stmt.parameters[":account_type"] = accountType;
            stmt.parameters[":username"] = username;
            stmt.parameters[":password"] = password;
            stmt.parameters[":notification_location"] = notificationLocation;
            stmt.parameters[":sound"] = sound;
            stmt.parameters[":imap_server"] = imapServer;
            stmt.parameters[":port_number"] = imapPort;
            stmt.parameters[":secure"] = secure;
            stmt.parameters[":working"] = true;
            stmt.parameters[":working_reason"] = null;
            stmt.parameters[":last_checked"] = null;
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
									  accountId:Number,
									  name:String,
									  accountType:String,
									  username:String,
									  password:String,
									  imapServer:String,
									  imapPort:Number,
									  secure:Boolean,
									  notificationLocation:String,
									  sound:String):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.update;
            stmt.parameters[":account_id"] = accountId;
            stmt.parameters[":name"] = name;
            stmt.parameters[":account_type"] = accountType;
            stmt.parameters[":username"] = username;
            stmt.parameters[":password"] = password;
            stmt.parameters[":notification_location"] = notificationLocation;
            stmt.parameters[":sound"] = sound;
            stmt.parameters[":imap_server"] = imapServer;
            stmt.parameters[":port_number"] = imapPort;
            stmt.parameters[":secure"] = secure;
            stmt.parameters[":working"] = true;
            stmt.parameters[":working_reason"] = null;
            stmt.parameters[":last_checked"] = null;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function updateLastChecked(responder:DatabaseResponder,
									  	  accountId:Number,
									      working:Boolean,
										  workingReason:String,
										  lastChecked:Date):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.updateLastChecked;
            stmt.parameters[":account_id"] = accountId;
            stmt.parameters[":working"] = working;
            stmt.parameters[":working_reason"] = workingReason;
            stmt.parameters[":last_checked"] = lastChecked;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function deleteAccountById(responder:DatabaseResponder,
									      accountId:uint):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.deleteById;
            stmt.parameters[":account_id"] = accountId;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function getAccountLabels(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.accounts.selectIdAndName;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = stmt.getResult().data;
				responder.dispatchEvent(dbe);
			}
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function getAccounts(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.accounts.selectAll;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = stmt.getResult().data;
				responder.dispatchEvent(dbe);
			}
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function getAccountById(responder:DatabaseResponder, accountId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.accounts.selectById;
			stmt.parameters[":account_id"] = accountId;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = stmt.getResult().data[0];
				responder.dispatchEvent(dbe);
			}
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		// Messages
		
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

		public function deleteMessagesByAccountId(responder:DatabaseResponder,
										          accountId:uint):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.messages.deleteByAccountId;
			stmt.parameters[":account_id"] = accountId;
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