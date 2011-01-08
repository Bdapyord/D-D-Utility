package org.medawar.DualViewer.scripts
{
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.XMLListCollection;
	import flash.system.Capabilities;

	import org.medawar.DualViewer.map.SimpleZoomMap;
	
	import spark.skins.spark.mediaClasses.fullScreen.FullScreenButtonSkin;
	
	public class Model
	{
		[Bindable]
		public var viewCollection:XMLListCollection = new XMLListCollection();
		[Bindable]
		public var views:ArrayCollection = new ArrayCollection();
		[Bindable]
		private var viewsMap:ArrayCollection = new ArrayCollection();
		
		private var group:GroupView;
		
		private var currentView:int = 0;
		
		public function Model()
		{
			
			
		}
		public function setGroup( groupIN:GroupView ):void{
			this.group= groupIN;
		}
		
		public function getLibPaht():String{
			return this.group.getLibPath();
		}
		
		public function getMapsSealized():String{
			var s:String="";
			for each (var v:SimpleZoomMap in viewsMap){
				s+=v.seralize();
			}
			return s;
		}
		public function getCurrentView():SimpleZoomMap{
			return viewsMap.getItemAt(currentView);
		}
		public function setCurrentView(pos:int):void{
			currentView = pos;
		}
		public function addView(v:SimpleZoomMap):void{
			views.addItem({label: v.nameView});
			viewsMap.addItem(v);
		}
		public function getRelativeURLinLib(src:String):String{
			src=src.replace("file://","");
			var os:String = Capabilities.os.substr(0, 3);
			if (os == "Win") {
				var pattern:RegExp = /(\/)/g;

				src = src.replace(pattern,"\\");
				return src.replace(this.group.getLibPath()+"\\","");
			} else if (os == "Mac") {
				var pattern:RegExp = /(\\)/g;
				src = src.replace(pattern,"/");
				return src.replace(this.group.getLibPath()+"/","");
			 } else {          
				  return src;
			 }
			
		}
		public function getfullURLinOS(src:String):String{
			src = getRelativeURLinLib(src);
			if(src.substr(0,7)=="file://"){
				src=src.replace("file://","");
			}
			var os:String = Capabilities.os.substr(0, 3);
			if (os == "Win") {
				var pattern:RegExp = /(\/)/g;
				
				src = src.replace(pattern,"\\");
				return this.group.getLibPath()+"\\"+src;
	        } else if (os == "Mac") {
				var pattern:RegExp = /(\)/g;
				src = src.replace(pattern,"/");
				return "file://"+this.group.getLibPath()+"/"+src;
	        } else {          
		        return src;
	        }
		}
	}
}