package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.data.PreferenceKeys;
	import com.mailbrew.database.Database;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.email.EmailEvent;
	import com.mailbrew.email.EmailHeader;
	import com.mailbrew.email.IEmailService;
	import com.mailbrew.events.CheckMailEvent;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.events.UpdateAppIconEvent;
	import com.mailbrew.model.ModelLocator;
	import com.mailbrew.notify.Notification;
	import com.mailbrew.util.EmailServiceFactory;
	import com.mailbrew.util.ServiceIconFactory;
	import com.mailbrew.util.StatusBarManager;
	
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NotificationType;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.System;
	
	public class CheckMailCommand implements ICommand
	{
		private var accountData:Array;
		private var currentAccount:Object;
		private var newUnseenEmails:Vector.<EmailHeader>;
		private var oldUnseenEmails:Array;
		private var ml:ModelLocator;
		private var topLevelMenu:NativeMenu;
		private var serviceMenu:NativeMenu;
		private var emailService:IEmailService;
		
		public function execute(e:CairngormEvent):void
		{
			var cme:CheckMailEvent = e as CheckMailEvent;
			this.ml = ModelLocator.getInstance();
			if (this.ml.checkEmailLock) return;
			this.ml.checkEmailLock = true;
			StatusBarManager.showMessage("Checking for new messages", true);
			var db:Database = this.ml.db;
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				accountData = e.data;
				topLevelMenu = ml.notificationManager.getMenu();
				if (topLevelMenu == null)
				{
					topLevelMenu = new NativeMenu();
					ml.notificationManager.setMenu(topLevelMenu);
				}
				checkEmailLoop();
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			if (cme.accountIds == null)
			{
				db.getAccounts(responder);
			}
			else
			{
				db.getAccountsByIds(responder, cme.accountIds);
			}
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
		
		private function finish():void
		{			
			// Update the app icon
			new UpdateAppIconEvent().dispatch();
			
			// Refresh the account list to show or clear errors.
			// Make sure the correct account is selected after 
			// the refresh.
			var pale:PopulateAccountListEvent = new PopulateAccountListEvent();
			if (this.ml.accountInfo != null)
			{
				pale.selectedId = this.ml.accountInfo.accountId;
			}
			pale.dispatch();
			
			// Update the status message
			StatusBarManager.showMessage("Done", false);
			
			// Do some memory management
			this.disposeEmailService();
			this.accountData = null;
			this.currentAccount = null;
			this.newUnseenEmails = null;
			this.oldUnseenEmails = null;
			this.ml = null;
			this.topLevelMenu = null;
			this.serviceMenu = null;
			System.gc();
			
			// Remove the lock
			ModelLocator.getInstance().checkEmailLock = false;
		}
		
		private function checkEmailLoop():void
		{
			// The loop is finished
			if (this.accountData == null || this.accountData.length == 0)
			{
				this.finish();
				return;
			}
			
			// Reset some stuff
			this.newUnseenEmails = null;
			this.oldUnseenEmails = null;
			this.currentAccount = this.accountData.pop();
			if (!this.currentAccount.active)
			{
				this.checkEmailLoop();
				return;
			}
			
			// Manage the Dock or System Tray menu
			if (this.topLevelMenu.getItemByName(this.currentAccount.id) != null)
			{
				this.topLevelMenu.removeItem(this.topLevelMenu.getItemByName(this.currentAccount.id));
			}
			this.serviceMenu = new NativeMenu();
			this.serviceMenu.addEventListener(Event.SELECT, onMenuItemSelected);
			var menuItem:NativeMenuItem = new NativeMenuItem(this.currentAccount.name);
			menuItem.name = this.currentAccount.id;
			menuItem.submenu = this.serviceMenu;
			this.topLevelMenu.addItemAt(menuItem, 0);
			this.disposeEmailService();
			this.emailService = EmailServiceFactory.getEmailService(this.currentAccount.account_type,
																	this.currentAccount.username,
																	this.currentAccount.password,
																	this.currentAccount.imap_server,
																	Number(this.currentAccount.port_number),
																	Boolean(this.currentAccount.secure));
			this.emailService.addEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			this.emailService.addEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			this.emailService.addEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
			this.emailService.addEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
			StatusBarManager.showMessage("Checking " + this.currentAccount.name, true);
			this.emailService.getUnseenEmailHeaders();
		}
		
		private function disposeEmailService():void
		{
			if (this.emailService != null)
			{
				this.emailService.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
				this.emailService.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
				this.emailService.removeEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
				this.emailService.removeEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
				this.emailService.dispose();
				this.emailService = null;
			}
		}
		
		private function onProtocolError(e:EmailEvent):void
		{
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.PROTOCOL_ERROR, onProtocolError);
			var reason:String = "Protocol error.";
			if (e.data != null)
			{
				reason += " [Error message: "+e.data+"]"; 
			}
			this.updateAccountAndContinue(false, reason);
		}
		
		private function onAuthenticationFailed(e:EmailEvent):void
		{
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.AUTHENTICATION_FAILED, onAuthenticationFailed);
			var reason:String = "Authentication failed. Your credentials were not accepted. Please update your username and password.";
			if (e.data != null)
			{
				reason += " [Error message: "+e.data+"]"; 
			}
			this.updateAccountAndContinue(false, reason);
		}
		
		private function onConnectionFailed(e:EmailEvent):void
		{
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.CONNECTION_FAILED, onConnectionFailed);
			var reason:String = "Unable to connect to email service.";
			if (e.data != null)
			{
				reason += " [Error message: "+e.data+"]"; 
			}
			this.updateAccountAndContinue(false, reason);
		}
		
		private function onUnseenEmails(e:EmailEvent):void
		{
			var es:IEmailService = e.target as IEmailService;
			es.removeEventListener(EmailEvent.UNSEEN_EMAILS, onUnseenEmails);
			this.newUnseenEmails = e.data;
			if (this.newUnseenEmails == null)
			{
				this.updateAccountAndContinue(true, null);
				return;
			}
			else if (this.newUnseenEmails.length == 0)
			{
				if (this.topLevelMenu.getItemByName(this.currentAccount.id) != null)
				{
					this.topLevelMenu.getItemByName(this.currentAccount.id).enabled = false;
				}
				this.deleteOldMessages();
				return;
			}
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
			var notificationSoundPlayed:Boolean = false;
			var dockIconBounced:Boolean = false;
			newEmailLoop: for (var i:uint = 0; i < this.newUnseenEmails.length; ++i)
			{
				var emailHeader:EmailHeader = this.newUnseenEmails[i];
				var subject:String = new String();
				if (emailHeader.subject != null)
				{
					subject = emailHeader.subject;
				}
				else if (emailHeader.summary != null)
				{
					subject = emailHeader.summary;
				}
				var menuItem:NativeMenuItem = new NativeMenuItem(emailHeader.from + " - " + subject);
				if (emailHeader.url != null)
				{
					menuItem.data = emailHeader.url;
				}
				else
				{
					menuItem.enabled = false;
				}
				this.serviceMenu.addItem(menuItem);
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
				if (!notificationSoundPlayed)
				{
					this.playNotificationSound();
					notificationSoundPlayed = true;
				}
				if (!dockIconBounced)
				{
					this.bounceDockIcon();
					dockIconBounced = true;
				}
				if (i < ModelLocator.MAX_NOTIFICATIONS)
				{
					this.addNotification(emailHeader);
				}
			}
			this.deleteOldMessages();
		}
		
		private function addNotification(emailHeader:EmailHeader):void
		{
			var summary:String = (emailHeader.summary != null) ? emailHeader.summary : emailHeader.subject;
			var notification:Notification = new Notification(emailHeader.from,
                                                             summary,
															 this.currentAccount.notification_location,
															 this.ml.prefs.getValue(PreferenceKeys.NOTIFICATION_DISPLAY_INTERVAL),
															 ServiceIconFactory.getLargeServiceIconClass(this.currentAccount.account_type, this.currentAccount.username),
															 ModelLocator.DEFAULT_FRAME_RATE);
			notification.addEventListener(Event.CLOSE, onNotificationClosed);
			this.ml.notificationManager.addNotification(notification);
		}
		
		private static function onNotificationClosed(e:Event):void
		{
			var notification:Notification = e.target as Notification;
			notification.removeEventListener(Event.CLOSE, onNotificationClosed);
			if (ModelLocator.getInstance().notificationManager.length == 0)
			{
				// All done showing notifications
				if (NativeApplication.nativeApplication.activeWindow == null) // App isn't open or active
				{
					ModelLocator.getInstance().frameRate = 1;
				}
			}
		}
		
		private function playNotificationSound():void
		{
			var soundName:String = this.currentAccount.notification_sound;
			if (soundName == null) return;
			var SoundClass:Class = this.ml.notificationSounds.getSound(soundName);
			var sound:Sound = new SoundClass();
			sound.play();
		}
		
		private function bounceDockIcon():void
		{
			if (!this.ml.prefs.getValue(PreferenceKeys.APPLICATION_ALERT, false)) return;
			ModelLocator.getInstance().notificationManager.alert(NotificationType.INFORMATIONAL, NativeApplication.nativeApplication.openedWindows[0]);
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
		
		private static function onMenuItemSelected(e:Event):void
		{
			var menuItem:NativeMenuItem = e.target as NativeMenuItem;
			if (menuItem.data != null)
			{
				navigateToURL(new URLRequest(String(menuItem.data)));
			}
		}
	}
}