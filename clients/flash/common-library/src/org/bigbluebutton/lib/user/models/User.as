package org.bigbluebutton.lib.user.models {
	
	import org.bigbluebutton.lib.chat.models.ChatMessages;
	import org.osflash.signals.ISignal;
	
	[Bindable]
	public class User {
		public static const MODERATOR:String = "MODERATOR";
		
		public static const VIEWER:String = "VIEWER";
		
		public static const PRESENTER:String = "PRESENTER";
		
		public static const UNKNOWN_USER:String = "UNKNOWN USER";
		
		/**
		 * Flag to tell that user is in the process of leaving the meeting.
		 */
		public var isLeavingFlag:Boolean = false;
		
		private var _userID:String = UNKNOWN_USER;
		
		public function get userID():String {
			return _userID;
		}
		
		public function set userID(value:String):void {
			_userID = value;
		}
		
		private var _name:String;
		
		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
		}
		
		private var _phoneUser:Boolean = false;
		
		public function get phoneUser():Boolean {
			return _phoneUser;
		}
		
		public function set phoneUser(value:Boolean):void {
			_phoneUser = value;
		}
		
		private var _me:Boolean = false;
		
		public function get me():Boolean {
			return _me;
		}
		
		public function set me(value:Boolean):void {
			_me = value;
		}
		
		private var _presenter:Boolean = false;
		
		public function get presenter():Boolean {
			return _presenter;
		}
		
		public function set presenter(value:Boolean):void {
			_presenter = value;
		}
		
		private var _role:String = VIEWER;
		
		public function get role():String {
			return _role;
		}
		
		public function set role(role:String):void {
			_role = role;
			verifyUserStatus();
		}
		
		private var _raiseHand:Boolean = false;
		
		public function get raiseHand():Boolean {
			return _raiseHand;
		}
		
		public function set raiseHand(r:Boolean):void {
			_raiseHand = r;
			verifyUserStatus();
		}
		
		private var _voiceUserId:String;
		
		public function get voiceUserId():String {
			return _voiceUserId;
		}
		
		public function set voiceUserId(value:String):void {
			_voiceUserId = value;
		}
		
		private var _voiceJoined:Boolean;
		
		public function get voiceJoined():Boolean {
			return _voiceJoined;
		}
		
		public function set voiceJoined(value:Boolean):void {
			_voiceJoined = value;
			verifyUserStatus();
		}
		
		private var _muted:Boolean;
		
		public function get muted():Boolean {
			return _muted;
		}
		
		public function set muted(value:Boolean):void {
			_muted = value;
			verifyUserStatus();
		}
		
		private var _talking:Boolean;
		
		public function get talking():Boolean {
			return _talking;
		}
		
		public function set talking(value:Boolean):void {
			_talking = value;
			verifyUserStatus();
		}
		
		private var _locked:Boolean;
		
		public function get locked():Boolean {
			return _locked;
			verifyUserStatus();
		}
		
		public function set locked(value:Boolean):void {
			_locked = value;
		}
		
		public var streamNames:Array = new Array();
		
		public function get hasStream():Boolean {
			return streamNames.length > 0;
		}
		
		public function sharedWebcam(stream:String):Boolean {
			if (stream && stream != "" && !hasThisStream(stream)) {
				streamNames.push(stream);
				verifyMedia();
				return true;
			}
			
			return false;
		}
		
		public function unsharedWebcam(stream:String):void {
			streamNames = streamNames.filter(function(item:*, index:int, array:Array):Boolean {
				return item != stream;
			});
			verifyMedia();
		}
		
		private function hasThisStream(streamName:String):Boolean {
			return streamNames.some(function(item:*, index:int, array:Array):Boolean {
				return item == streamName;
			});
		}
		
		public var viewingStreams:Array = new Array();
		
		public function addViewingStream(streamName:String):Boolean {
			if (isViewingStream(streamName)) {
				return false;
			}
			
			viewingStreams.push(streamName);
			return true;
		}
		
		public function removeViewingStream(streamName:String):Boolean {
			if (!isViewingStream(streamName)) {
				return false;
			}
			
			viewingStreams = viewingStreams.filter(function(item:*, index:int, array:Array):Boolean {
				return item != streamName;
			});
			return true;
		}
		
		private function isViewingStream(streamName:String):Boolean {
			return viewingStreams.some(function(item:*, index:int, array:Array):Boolean {
				return item == streamName;
			});
		}
		
		public function isViewingAllStreams():Boolean {
			return viewingStreams.length == streamNames.length;
		}
		
		// This used to only be used for accessibility and doesn't need to be filled in yet. - Chad
		private function verifyUserStatus():void {
		}
		
		// This used to only be used for accessibility and doesn't need to be filled in yet. - Chad
		private function verifyMedia():void {
		}
		
		public function isModerator():Boolean {
			return role == MODERATOR;
		}
		
		private var _listenOnly:Boolean;
		
		public function get listenOnly():Boolean {
			return _listenOnly;
		}
		
		public function set listenOnly(value:Boolean):void {
			_listenOnly = value;
		}
	}
}
