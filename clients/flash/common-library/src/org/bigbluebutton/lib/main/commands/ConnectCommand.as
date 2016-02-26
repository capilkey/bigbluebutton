package org.bigbluebutton.lib.main.commands {
	
	import org.bigbluebutton.lib.chat.services.IChatMessageService;
	import org.bigbluebutton.lib.deskshare.services.IDeskshareConnection;
	import org.bigbluebutton.lib.main.models.IConferenceParameters;
	import org.bigbluebutton.lib.main.models.IUserSession;
	import org.bigbluebutton.lib.main.services.IBigBlueButtonConnection;
	import org.bigbluebutton.lib.presentation.services.IPresentationService;
	import org.bigbluebutton.lib.user.services.IUsersService;
	import org.bigbluebutton.lib.video.services.IVideoConnection;
	import org.bigbluebutton.lib.voice.services.IVoiceConnection;
	
	import robotlegs.bender.bundles.mvcs.Command;
	
	public class ConnectCommand extends Command {
		private const LOG:String = "ConnectCommand::";
		
		[Inject]
		public var userSession:IUserSession;
		
		[Inject]
		public var conferenceParameters:IConferenceParameters;
		
		[Inject]
		public var connection:IBigBlueButtonConnection;
		
		[Inject]
		public var videoConnection:IVideoConnection;
		
		[Inject]
		public var voiceConnection:IVoiceConnection;
		
		[Inject]
		public var deskshareConnection:IDeskshareConnection;
		
		[Inject]
		public var uri:String;
		
		[Inject]
		public var usersService:IUsersService;
		
		[Inject]
		public var chatService:IChatMessageService;
		
		[Inject]
		public var presentationService:IPresentationService;
		
		[Inject]
		public var connectingFinishedSignal:ConnectingFinishedSignal;
		
		[Inject]
		public var connectingFailedSignal:ConnectingFailedSignal;
		
		override public function execute():void {
			connection.uri = uri;
			connection.connectionSuccessSignal.add(mainConnectionSuccess);
			connection.connectionFailureSignal.add(mainConnectionFailure);
			connection.connect(conferenceParameters);
		}
		
		private function mainConnectionSuccess():void {
			trace(LOG + "mainConnectionSuccess()");
			connection.connectionSuccessSignal.remove(mainConnectionSuccess);
			connection.connectionFailureSignal.remove(mainConnectionFailure);
			
			userSession.mainConnection = connection;
			userSession.userId = connection.userId;
			
			// Set up users message sender in order to send the "joinMeeting" message:
			usersService.setupMessageSenderReceiver();
			chatService.setupMessageSenderReceiver();
			presentationService.setupMessageSenderReceiver();
			
			// Send the join meeting message, then wait for the reponse
			userSession.successJoiningMeetingSignal.add(validateTokenSuccess);
			userSession.failureJoiningMeetingSignal.add(validateTokenFailure);
			usersService.validateToken();
		}
		
		private function validateTokenSuccess():void {
			userSession.successJoiningMeetingSignal.remove(validateTokenSuccess);
			userSession.failureJoiningMeetingSignal.remove(validateTokenFailure);
			
			// set up and connect the remaining connections
			videoConnection.uri = userSession.config.getConfigFor("VideoConfModule").@uri + "/" + conferenceParameters.room;
			//TODO see if videoConnection.successConnected is dispatched when it's connected properly
			videoConnection.connectionSuccessSignal.add(videoConnectionSuccess);
			videoConnection.connectionFailureSignal.add(videoConnectionFailure);
			videoConnection.connect();
			userSession.videoConnection = videoConnection;
			
			voiceConnection.uri = userSession.config.getConfigFor("PhoneModule").@uri;
			userSession.voiceConnection = voiceConnection;
		}
		
		private function videoConnectionSuccess():void {
			trace(LOG + "successVideoConnected()");
			videoConnection.connectionSuccessSignal.remove(videoConnectionSuccess);
			videoConnection.connectionFailureSignal.remove(videoConnectionFailure);
			
			deskshareConnection.applicationURI = userSession.config.getConfigFor("DeskShareModule").@uri;
			deskshareConnection.room = conferenceParameters.room;
			deskshareConnection.connectionSuccessSignal.add(deskshareConnectionSuccess);
			deskshareConnection.connectionFailureSignal.add(deskshareConnectionFailure);
			deskshareConnection.connect();
			userSession.deskshareConnection = deskshareConnection;
		}
		
		private function deskshareConnectionSuccess():void {
			trace(LOG + "deskshareConnectionSuccess()");
			deskshareConnection.connectionSuccessSignal.remove(deskshareConnectionSuccess);
			deskshareConnection.connectionFailureSignal.remove(deskshareConnectionFailure);
			
			// Query the server for chat, users, and presentation info
			chatService.sendWelcomeMessage();
			chatService.getPublicChatMessages();
			presentationService.getPresentationInfo();
			userSession.userList.allUsersAddedSignal.add(successUsersAdded);
			usersService.queryForParticipants();
			usersService.queryForRecordingStatus();
			//usersService.getRoomLockState();
		}
		
		protected function successUsersAdded():void {
			userSession.userList.allUsersAddedSignal.remove(successUsersAdded);
			connectingFinishedSignal.dispatch();
		}
		
		private function mainConnectionFailure(reason:String):void {
			trace(LOG + "mainConnectionFailure()");
			connectingFailedSignal.dispatch("connectionFailed");
			connection.connectionSuccessSignal.remove(mainConnectionSuccess);
			connection.connectionFailureSignal.remove(mainConnectionFailure);
		}
		
		private function validateTokenFailure():void {
			trace(LOG + "validateTokenFailure() -- Failed to join the meeting!!!");
			userSession.successJoiningMeetingSignal.remove(validateTokenSuccess);
			userSession.failureJoiningMeetingSignal.remove(validateTokenFailure);
		}
		
		private function videoConnectionFailure(reason:String):void {
			trace(LOG + "videoConnectionFailure()");
			videoConnection.connectionSuccessSignal.remove(videoConnectionSuccess);
			videoConnection.connectionFailureSignal.remove(videoConnectionFailure);
		}
		
		private function deskshareConnectionFailure(reason:String):void {
			trace(LOG + "deskshareConnectionFailure()");
			deskshareConnection.connectionSuccessSignal.remove(deskshareConnectionSuccess);
			deskshareConnection.connectionFailureSignal.remove(deskshareConnectionFailure);
		}
	}
}
