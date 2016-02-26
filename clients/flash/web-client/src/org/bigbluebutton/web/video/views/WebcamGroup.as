package org.bigbluebutton.web.video.views {
	import spark.components.Group;
	
	public class WebcamGroup extends Group {
		private const VERTICAL_PADDING:uint = 1;
		
		private const HORIZONTAL_PADDING:uint = 1;
		
		private var _minContentAspectRatio:Number = 4 / 3;
		
		public function WebcamGroup() {
			super();
		}
		
		public function addVideo(v:WebcamView):void {
			addElement(v);
			_minContentAspectRatio = minContentAspectRatio();
			invalidateDisplayList();
		}
		
		public function removeVideo(v:WebcamView):void {
			removeElement(v);
			_minContentAspectRatio = minContentAspectRatio();
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			updateDisplayListHelper(w, h);
		}
		
		private function updateDisplayListHelper(unscaledWidth:Number, unscaledHeight:Number):void {
			if (numChildren == 0) {
				return;
			}
			
			var bestConfiguration:Object = findBestConfiguration(unscaledWidth, unscaledHeight, numChildren);
			var numColumns:int = bestConfiguration.numColumns;
			var numRows:int = bestConfiguration.numRows;
			var cellWidth:int = bestConfiguration.width;
			var cellHeight:int = bestConfiguration.height;
			var cellAspectRatio:Number = bestConfiguration.cellAspectRatio;
			
			var blockX:int = Math.floor((unscaledWidth - cellWidth * numColumns) / 2);
			var blockY:int = Math.floor((unscaledHeight - cellHeight * numRows) / 2);
			var itemX:int, itemY:int, itemWidth:int, itemHeight:int;
			
			for (var i:int = 0; i < numChildren; ++i) {
				var item:WebcamView = getChildAt(i) as WebcamView;
				var cellOffsetX:int = 0;
				var cellOffsetY:int = 0;
				if (item.videoProfile.aspectRatio > cellAspectRatio) {
					itemWidth = cellWidth;
					itemHeight = Math.floor(cellWidth / item.videoProfile.aspectRatio);
					cellOffsetY = (cellHeight - itemHeight) / 2;
				} else {
					itemWidth = Math.floor(cellHeight * item.videoProfile.aspectRatio);
					itemHeight = cellHeight;
					cellOffsetX = (cellWidth - itemWidth) / 2;
				}
				itemX = (i % numColumns) * cellWidth + blockX + cellOffsetX;
				itemY = Math.floor(i / numColumns) * cellHeight + blockY + cellOffsetY;
				
				item.setActualSize(itemWidth, itemHeight);
				item.move(itemX, itemY);
			}
		}
		
		private function findBestConfiguration(canvasWidth:int, canvasHeight:int, numChildrenInCanvas:int):Object {
			var bestConfiguration:Object = {occupiedArea: 0}
			
			for (var numColumns:int = 1; numColumns <= numChildrenInCanvas; ++numColumns) {
				var numRows:int = Math.ceil(numChildrenInCanvas / numColumns);
				var currentConfiguration:Object = calculateOccupiedArea(canvasWidth, canvasHeight, numColumns, numRows);
				if (currentConfiguration.occupiedArea > bestConfiguration.occupiedArea) {
					bestConfiguration = currentConfiguration;
				}
			}
			return bestConfiguration;
		}
		
		private function calculateOccupiedArea(canvasWidth:int, canvasHeight:int, numColumns:int, numRows:int):Object {
			var obj:Object = calculateCellDimensions(canvasWidth, canvasHeight, numColumns, numRows);
			obj.occupiedArea = obj.width * obj.height * numChildren;
			obj.numColumns = numColumns;
			obj.numRows = numRows;
			obj.cellAspectRatio = _minContentAspectRatio;
			return obj;
		}
		
		private function calculateCellDimensions(canvasWidth:int, canvasHeight:int, numColumns:int, numRows:int):Object {
			var obj:Object = {width: Math.floor(canvasWidth / numColumns) - HORIZONTAL_PADDING, height: Math.floor(canvasHeight / numRows) - VERTICAL_PADDING}
			if (obj.width / obj.height > _minContentAspectRatio) {
				obj.width = Math.floor(obj.height * _minContentAspectRatio);
			} else {
				obj.height = Math.floor(obj.width / _minContentAspectRatio);
			}
			return obj;
		}
		
		private function minContentAspectRatio():Number {
			var result:Number = Number.MAX_VALUE;
			for (var i:int = 0; i < numChildren; ++i) {
				var item:WebcamView = getChildAt(i) as WebcamView;
				if (item.videoProfile.aspectRatio < result) {
					result = item.videoProfile.aspectRatio;
				}
			}
			return result;
		}
	}
}
