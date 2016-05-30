package org.bigbluebutton.web.main.views {
	import mx.graphics.SolidColor;
	
	import org.bigbluebutton.lib.main.views.MenuButtonsBase;
	import org.bigbluebutton.lib.main.views.TopToolbarBase;
	import org.bigbluebutton.lib.presentation.models.Presentation;
	import org.bigbluebutton.lib.presentation.views.PresentationViewBase;
	import org.bigbluebutton.web.video.views.WebcamGroup;
	
	import spark.components.Group;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Rect;
	
	public class MainPanel extends Group {
		private var _presentationView:PresentationViewBase;
		
		private var _menuButtons:MenuButtonsBase;
		
		private var _topToolbar:TopToolbarBase;
		
		private var _videoContainer:WebcamGroup;
		
		private var _contentGroup:Group;
		
		private var _contentVerticalLayout:VerticalLayout;
		
		private var _contentHorizontalLayout:HorizontalLayout;
		
		public function MainPanel() {
			super();
			
			var l:VerticalLayout = new VerticalLayout();
			l.gap = 0;
			l.horizontalAlign = "center";
			layout = l;
			
			_topToolbar = new TopToolbarBase();
			_topToolbar.percentWidth = 100;
			_topToolbar.height = 60;
			addElement(_topToolbar);
			
			_contentGroup = new Group();
			_contentGroup.height = 100;
			_contentGroup.width = 100;
			
			_contentVerticalLayout = new VerticalLayout();
			_contentHorizontalLayout = new HorizontalLayout();
			
			_contentGroup.layout = _contentVerticalLayout;
			
			_presentationView = new PresentationViewBase();
			_presentationView.percentWidth = 100;
			_presentationView.percentHeight = 100;
			_contentGroup.addElement(_presentationView);
			
			_videoContainer = new WebcamGroup();
			_videoContainer.percentWidth = 100;
			_contentGroup.addElement(_videoContainer);
			
			addElement(_contentGroup);
			
			_menuButtons = new MenuButtonsBase();
			addElement(_menuButtons);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			_contentGroup.width = w;
			_contentGroup.height = h - _topToolbar.height - _menuButtons.height;
			
			if (_videoContainer.numVideos == 0) {
				_videoContainer.width = 0;
				_videoContainer.height = 0;
				_presentationView.width = _contentGroup.width;
				_presentationView.height = _contentGroup.height;
			} else {
				var viewportRatio:Number = _presentationView.viewport.width / _presentationView.viewport.height;
				var availableRatio:Number = _contentGroup.width / _contentGroup.height;
				
				if (viewportRatio > availableRatio) { // width is maxed
					var maxPageHeight:Number = w / viewportRatio;
					var videoHeight:Number = Math.max(_contentGroup.height - maxPageHeight, 0.2 * _contentGroup.height);
					
					_videoContainer.width = _contentGroup.width;
					_videoContainer.height = videoHeight;
					_presentationView.width = _contentGroup.width;
					_presentationView.height = _contentGroup.height - videoHeight;
					
					_contentGroup.layout = _contentVerticalLayout;
				} else if (viewportRatio < availableRatio) { // height is maxed
					var maxPageWidth:Number = h * viewportRatio;
					var videoWidth:Number = Math.max(_contentGroup.width - maxPageWidth, 0.2 * _contentGroup.width);
					
					_videoContainer.width = videoWidth;
					_videoContainer.height = _contentGroup.height;
					_presentationView.width = _contentGroup.width - videoWidth;
					_presentationView.height = _contentGroup.height;
					
					_contentGroup.layout = _contentHorizontalLayout;
				} else { // equal
					
				}
			}
		}
	}
}
