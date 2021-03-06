package com.mailbrew.database
{
	
	import flash.data.*;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.*;
	import flash.utils.ByteArray;

	public class Database
	{
		private var sql:XML;
		private var dbFile:File;
		public var aConn:SQLConnection;
		public var encryptionKey:ByteArray;
				
		public function Database(sql:XML, encryptionKey:ByteArray)
		{
			this.sql = sql;
			this.encryptionKey = encryptionKey;
		}
		
		public function initialize(responder:DatabaseResponder):void
		{
			this.dbFile = File.applicationStorageDirectory.resolvePath("mailbrew.db");	
			this.aConn = new SQLConnection();
			var listener:Function = function(e:SQLEvent):void
			{
				aConn.removeEventListener(SQLEvent.OPEN, listener);
				aConn.removeEventListener(SQLErrorEvent.ERROR, errorListener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			
			var errorListener:Function = function(ee:SQLErrorEvent):void
			{
				aConn.removeEventListener(SQLEvent.OPEN, listener);
				aConn.removeEventListener(SQLErrorEvent.ERROR, errorListener);
				dbFile.deleteFile();
				initialize(responder);
			};
			
			this.aConn.addEventListener(SQLEvent.OPEN, listener);
			this.aConn.addEventListener(SQLErrorEvent.ERROR, errorListener);
			this.aConn.openAsync(dbFile, SQLMode.CREATE, null, false, 1024, this.encryptionKey);
		}
				
		public function shutdown():void
		{
			if (this.aConn.inTransaction)
			{
				this.aConn.rollback();
			}
			if (this.aConn.connected)
			{
				// Best to let the runtime close the connection.
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

		public function dropAccountsTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.drop;
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
									  notificationSound:String,
									  active:Boolean):void
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
            stmt.parameters[":notification_sound"] = notificationSound;
            stmt.parameters[":imap_server"] = imapServer;
            stmt.parameters[":port_number"] = imapPort;
            stmt.parameters[":secure"] = secure;
            stmt.parameters[":working"] = true;
            stmt.parameters[":working_reason"] = null;
            stmt.parameters[":last_checked"] = null;
            stmt.parameters[":active"] = active;
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
									  notificationSound:String,
									  active:Boolean):void
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
            stmt.parameters[":notification_sound"] = notificationSound;
            stmt.parameters[":imap_server"] = imapServer;
            stmt.parameters[":port_number"] = imapPort;
            stmt.parameters[":secure"] = secure;
            stmt.parameters[":working"] = true;
            stmt.parameters[":working_reason"] = null;
            stmt.parameters[":last_checked"] = null;
            stmt.parameters[":active"] = active;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = accountId;
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
				dbe.data = accountId;
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function updateSortOrder(responder:DatabaseResponder,
									  	accountId:Number,
									    sortOrder:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.accounts.updateSortOrder;
            stmt.parameters[":account_id"] = accountId;
            stmt.parameters[":sort_order"] = sortOrder;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = accountId;
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
				dbe.data = accountId;
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
			stmt.text = this.sql.accounts.selectForList;
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

		/**
		 * Unfortunately I have to build the SQL string my hand rather than
		 * using a prepared statement because prepared statements are not
		 * compatible with SELECT IN statements. You would never do this on
		 * the web, but on the desktop, I think I can get away wit it.
		 **/
		public function getAccountsByIds(responder:DatabaseResponder, accountIds:Array):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			var sql:String = "SELECT * FROM accounts WHERE id IN (" + accountIds.toString() + ")";
			stmt.text = sql;
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

		public function getErrorMessage(responder:DatabaseResponder, accountId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.accounts.selectWorkingReason;
			stmt.parameters[":account_id"] = accountId;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				dbe.data = stmt.getResult().data[0].working_reason;
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

		public function dropMessagesTable(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.messages.drop;
			var listener:Function = function(e:SQLEvent):void
			{
				stmt.removeEventListener(SQLEvent.RESULT, listener);
				var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				responder.dispatchEvent(dbe);
			};
			stmt.addEventListener(SQLEvent.RESULT, listener);
			stmt.execute();
		}

		public function getMessageUniqueIdsByAccountId(responder:DatabaseResponder,
											   		   accountId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.messages.selectUniqueIdsByAccountId;
			stmt.parameters[":account_id"] = accountId;
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

		public function getMessagesByAccountId(responder:DatabaseResponder,
											   accountId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.messages.selectMessagesByAccountId;
			stmt.parameters[":account_id"] = accountId;
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

		public function insertUnseenMessage(responder:DatabaseResponder,
										    accountId:Number,
											uniqueId:String,
											sender:String,
											summary:String = null,
											url:String = null):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
			stmt.text = this.sql.messages.insert;
			stmt.parameters[":account_id"] = accountId;
			stmt.parameters[":unique_id"] = uniqueId;
			stmt.parameters[":sender"] = sender;
			stmt.parameters[":summary"] = summary;
			stmt.parameters[":url"] = url;
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