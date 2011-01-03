package org.medawar.DualViewer.map
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.xml.*;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.SWFLoader;
	import mx.core.UIComponent;
	import mx.effects.Zoom;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.modules.Module;
	
	import org.medawar.DualViewer.scripts.Model;
	
	import spark.components.Group;
	import spark.components.VSlider;
	
	
	public class SimpleZoomMap extends Module	
	{		
		private var cont:Group = new Group();
		private var zoom:Zoom = new Zoom(cont);
		private var s:VSlider = new VSlider();
		private var maxId:uint = 0;
		public var nameView:String;
		private var m:Model;
		
		public function SimpleZoomMap(src:String , namev:String,model:Model)
		{
			this.m=model;
			this.nameView = namev;
			addEventListener( Event.ADDED, registerListeners )
			this.percentHeight=100;
			this.percentWidth=100;
			this.horizontalScrollPolicy = "off";
			this.verticalScrollPolicy= "off";
			this.layout="absolute";
			
			s.right = 17;
			s.top=14;
			s.value=1;
			s.minimum=0.1;
			s.maximum=2;
			s.stepSize = 0.2;
			s.addEventListener(Event.CHANGE,function(e:Event):void{ 
				scaleAt( s.value, lastP.x, lastP.y )                            
			});
			this.addElement(cont);
			this.addElement(s);
			
			this.setPicture(src);
			
		}
		private var _loader:Loader;
		private var  lastP:Point = new Point(0,0) ;
		private var  pict:SWFLoader = new SWFLoader();
		
		private var objects:Array = new Array();
		
		
		//private var objects:Vector.<mapObject> = new Vector.<mapObject>();
		private var crnObjt:mapObject;
		public function addObject(src:String,id:String):mapObject{
			src = m.getfullURLinOS(src);
			var im:mapObject = new mapObject();
			_loader = new Loader();
			if(crnObjt !=null)
				crnObjt.op.visible=false;
			im.im.load(src);
			//im.im.scaleContent = true;
			im.del.addEventListener(MouseEvent.MOUSE_DOWN,function(e:Event):void{ 
				cont.removeElement(im);
				delete objects[im.id];
				crnObjt=null;
			});
			im.addEventListener(MouseEvent.MOUSE_DOWN,function(e:Event):void{ 
				im.startDrag();
				im.op.setVisible(true);
				crnObjt=im;
			});
			im.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE,function(e:Event):void{ 
				im.stopDrag();
				im.op.setVisible(false);
			});
			im.addEventListener(MouseEvent.MOUSE_UP,function(e:Event):void{ 
				im.stopDrag();
			});
			im.x=lastP.x;
			im.y=lastP.y;
			cont.addElement(im);
			im.id=id;
			objects[id]=im;
			return im;
		}
		public function getModification():String{
			var xmlString:String ="";///="<modifiy>";
			xmlString+=seralize();
			//xmlString+="</modifiy>";
			return xmlString;
			
		}
		public function seralize():String{
			var xmlString:String ="";
			
			xmlString+="<map label='"+this.nameView+"' x='"+cont.x+"' y='"+cont.y+"' scale='"+cont.scaleX+"' source='"+m.getRelativeURLinLib(pict.source.toString())+"'>";
			for (var k:String in objects) 
			{
				var value:mapObject =objects[k]; // <-- lookup
				xmlString+="<object id='"+value.id+"' x='"+value.x+"' y='"+value.y+"' scale='"+value.im.scaleX+"' source='"+m.getRelativeURLinLib(value.im.source)+"' rotation='"+value.im.rotation+"' />\n";
			}
			xmlString+="</map>";
			
			//result.parseXML(xmlString);
			return xmlString;					
		}
		public function load(doc:XML):void{
			if(pict.source!= m.getfullURLinOS(doc.@source)){
				this.setPicture(doc.@source);
			}
			
			this.nameView = doc.@label;
			
			var p:Point = cont.localToGlobal(new Point(doc.@x,doc.@y));
			//scaleAt(doc.firstChild.firstChild.attributes.scale,p.x ,p.y);
			
			cont.x =  doc.@x;
			cont.y = doc.@y;
			cont.scaleX = doc.@scale;
			cont.scaleY = doc.@scale;
			/*cont.scaleX = doc.firstChild.firstChild.attributes.scale;
			cont.scaleY = doc.firstChild.firstChild.attributes.scale;*/
			var notDel:Dictionary = new Dictionary();
			for each(var ob:XML in doc..object) { // Soit la variable bal, car le nom "balise" est déja utilisé ici
				var mCrt:mapObject;
				if (objects[ob.@id]==null){
					addObject(ob.@source,ob.@id);	
				}
				mCrt = objects[ob.@id];
				
				mCrt.x=ob.@x;
				mCrt.y=ob.@y;
				mCrt.im.scaleX=ob.@scale;
				mCrt.im.scaleY=ob.@scale;
				mCrt.im.rotation=ob.@rotation;
				mCrt.id= ob.@id;
				notDel[mCrt.id]= true;
			}
			for (var k:String in objects) 
			{
				if(notDel[k] == null){
					cont.removeElement(objects[k])
					delete objects[k];
				}
			}
		}
		
		public function setPicture(src:String):void{
			if(src =="")return;
			pict = new SWFLoader();
			pict.autoLoad=true;
			pict.id="pict" ;
			
			src = m.getfullURLinOS(src);
			       
			
			pict.load(src);
			pict.addEventListener(IOErrorEvent.IO_ERROR, handleIO);
			cont.addElement(pict);	
		}
		public function handleIO(evt:IOErrorEvent):void
		{
			trace(evt);
			// [IOErrorEvent type="ioError" bubbles=false cancelable=false eventPhase=2 text="Error #2035: URL Not Found. URL: file:///D|/as3/foo.gif"]
		}
		public function  scaleAtUn( scale : Number, originX : Number, originY : Number ) : void
		{
			if(zoom.isPlaying)zoom.stop();
			zoom.originX = originX;
			zoom.originY = originY;
			zoom.zoomHeightFrom = 1;
			zoom.zoomWidthFrom= 1;
			zoom.zoomHeightTo= scale;
			zoom.zoomWidthTo= scale;
			zoom.play();
			
		}
		
		// Transformations
		public function scaleAt( scale : Number, originX : Number, originY : Number ) : void
		{
			if(zoom.isPlaying)zoom.stop();
			zoom.originX = originX;
			zoom.originY = originY;
			zoom.zoomHeightFrom = cont.scaleX;
			zoom.zoomWidthFrom= cont.scaleX;
			zoom.zoomHeightTo= scale;
			zoom.zoomWidthTo= scale;
			zoom.play();
			
		}
		
		public function rotateAt( angle : Number, originX : Number, originY : Number ) : void
		{
			/*// get the transformation matrix of this object
			affineTransform = cont.transform.matrix
			
			
			// move the object to (0/0) relative to the origin
			affineTransform.translate( -originX, -originY )
			
			// rotate
			affineTransform.rotate( angle )
			
			// move the object back to its original position
			affineTransform.translate( originX, originY )
			
			
			// apply the new transformation to the object
			cont.transform.matrix = affineTransform*/
		}
		
		
		// Helpers
		private function registerListeners( event : Event ) : void
		{
			// Panning
			pict.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown )
			
			pict.addEventListener( MouseEvent.MOUSE_UP, onMouseUp )
			pict.addEventListener( FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onMouseUp )
			
			// Mouse wheel support for zooming
			cont.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel )
			
			// Keyboard support for zooming
			pict.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown )            
		}
		
		
		// Event Handlers
		private function onMouseWheel( event : MouseEvent ) : void
		{
			// set the origin of the transformation
			// to the current position of the mouse
			var originX : Number = cont.mouseX
			var originY : Number = cont.mouseY
			lastP = new Point(originX, originY); 
			// zoom
			if( !event.altKey )
			{
				if( event.delta > 0 )
				{                    
					// zoom in
					scaleAt( cont.scaleX+0.2, originX, originY ) 
				}
				else
				{
					// zoom out                    
					scaleAt( cont.scaleX-0.2, originX, originY )
				}
			}
			else
			{
				// rotate
				rotateAt( event.delta / 20, originX, originY )
			}
			s.value= cont.scaleX;
		}
		
		private function onMouseDown( event : MouseEvent ) : void
		{
			cont.startDrag()
			var originX : Number = cont.mouseX
			var originY : Number = cont.mouseY
			lastP = new Point(originX, originY); 
			if(crnObjt !=null)
				crnObjt.op.visible=false;
		}
		
		private function onMouseUp( event : MouseEvent ) : void
		{
			cont.stopDrag()
		}
		
		/**
		 * Keyboard support for zooming due to
		 * missing mouse wheel support on Mac OS
		 */
		private function onKeyDown( event : KeyboardEvent ) : void
		{
			// set the origin of the transformation
			// to the current position of the mouse
			var originX : Number = cont.mouseX
			var originY : Number = cont.mouseY
			lastP = new Point(originX, originY); 
			
			// zoom
			if( event.keyCode == Keyboard.UP )
			{
				// zoom in
				scaleAt( cont.scaleX+0.2, originX, originY )                            
			}
			else if( event.keyCode == Keyboard.DOWN )
			{
				// zoom out
				scaleAt(cont.scaleX-0.2, originX, originY )                    
			}
				// rotate
			else if( event.keyCode == Keyboard.LEFT )
			{
				// rotate left    
				rotateAt( -Math.PI / 60, originX, originY )                
			}
			else if( event.keyCode == Keyboard.RIGHT )
			{
				// rotate right
				rotateAt( Math.PI / 60, originX, originY )                
			}
		}
	}
}