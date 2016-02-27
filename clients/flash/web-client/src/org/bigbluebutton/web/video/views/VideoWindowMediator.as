package org.bigbluebutton.web.video.views {
	import mx.collections.ArrayCollection;
	
	import org.bigbluebutton.lib.main.models.IUserSession;
	import org.bigbluebutton.lib.user.models.User;
	import org.bigbluebutton.lib.user.models.UserList;
	import org.bigbluebutton.lib.video.models.IVideoProfileManager;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class VideoWindowMediator extends Mediator {
		
		[Inject]
		public var view:VideoWindow;
		
		[Inject]
		public var userSession:IUserSession;
		
		[Inject]
		public var videoProfileManager:IVideoProfileManager;
		
		private var videos:ArrayCollection;
		
		override public function initialize():void {
			userSession.userList.userAddedSignal.add(userAddedHandler);
			userSession.userList.userRemovedSignal.add(userRemovedHandler);
			userSession.userList.userChangeSignal.add(userChangeHandler);
			
			videos = new ArrayCollection();
			
			if (videoProfileManager.loaded) {
				setupAllWebcams();
			} else {
				videoProfileManager.loadedSignal.add(videoProfilesLoadedHandler);
			}
		}
		
		private function setupAllWebcams():void {
			closeAllWebcams();
			
			// find existing webcams
			var users:ArrayCollection = userSession.userList.users;
			for each (var u:User in users) {
				for each (var s:String in u.streamNames) {
					startStream(u, s);
				}
			}
		}
		
		private function closeAllWebcams():void {
			for each (var video:Object in videos) {
				stopStream(null, video.streamName);
			}
		}
		
		private function videoProfilesLoadedHandler():void {
			videoProfileManager.loadedSignal.remove(videoProfilesLoadedHandler);
			
			setupAllWebcams();
		}
		
		private function userAddedHandler(user:User):void {
			for each (var s:String in user.streamNames) {
				startStream(user, s);
			}
		}
		
		private function userRemovedHandler(userId:String):void {
			var videosByUserId:Array = findVideosByUserId(userId);
			
			for each (var video:Object in videosByUserId) {
				stopStream(null, video.streamName);
			}
		}
		
		private function userChangeHandler(user:User, type:int, streamName:Object):void {
			if (type == UserList.START_STREAM) {
				trace("name: " + user.name + ", hasStream: " + user.hasStream + ", streamName: " + streamName);
				startStream(user, streamName as String);
			} else if (type == UserList.STOP_STREAM) {
				stopStream(user, streamName as String);
			}
		}
		
		private function startStream(user:User, streamName:String):void {
			if (findVideoByStreamName(streamName) == null) {
				for (var i:int = 0; i < 10; i++) {
					var newWebcam:WebcamView = new WebcamView();
					newWebcam.videoProfile = videoProfileManager.getVideoProfileByStreamName(streamName);
					newWebcam.startStream(userSession.videoConnection.connection, user.name, streamName, user.userID);
					
					videos.addItem(newWebcam);
					view.addVideo(newWebcam);
					user.addViewingStream(streamName);
				}
			}
		}
		
		private function stopStream(user:User, streamName:String):void {
			var video:WebcamView = findVideoByStreamName(streamName);
			if (video != null) {
				videos.removeItem(video);
				view.removeVideo(video);
				video.close();
				
				if (user != null) {
					user.removeViewingStream(streamName);
				}
			}
		}
		
		private function findVideoByStreamName(streamName:String):WebcamView {
			for each (var video:Object in videos) {
				if ((video as WebcamView).streamName == streamName) {
					return video as WebcamView;
				}
			}
			return null;
		}
		
		private function findVideosByUserId(userId:String):Array {
			var returnedArray:Array = new Array();
			
			for each (var video:Object in videos) {
				if ((video as WebcamView).userID == userId) {
					returnedArray.push(video);
				}
			}
			return returnedArray;
		}
		
		override public function destroy():void {
			userSession.userList.userAddedSignal.remove(userAddedHandler);
			userSession.userList.userRemovedSignal.remove(userRemovedHandler);
			userSession.userList.userChangeSignal.remove(userChangeHandler);
			videoProfileManager.loadedSignal.remove(videoProfilesLoadedHandler);
			
			closeAllWebcams();
			
			super.destroy();
			view = null;
		}
	}
}
