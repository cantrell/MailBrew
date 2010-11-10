package com.mailbrew.commands
{
	import air.update.ApplicationUpdaterUI;
	
	import com.adobe.air.crypto.EncryptionKeyGenerator;
	import com.adobe.air.preferences.Preference;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.components.PreferencesWindow;
	import com.mailbrew.components.Summary;
	import com.mailbrew.data.PreferenceKeys;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.CheckMailEvent;
	import com.mailbrew.events.InitEvent;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.model.ModelLocator;
	import com.mailbrew.notify.NotificationManager;
	import com.mailbrew.util.Tracker;
	import com.mailbrew.util.WindowManager;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class InitCommand
		implements ICommand
	{
		private var ml:ModelLocator;
		
		public function execute(e:CairngormEvent):void
		{
			var initEvent:InitEvent = e as InitEvent;
			this.ml = ModelLocator.getInstance();
			
			var prefs:Preference = new Preference();
			prefs.load();
			this.ml.prefs = prefs;
			
			// Set up preferences...
			var defaultsSet:Boolean = false;
			if (this.ml.prefs.getValue(PreferenceKeys.UPDATE_INTERVAL) == null)
			{
				this.ml.prefs.setValue(PreferenceKeys.UPDATE_INTERVAL, PreferenceKeys.UPDATE_INTERVAL_DEFAULT, false);
				defaultsSet = true;
			}

			if (this.ml.prefs.getValue(PreferenceKeys.NOTIFICATION_DISPLAY_INTERVAL) == null)
			{
				this.ml.prefs.setValue(PreferenceKeys.NOTIFICATION_DISPLAY_INTERVAL, PreferenceKeys.NOTIFICATION_DISPLAY_INTERVAL_DEFAULT, false);
				defaultsSet = true;
			}

			if (this.ml.prefs.getValue(PreferenceKeys.IDLE_THRESHOLD) == null)
			{
				this.ml.prefs.setValue(PreferenceKeys.IDLE_THRESHOLD, PreferenceKeys.IDLE_THRESHOLD_DEFAULT, false);
				defaultsSet = true;
			}
			
			if (this.ml.prefs.getValue(PreferenceKeys.COLLECT_USAGE_DATA) == null)
			{
				this.ml.prefs.setValue(PreferenceKeys.COLLECT_USAGE_DATA, PreferenceKeys.COLLECT_USAGE_DATA_DEFAULT, false);
				defaultsSet = true;
			}
			
			if (this.ml.prefs.getValue(PreferenceKeys.APPLICATION_ALERT) == null)
			{
				this.ml.prefs.setValue(PreferenceKeys.APPLICATION_ALERT, PreferenceKeys.APPLICATION_ALERT_DEFAULT, false);
				defaultsSet = true;
			}

			// Summary window
			if (this.ml.prefs.getValue(PreferenceKeys.SUMMARY_WINDOW_POINT) != null)
			{
				var summaryWindowLocation:Object = this.ml.prefs.getValue(PreferenceKeys.SUMMARY_WINDOW_POINT);
				this.ml.summaryWindow = new Summary();
				this.ml.summaryWindow.setLocation(new Point(summaryWindowLocation.x, summaryWindowLocation.y));
				this.ml.summaryWindow.open(false);
			}

			if (defaultsSet) this.ml.prefs.save();

			// Set up analytics
			this.ml.tracker = new Tracker();
			
			// Installation event
			if (!this.ml.prefs.getValue(PreferenceKeys.MAILBREW_INSTALLATION_FLAG))
			{
				this.ml.prefs.setValue(PreferenceKeys.MAILBREW_INSTALLATION_FLAG, true, false);
				this.ml.prefs.save();
				this.ml.tracker.eventInstall();
			}
			
			// Set up the notification manager
			this.ml.notificationManager = new NotificationManager(this.ml.prefs.getValue(PreferenceKeys.IDLE_THRESHOLD));

			// Dock and system tray icons
			var appIcons:Array = new Array();
			appIcons.push(new this.ml.Dynamic128IconClass());
			appIcons.push(new this.ml.Dynamic16IconClass());
			this.ml.notificationManager.setIcons(appIcons);
			
			var topLevelMenu:NativeMenu = this.ml.notificationManager.getMenu();
			if (topLevelMenu == null)
			{
				topLevelMenu = new NativeMenu();
				this.ml.notificationManager.setMenu(topLevelMenu);
			}

			var sep1:NativeMenuItem = new NativeMenuItem(null, true);
			topLevelMenu.addItemAt(sep1, 0);

			var checkNowMenuItem:NativeMenuItem = new NativeMenuItem("Check Now");
			checkNowMenuItem.name = "checkNow";
			checkNowMenuItem.addEventListener(Event.SELECT, onCheckNow);
			topLevelMenu.addItemAt(checkNowMenuItem, 1);

			var sep2:NativeMenuItem = new NativeMenuItem(null, true);
			topLevelMenu.addItemAt(sep2, 2);

			var openMenuItem:NativeMenuItem = new NativeMenuItem("Open");
			openMenuItem.name = "open";
			openMenuItem.addEventListener(Event.SELECT, onOpen);
			topLevelMenu.addItemAt(openMenuItem, 3);

			var prefsMenuItem:NativeMenuItem = new NativeMenuItem("Settings");
			prefsMenuItem.name = "open";
			prefsMenuItem.addEventListener(Event.SELECT, onSettings);
			topLevelMenu.addItemAt(prefsMenuItem, 4);
			
			// Exit option on Windows
			if (NativeApplication.supportsSystemTrayIcon)
			{
				var sep3:NativeMenuItem = new NativeMenuItem(null, true);
				topLevelMenu.addItemAt(sep3, 5);
				var exitMenuItem:NativeMenuItem = new NativeMenuItem("Exit");
				exitMenuItem.addEventListener(Event.SELECT, onExitApplication);
				topLevelMenu.addItemAt(exitMenuItem, 6);
			}
			
			var databasePassword:String = this.ml.prefs.getValue(PreferenceKeys.DATABASE_PASSWORD);
			if (databasePassword == null)
			{
				databasePassword = this.generateStrongPassword();
				this.ml.prefs.setValue(PreferenceKeys.DATABASE_PASSWORD, databasePassword, true);
				this.ml.prefs.save();
			}
			var sqlFile:File = File.applicationDirectory.resolvePath("sql.xml");
			var sqlFileStream:FileStream = new FileStream();
			sqlFileStream.open(sqlFile, FileMode.READ);
			var sql:XML = new XML(sqlFileStream.readUTFBytes(sqlFileStream.bytesAvailable));
			sqlFileStream.close();
			var keyGenerator:EncryptionKeyGenerator = new EncryptionKeyGenerator();
			var encryptionKey:ByteArray = keyGenerator.getEncryptionKey(databasePassword);
			var db:Database = new Database(sql, encryptionKey);
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
			this.ml.db.createAccountsTable(responder);			
		}
		
		private function createMessagesTable(e:Event):void
		{
			var oldResponder:DatabaseResponder = e.target as DatabaseResponder;
			oldResponder.removeEventListener(DatabaseEvent.RESULT_EVENT, createMessagesTable);
			var responder:DatabaseResponder = new DatabaseResponder();
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, start);
			this.ml.db.createMessagesTable(responder);			
		}
		
		private function start(e:Event):void
		{
			var oldResponder:DatabaseResponder = e.target as DatabaseResponder;
			oldResponder.removeEventListener(DatabaseEvent.RESULT_EVENT, start);
			new PopulateAccountListEvent().dispatch();
			this.ml.checkEmailTimer = new Timer(this.ml.prefs.getValue(PreferenceKeys.UPDATE_INTERVAL) * 60 * 1000);
			this.ml.checkEmailTimer.addEventListener(TimerEvent.TIMER, ml.checkEmail);
			this.ml.checkEmailTimer.start();
			if (!ModelLocator.testMode) new CheckMailEvent().dispatch();
			
			// Set up the application updater
			ml.appUpdater = new ApplicationUpdaterUI();
			ml.appUpdater.configurationFile = File.applicationDirectory.resolvePath("updaterSettings.xml");			
			ml.appUpdater.delay = 0; // No timer. Just check on startup
			ml.appUpdater.initialize();
		}
		
		private function onCheckNow(e:Event):void
		{
			new CheckMailEvent().dispatch();
			ModelLocator.getInstance().tracker.eventCheckAllNow();
		}
		
		private function onOpen(e:Event):void
		{
			this.ml.mainAppWindowVisible = true;
		}
		
		private function onSettings(e:Event):void
		{
			var win:NativeWindow = WindowManager.getWindowByTitle(WindowManager.PREFERENCES);
			if (win != null)
			{
				win.activate();
			}
			else
			{
				var prefsWin:PreferencesWindow = new PreferencesWindow();
				prefsWin.open(true);
			}

		}
		
		private function onExitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit(0);
		}
		
		private static const POSSIBLE_CHARS:Array = ["abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ","0123456789","~`!@#$%^&*()_-+=[{]}|;:'\"\\,<.>/?"];
		
		private function generateStrongPassword(length:uint = 32):String
		{
			if (length < 8) length = 8;
			var pw:String = new String();
			var charPos:uint = 0;
			while (pw.length < length)
			{
				var chars:String = POSSIBLE_CHARS[charPos];
				var char:String = chars.charAt(this.getRandomWholeNumber(0, chars.length - 1));
				var splitPos:uint = this.getRandomWholeNumber(0, pw.length);
				pw = (pw.substring(0, splitPos) + char + pw.substring(splitPos, pw.length));
				charPos = (charPos == 3) ? 0 : charPos + 1;
			}
			return pw;
		}
		
		private function getRandomWholeNumber(min:Number, max:Number):Number
		{
			return Math.round(((Math.random() * (max - min)) + min));
		}
	}
}
