package org.bigbluebutton.web.video.views {
	import flash.events.Event;
	
	import org.bigbluebutton.lib.common.views.VideoView;
	import org.bigbluebutton.lib.video.models.VideoProfile;
	
	public class WebcamView extends VideoView {
		
		protected var _videoProfile:VideoProfile;
		
		public function WebcamView() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.RESIZE, onResize);
			
			width = 100;
			height = 100;
		}
		
		public function set videoProfile(vp:VideoProfile):void {
			_videoProfile = vp;
		}
		
		public function get videoProfile():VideoProfile {
			return _videoProfile;
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			positionVideo();
			addChild(video);
		}
		
		private function onResize(e:Event):void {
			positionVideo();
		}
		
		private function positionVideo():void {
			var videoAspectRatio:Number = _videoProfile.aspectRatio;
			var containerAspectRatio:Number = width / height;
			
			if (videoAspectRatio > containerAspectRatio) {
				video.width = width;
				video.height = width / videoAspectRatio;
			} else {
				video.height = height;
				video.width = height * videoAspectRatio;
			}
			
			video.x = width / 2 - video.width / 2;
			video.y = height / 2 - video.height / 2;
		}
		
		public override function close():void {
			removeEventListener(Event.RESIZE, onResize);
			super.close();
		}
	}
}
