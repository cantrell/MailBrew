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
			this.aConn.addEventListener(SQLEvent.OPEN,
				function(e:SQLEvent):void
				{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
				});
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
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		/*
		public function insertFeed(responder:DatabaseResponder, feedUrl:String, feed:IFeed, parent:int = -1):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.insert;
            stmt.parameters[":name"] = (feed.metadata.title != null) ? feed.metadata.title : feedUrl;
            stmt.parameters[":description"] = feed.metadata.description;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.parameters[":site_url"] = feed.metadata.link;
            stmt.parameters[":sort_order"] = -1;
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 1;
            stmt.parameters[":error_message"] = null;
            stmt.parameters[":is_folder"] = false;
            stmt.parameters[":parent"] = parent;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().lastInsertRowID;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function updateFeed(responder:DatabaseResponder, feedId:Number, feedUrl:String, feed:IFeed):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.update;
            stmt.parameters[":name"] = (feed.metadata.title != null) ? feed.metadata.title : feedUrl;
            stmt.parameters[":description"] = feed.metadata.description;
            stmt.parameters[":icon"] = null;
            stmt.parameters[":feed_url"] = feedUrl;
            stmt.parameters[":site_url"] = feed.metadata.link;            
            stmt.parameters[":etag"] = null;
            stmt.parameters[":last_updated"] = new Date();
            stmt.parameters[":parsable"] = 1;
            stmt.parameters[":error_message"] = null;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function deleteFeedById(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.deleteByFeedId;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		
		public function getFeedInfoById(responder:DatabaseResponder, feedId:Number):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectInfoById;
            stmt.parameters[":feed_id"] = feedId;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
            		var results:SQLResult = stmt.getResult();
					dbe.data = results.data[0];
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}

		public function getFeeds(responder:DatabaseResponder):void
		{
			if (!this.aConn.connected) return;
			var stmt:SQLStatement = this.getStatement();
			stmt.sqlConnection = this.aConn;
            stmt.text = this.sql.feeds.selectAll;
            stmt.addEventListener(SQLEvent.RESULT,
            	function(e:SQLEvent):void
            	{
					var dbe:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dbe.data = stmt.getResult().data;
					responder.dispatchEvent(dbe);
            	});
            stmt.execute();
		}
		*/
		
		private function getStatement():SQLStatement
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.addEventListener(SQLErrorEvent.ERROR,
				function(e:SQLErrorEvent):void
				{
					trace("getStatement SQLError event: ", e);
				});
			return stmt;
		}
	}
}