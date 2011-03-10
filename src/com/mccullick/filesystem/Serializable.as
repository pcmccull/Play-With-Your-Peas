package com.mccullick.filesystem 
{
	
	/**
	* ...
	* @author Philip McCullick
	*/
	public interface Serializable 
	{
		/**
		 * Create an object that can be used to rebuild this Class instance in this exact state
		 * @return
		 */
		function save():Object;
		
		/**
		 * Load the object that was saved and rebuild the Class instance
		 * @param	obj
		 */
		function load(obj:Object):void
		
	}
	
}