package com.mccullick.filesystem 
{
	import flash.net.SharedObject;

	/**
	* ...
	* @author Philip McCullick
	*/
	public class File 
	{
		private var fileName:String;
		public function File(fileName:String) 
		{
			this.fileName = fileName;
		}
		
		/**
		 * Writes an object to the disk
		 * @param	obj
		 */
		public function save(obj:Object):void
		{
			var so:SharedObject = SharedObject.getLocal(fileName);
			so.data.savedObject = obj;
			so.flush();
		}
		
		/**
		 * Loads an object from the disk
		 * @return
		 */
		public function load():Object
		{
			var so:SharedObject = SharedObject.getLocal(fileName);
			return so.data.savedObject;		
		}
		
	}
	
}