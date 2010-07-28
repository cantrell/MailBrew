package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.AccountInfo;
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.data.PreferenceKeys;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.model.ModelLocator;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	
	import mx.collections.ArrayCollection;
	
	public class PopulateAccountListCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			var pale:PopulateAccountListEvent = e as PopulateAccountListEvent;
			var ml:ModelLocator = ModelLocator.getInstance();
			var db:Database = ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				var accountData:Array =  new Array();
				for each (var o:Object in e.data)
				{
					var accountInfo:Object = new Object();
					accountInfo.label = o.name;
					accountInfo.username = o.username;
					accountInfo.accountId = o.id;
					accountInfo.working = o.working;
					accountInfo.active = o.active;
					accountInfo.accountType = o.account_type;
					accountInfo.selected = (o.id == pale.selectedId) ? true : false;
					accountInfo.total = o.total;
					accountData.push(accountInfo);
				}
				ml.accounts = new ArrayCollection(accountData);
				
				// Should the "Check Now" dock/tray icon be enabled?
				var menu:NativeMenu = ModelLocator.getInstance().notificationManager.getMenu();
				var checkNowMenuItem:NativeMenuItem;
				for each (var nmi:NativeMenuItem in menu.items)
				{
					if (nmi.name == "checkNow")
					{
						checkNowMenuItem = nmi;
						break;
					}
				}
				if (checkNowMenuItem != null)
				{
					checkNowMenuItem.enabled = false;
					for each (var ai:Object in ml.accounts)
					{
						if (ai.active)
						{
							checkNowMenuItem.enabled = true;
							break;
						}
					}
				}
				
				// Handle monthly usage reports
				var oldTimestamp:Number = ml.prefs.getValue(PreferenceKeys.MONTHLY_REPORT_TIMESTAMP, 0);
				var newTimestamp:Number = new Date().time;
				if (oldTimestamp == 0)
				{
					ml.prefs.setValue(PreferenceKeys.MONTHLY_REPORT_TIMESTAMP, newTimestamp, false);
					return;
				}
				if ((newTimestamp - oldTimestamp) >= (30 * 24 * 60 * 60 * 1000)) // about one month
				{
					var gmail:uint = 0, imap:uint = 0, googleWave:uint = 0, googleVoice:uint = 0;
					for each (var aInfo:Object in ml.accounts)
					{
						if (aInfo.accountType == AccountTypes.GMAIL)
						{
							++gmail;
						}
						else if (aInfo.accountType == AccountTypes.IMAP)
						{
							++imap;
						}
						else if (aInfo.accountType == AccountTypes.GOOGLE_WAVE)
						{
							++googleWave;
						}
						else if (aInfo.accountType == AccountTypes.GOOGLE_VOICE)
						{
							++googleVoice;
						}
					}
					ml.tracker.eventMonthlyReport(imap, gmail, googleWave, googleVoice);
					ml.prefs.setValue(PreferenceKeys.MONTHLY_REPORT_TIMESTAMP, newTimestamp, false);
					ml.prefs.save();
				}
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getAccountLabels(responder);
		}
	}
}