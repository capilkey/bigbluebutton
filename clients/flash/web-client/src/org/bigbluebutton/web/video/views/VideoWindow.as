package org.bigbluebutton.web.video.views {
	import org.bigbluebutton.web.window.views.BBBWindow;
	
	public class VideoWindow extends BBBWindow {
		
		public var videoContainer:WebcamGroup;
		
		public function VideoWindow() {
			super();
			
			title = "Videos";
			width = 300;
			height = 400;
			
			videoContainer = new WebcamGroup();
			videoContainer.percentHeight = 100;
			videoContainer.percentWidth = 100;
			
			addElement(videoContainer);
		}
		
		public function addVideo(v:WebcamView):void {
			videoContainer.addVideo(v);
		}
		
		public function removeVideo(v:WebcamView):void {
			videoContainer.removeVideo(v);
		}
	}
}
