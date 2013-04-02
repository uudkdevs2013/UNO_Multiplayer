﻿/**
 * The CLIK Label component is a noneditable standard textField wrapped by a MovieClip symbol, with a few additional convenient features. Internally, the Label supports the same properties and behaviors as the standard textField, however only a handful of commonly used features are exposed by the component itself. Access to the Label’s actual textField is provided if the user needs to change its properties directly. In certain cases, such as those described below, developers may use the standard textField instead of the Label component.
 
   Since the Label is a MovieClip symbol, it can be embellished with graphical elements, which is not possible with the standard textField. As a symbol, it does not need to be configured per instance like textField instances.  The Label also provides a disabled state that can be defined in the timeline. Whereas, complex AS2 code is required to mimic such behavior with the standard textField. 

   The Label component uses constraints by default, which means resizing a Label instance on the stage will have no visible effect at runtime. If resizing textFields is required, developers should use the standard textField instead of the Label in most cases. In general, if consistent reusability is not a requirement for the text element, the standard textField is a lighter weight alternative than the Label component.

 
	<b>Inspectable Properties</b>
	The inspectable properties of the Label component are:<ul>
	<li><i>text</i>: Sets the text of the Label.</li>
	<li><i>visible</i>: Hides the label if set to false.</li>
	<li><i>disabled</i>: Disables the label if set to true.</li>
	<li><i>autoSize</i>: Determines if the button will scale to fit the text that it contains and which direction to align the resized button. Setting the autoSize property to {@code autoSize="none"} will leave its current size unchanged.</li>
	<li><i>enableInitCallback</i>: If set to true, _global.CLIK_loadCallback() will be fired when a component is loaded and _global.CLIK_unloadCallback will be called when the component is unloaded. These methods receive the instance name, target path, and a reference the component as parameters.  _global.CLIK_loadCallback and _global.CLIK_unloadCallback should be overriden from the game engine using GFx FunctionObjects.</li></ul>
	
	<b>States</b>
	The CLIK Label component supports two states based on the disabled property.<ul>
	<li>A default or enabled state.</li>
	<li>a disabled state.</li></ul>
	
	<b>Events</b>
	All event callbacks receive a single Object parameter that contains relevant information about the event. The following properties are common to all events. <ul>
	<li><i>type</i>: The event type.</li>
	<li><i>target</i>: The target that generated the event.</li></ul>
	
	The events generated by the Label component are listed below. The properties listed next to the event are provided in addition to the common properties.<ul>
	<li><i>show</i>: The component’s visible property has been set to true at runtime.</li>
	<li><i>hide</i>: The component’s visible property has been set to false at runtime.</li>
	<li><i>stateChange</i>: The label’s state has changed.</li><ul>
		<li><i>state</i>: The new label state. String type. Values "default" or "disabled". </li></ul></li></ul>
 */

/**************************************************************************

Filename    :   Label.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

import flash.external.ExternalInterface; 
import gfx.core.UIComponent;
import gfx.utils.Constraints;
import gfx.utils.Locale;

[InspectableList("disabled", "visible", "textID", "enableInitCallback", "autoSize")]
class gfx.controls.Label extends UIComponent {
	
// Constants:

// Public Properties:

// Private Properties:
	private var _text:String;
	private var _autoSize:String = "none";
	private var constraints:Constraints;
	private var isHtml:Boolean;
	
// UI Elements:
	/** A reference to the TextField instance. Note that when state changes are made, the textField instance may change, so changes made to it externally may be lost. */
	public var textField:TextField;

	
// Initialization:
	/**
	 * The constructor is called when a Label or a sub-class of Label is instantiated on stage or by using {@code attachMovie()} in ActionScript. This component can <b>not</b> be instantiated using {@code new} syntax. When creating new components that extend Label, ensure that a {@code super()} call is made first in the constructor.
	 */
	public function Label() { super(); }
	
// Public Methods:
	/**
	 * Set the {@code text} parameter of the component using the Locale class to look up a localized version of the text from the Game Engine. This property can be set with ActionScript, and is used when the text is set using the Component Inspector.
	 * @see Locale
	 */
	[Inspectable(name="text", defaultValue="")]
	public function get textID():String { return null; }
	public function set textID(value:String):Void {
		if (value != "") {
			text = Locale.getTranslatedString(value);
		}
	}
	
	/**
	 * The text to be displayed by the Label component. This property assumes that localization has been handled externally.
	 * @see #htmlText For formatted text, use the {@code htmlText} property.
	 */
	public function get text():String { return _text; }
	public function set text(value:String):Void { 
		isHtml = false;
		_text = value; 		
		if (initialized) {
            if (textField != null) { textField.text = value; }            
            sizeIsInvalid = true;
            validateNow();
        }
	}
	
	/**
	 * The html text to be displayed by the label component.  This property assumes that localization has been handled externally.
	 * @see #text For plain text use {@code text} property.
	 */
	public function get htmlText():String { return _text; }
	public function set htmlText(value:String):Void {
		isHtml = true;
		_text = value;
		if (textField != null) {
			textField.html = true;
			textField.htmlText = value;
		}
		if (initialized) {
            sizeIsInvalid = true;
            validateNow();            
        }
	}
	
	[Inspectable(defaultValue="false", verbose="1")]
	public function get disabled():Boolean { return _disabled; }
	public function set disabled(value:Boolean):Void { 
		super.disabled = value;
		setState(); 
	}
	
	/**
	 * Determines if the component will scale to fit the text that it contains. Setting the {@code autoSize} property to {@code false} will leave its current size unchanged.
	 */
	[Inspectable(type="String", enumeration="none,left,center,right", defaultValue="none")]
	public function get autoSize():String { return _autoSize; }
	public function set autoSize(value:String):Void {
		if (_autoSize == value) { return; }
		_autoSize = value;
		if (initialized) {
            sizeIsInvalid = true;
            validateNow();            
        }
	}
	
	public function setSize(width:Number, height:Number):Void {
		var w:Number = (_autoSize != "none") ? calculateWidth() : width;
		super.setSize(w, height);
	}
	
	/** @exclude */
	public function toString():String {
		return "[Scaleform Label " + _name + "]";
	}
	
	
// Private Methods:
	private function configUI():Void {
		constraints = new Constraints(this, true);
		constraints.addElement(textField, Constraints.ALL);
		tabEnabled = tabChildren = false;
		super.configUI();
		updateAfterStateChange();
		        
		if (autoSize != "none") {
            sizeIsInvalid = true;            
        }
	}
	
	/**
	 * Realigns the component based on the autoSize property.
	 */
	private function alignForAutoSize():Void {
        if (!initialized || _autoSize == "none" || textField == null) 
            return;
            
        var oldWidth = __width;
        width = calculateWidth();                        

        switch (_autoSize) {
            case "right":
                var oldRight = _x + oldWidth;
                _x = oldRight - __width;
                break;
            case "center":
                var oldCenter = _x + oldWidth/2;
                _x = oldCenter - __width / 2;
                break;
        }      
    }
	
	private function calculateWidth():Number {
        if (!initialized)
            return textField.textWidth + 5;
            
        var metrics:Object = constraints.getElement(textField).metrics;
        return textField.textWidth + metrics.left + metrics.right + 5;
	}

	private function updateAfterStateChange():Void {
		if (!initialized) { return; }
		validateNow(); // Ensure that the width/height is up to date.
		if (textField != null && _text != null) { 
			if (isHtml) {
				textField.html = true;
				textField.htmlText = _text
			} else {
				textField.text = _text;
			}
		}
		if (constraints != null) { constraints.update(__width,__height); }
		dispatchEvent({type:"stateChange", state:(_disabled ? "disabled" : "default")});
	}
	
	private function draw():Void {
		if (sizeIsInvalid) { 
			alignForAutoSize();
			_width = __width;
			_height = __height; 
		}
		constraints.update(__width,__height);
	}
	
	private function setState():Void {
		gotoAndPlay(_disabled ? "disabled" : "default");
		updateAfterStateChange();
	}
}
