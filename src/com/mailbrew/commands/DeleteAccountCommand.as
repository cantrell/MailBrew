package com.mailbrew.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.mailbrew.components.IconAlert;
	import com.mailbrew.database.DatabaseEvent;
	import com.mailbrew.database.DatabaseResponder;
	import com.mailbrew.events.DeleteAccountEvent;
	import com.mailbrew.events.PopulateAccountListEvent;
	import com.mailbrew.events.UpdateAppIconEvent;
	import com.mailbrew.model.ModelLocator;
	
	import flash.display.NativeMenu;
	
	public class DeleteAccountCommand
		implements ICommand
	{
		public function execute(e:CairngormEvent):void
		{
			if (ModelLocator.getInstance().checkEmailLock)
			{
				IconAlert.showInformation("Bad Timing", "You can't delete an account while checking for new messages. Please wait a second, then try again.");
				return;
			}
			var dae:DeleteAccountEvent = DeleteAccountEvent(e);
			this.deleteMessages(dae.accountId);
		}
		
		private function deleteMessages(accountId:Number):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				deleteAccount(accountId);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			ModelLocator.getInstance().db.deleteMessagesByAccountId(responder, accountId);
		}
		
		private function deleteAccount(accountId:Number):void
		{
			var responder:DatabaseResponder = new DatabaseResponder();
			var listener:Function = function(e:DatabaseEvent):void
			{
				responder.removeEventListener(DatabaseEvent.RESULT_EVENT, listener);
				ModelLocator.getInstance().accountInfo = null;
				new PopulateAccountListEvent().dispatch();
				removeIconMenu(accountId);
			};
			responder.addEventListener(DatabaseEvent.RESULT_EVENT, listener);
			ModelLocator.getInstance().db.deleteAccountById(responder, accountId);
		}
		
		private function removeIconMenu(accountId:Number):void
		{
			var menu:NativeMenu = ModelLocator.getInstance().notificationManager.getMenu();
			if (menu.getItemByName(String(accountId)) != null)
			{
				menu.removeItem(menu.getItemByName(String(accountId)));
			}
			this.updateAppIcon();
		}
		
		private function updateAppIcon():void
		{
			var uaie:UpdateAppIconEvent = new UpdateAppIconEvent();
			uaie.dispatch();
		}
	}
}