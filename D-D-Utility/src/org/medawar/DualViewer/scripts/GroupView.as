package org.medawar.DualViewer.scripts
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.security.SignatureStatus;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import flashx.textLayout.formats.Float;
	
	import mx.collections.ArrayList;
	import mx.collections.XMLListCollection;
	import mx.controls.listClasses.ListData;
	
	import org.medawar.DualViewer.map.SimpleZoomMap;

	public class GroupView
	{
		private var path:String ;
		private var name:String;
		private var libPath:String ;
		private var m:Model;
		public function GroupView(name:String,path:String,libPath:String, m:Model ){
			var pattern:RegExp = /$'/g; 
			
			this.path = path.replace(pattern,"");
			this.name = name.replace(pattern,"");
			this.libPath = libPath.replace(pattern,"");
			this.m = m;
			m.setGroup(this);
		}
		public function seralise():void{
			var ob:String ="<group><name>'"+this.name+"'</name><libpath>'"+this.libPath+"'</libpath><path>'"+this.path+"'</path>";
			ob+=m.getMapsSealized();
			
			ob+="</group>";
		
			var dskTopFileStream:FileStream = new FileStream();
			var dskTopFile:File = new File(this.path+"/"+this.name+".cmp");
			dskTopFileStream.openAsync (dskTopFile, FileMode.WRITE);
			dskTopFileStream.writeUTFBytes (ob);
			dskTopFileStream.close();
		}
		public function unseralise(f:File):void{
			var fileStream:FileStream = new FileStream();
			fileStream.open(f, FileMode.READ); 
			var xmlGroup:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable)); 
			fileStream.close(); 
			this.name = xmlGroup.name[0].text();
			this.path = xmlGroup.path[0].text();
			this.libPath = xmlGroup.libpath[0].text();
			var pattern:RegExp = /'/g; 
			this.path = this.path.replace(pattern,"");
			this.name = this.name.replace(pattern,"");
			this.libPath = this.libPath.replace(pattern,"");
			for (var i:int = 0; i < xmlGroup.map.length(); i++)
			{
				var map:XML = xmlGroup.map[i];
				var v:SimpleZoomMap = new SimpleZoomMap("","",m);
				var xml:XMLDocument = new XMLDocument();	
				v.load(map);
				m.addView(v);
			}
			
		}
		public function getLibPath():String{
			return libPath;
		}
	}
}