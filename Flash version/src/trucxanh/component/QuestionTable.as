package trucxanh.component {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Trung đẹp trai
	 */
	public class QuestionTable extends Sprite {
		
		public var column: int = 0;
		public var row: int = 0;
		
		private var cellWidth: Number = 0;
		private var cellHeight: Number = 0;
		private var count:int = 0;
		
		public function QuestionTable() {
			this.filters = [new GlowFilter(0x000000)];
		}
		
		public function setData(listCell: XMLList, column: int, row: int): void {
			this.column = column;
			this.row = row;
			
			cellWidth = this.width / column;
			cellHeight = this.height / row;
			
			var index: int = 0;
			var total: int = listCell.cell.length();
			count = total;
			var xPos: Number = 0;
			var yPos: Number = 0;
			var cellMovie: QuestionCell;
			for (var i: int = 0; i < column; i++) {
				for (var j: int = 0; j < row; j++) {
					if (index >= total)	break;
					cellMovie = new QuestionCell();
					cellMovie.addEventListener(Event.COMPLETE, cellLoadCompleteHandler, false, 0, true);
					cellMovie.setData(listCell.cell[index], cellWidth, cellHeight);
					this.addChild(cellMovie);
					cellMovie.x = xPos;
					cellMovie.y = yPos;					
					yPos += cellHeight;
					index++;
				}
				yPos = 0;
				xPos += cellWidth;
			}
		}
		
		private function cellLoadCompleteHandler(event: Event): void {
			count--;
			if (count == 0)	this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}

}