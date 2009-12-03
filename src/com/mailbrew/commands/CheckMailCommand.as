package com.mailbrew.commands
{
	import com.adobe.air.notification.Notification;
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.AccountTypes;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailHeader;
	import com.mailbrew.email.IEmailService;
	import com.mailbrew.email.gmail.Gmail;
	import com.mailbrew.email.imap.IMAP;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.events.UpdateAppIconEvent;
	import com.mailbrew.model.ModelLocator;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	
	public class CheckMailCommand implements ICommand
	{
		private var accountData:Array;
		private var currentAccount:Object;
		private var newUnseenEmails:Vector.<EmailHeader>;
		private var oldUnseenEmails:Array;
		private var unseenTotal:Number;
		private var ml:ModelLocator;
		private var menu:NativeMenu;
		
		public function execute(e:CairngormEvent):void
		{
			this.ml = ModelLocator.getInstance();
			if (this.ml.checkEmailLock) return;
			this.ml.checkEmailLock = true;
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				accountData = e.data;
				unseenTotal = 0;
				menu = new NativeMenu();
				menu.addEventListener(Event.SELECT, onMenuItemSelected);
				checkEmailLoop();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getAccounts(responder);
		}
		
		private function updateAccountAndContinue(working:Boolean, workingReason:String):void
		{
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				checkEmailLoop();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.updateLastChecked(responder, this.currentAccount.id, working, workingReason, new Date());
		}
		
		public function checkEmailLoop():void
		{
			// The loop is finished
			if (this.accountData == null || this.accountData.length == 0)
			{
				// Remove the lock
				this.ml.checkEmailLock = false;
				
				// Set the menu
				this.ml.purr.setMenu(this.menu);
				
				// Update the app icon
				var uaie:UpdateAppIconEvent = new UpdateAppIconEvent();
				uaie.unseenCount = this.unseenTotal;
				uaie.dispatch();
				
				// Refresh the account list to show or clear errors
				new PopulateAccountListEvent().dispatch();
				
				// Update the status message
				this.ml.statusMessage = "Done";
				
				return;
			}
			this.newUnseenEmails = null;
			this.oldUnseenEmails = null;
			this.currentAccount = this.accountData.pop();
			var emailService:IEmailService;
			if (this.currentAccount.account_type == AccountTypes.IMAP)
			{
				emailService = new IMAP(this.currentAccount.username,
										this.currentAccount.password,
										this.currentAccount.imap_server,
										Number(this.currentAccount.port_number),
										Boolean(this.currentAccount.secure));
			}
			else if (this.currentAccount.account_type == AccountTypes.GMAIL)
			{
				emailService = new Gmail(this.currentAccount.username, this.currentAccount.password);
			}
			
			emailService.addEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			emailService.addEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			emailService.addEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
			
			this.ml.statusMessage = "Checking " + this.currentAccount.name + "...";
			emailService.getUnseenEmailHeaders();
		}
		
		private function onAuthenticationFailed(e:EmailEvent):void
		{
			trace("onAuthenticationFailed");
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			var reason:String = "Authentication failed. Your credentials were not accepted. Please update your username and password.";
			if (e.data != null)
			{
				reason += " [Error message: "+e.data+"]"; 
			}
			this.updateAccountAndContinue(false, reason);
		}
		
		private function onConnectionFailed(e:EmailEvent):void
		{
			trace("onConnectionFailed", e.data);
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			var reason:String = "Unable to connect to email service.";
			if (e.data != null)
			{
				reason += " [Error message: "+e.data+"]"; 
			}
			this.updateAccountAndContinue(false, reason);
		}
		
		private function onUnseenEmails(e:EmailEvent):void
		{
			var emailService:IEmailService = e.target as IEmailService;
			emailService.removeEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
			this.newUnseenEmails = e.data;
			if (this.newUnseenEmails == null || this.newUnseenEmails.length == 0)
			{
				this.updateAccountAndContinue(true, null);
				return;
			}
			// If unseenTotal isn't 0, that means unseen emails have already been found
			// in other accounts and added to the NativeMenu. And since we know that
			// we just found more unseen email, this is a good time and place to add
			// a separator to the NativeMenu.
			if (this.unseenTotal > 0)
			{
				var separator:NativeMenuItem = new NativeMenuItem(null, true);
				this.menu.addItem(separator);
			}
			this.unseenTotal += this.newUnseenEmails.length;
			this.getOldUnseenEmails();
		}
		
		private function getOldUnseenEmails():void
		{
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				oldUnseenEmails = e.data;
				if (oldUnseenEmails == null) oldUnseenEmails = new Array();
				compareOldAndNew();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.getMessagesByAccountId(responder, this.currentAccount.id);
		}
		
		private function compareOldAndNew():void
		{
			newEmailLoop: for (var i:uint = 0; i < this.newUnseenEmails.length; ++i)
			{
				var emailHeader:EmailHeader = this.newUnseenEmails[i];
				var menuItem:NativeMenuItem = new NativeMenuItem(emailHeader.from + " - " + emailHeader.subject);
				menuItem.data = emailHeader.url;
				this.menu.addItem(menuItem);
				oldEmailLoop: for (var j:uint = 0; j < this.oldUnseenEmails.length; ++j)
				{
					var oldEmail:Object = this.oldUnseenEmails[j];
					if (emailHeader.id == oldEmail.unique_id)
					{
						continue newEmailLoop;
					}
				}
				// This has to happen in real-time while the currentAccount is in scope and we
				// know the location of the notifications. Don't move to the end of the process.
				this.addNotification(emailHeader);
			}
			this.deleteOldMessages();
		}
		
		private function addNotification(emailHeader:EmailHeader):void
		{
			var summary:String = (emailHeader.summary != null) ? emailHeader.summary : emailHeader.subject;
			var notification:Notification = new Notification(emailHeader.from, summary, this.currentAccount.notification_location, 3, this.ml.notificationIcon);
			notification.width = 250;
			this.ml.purr.addNotification(notification);
		}
		
		private function deleteOldMessages():void
		{
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				db.aConn.begin();
				insertNewMessageLoop();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.deleteMessagesByAccountId(responder, this.currentAccount.id);
		}

		private function insertNewMessageLoop():void
		{
			var db:Database = this.ml.db;
			if (this.newUnseenEmails == null || this.newUnseenEmails.length == 0)
			{
				db.aConn.commit();
				this.updateAccountAndContinue(true, null);
				return;
			}
			var unseenEmail:EmailHeader = this.newUnseenEmails.pop();
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				insertNewMessageLoop();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			db.insertUnseenMessage(responder, this.currentAccount.id, unseenEmail.id);
		}
		
		private function onMenuItemSelected(e:Event):void
		{
			var menuItem:NativeMenuItem = e.target as NativeMenuItem;
			if (menuItem.data != null)
			{
				navigateToURL(new URLRequest(String(menuItem.data)));
			}
		}
	}
}