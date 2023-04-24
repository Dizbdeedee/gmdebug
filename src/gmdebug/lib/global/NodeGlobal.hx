package global;

@:native("") extern class NodeGlobal {
	static var process : global.nodejs.Process;
	static var __filename : String;
	static var __dirname : String;
	static var require : global.NodeRequire;
	static var module : global.NodeModule;
	static var exports : Dynamic;
	/**
		Only available if `--expose-gc` is passed to the process.
	**/
	@:optional
	dynamic static function gc():Void;
	@:overload(function(callback:(args:ts.Undefined) -> Void):global.nodejs.Immediate { })
	static function setImmediate<TArgs>(callback:(args:haxe.extern.Rest<Any>) -> Void, args:haxe.extern.Rest<Any>):global.nodejs.Immediate;
	static function clearImmediate(immediateId:global.nodejs.Immediate):Void;
	static var global : {
		/**
			Evaluates JavaScript code and executes it.
		**/
		function eval(x:String):Dynamic;
		/**
			Converts a string to an integer.
		**/
		function parseInt(s:String, ?radix:Float):Float;
		/**
			Converts a string to a floating-point number.
		**/
		function parseFloat(string:String):Float;
		/**
			Returns a Boolean value that indicates whether a value is the reserved value NaN (not a number).
		**/
		function isNaN(number:Float):Bool;
		/**
			Determines whether a supplied number is finite.
		**/
		function isFinite(number:Float):Bool;
		/**
			Gets the unencoded version of an encoded Uniform Resource Identifier (URI).
		**/
		function decodeURI(encodedURI:String):String;
		/**
			Gets the unencoded version of an encoded component of a Uniform Resource Identifier (URI).
		**/
		function decodeURIComponent(encodedURIComponent:String):String;
		/**
			Encodes a text string as a valid Uniform Resource Identifier (URI)
		**/
		function encodeURI(uri:String):String;
		/**
			Encodes a text string as a valid component of a Uniform Resource Identifier (URI).
		**/
		function encodeURIComponent(uriComponent:ts.AnyOf3<String, Float, Bool>):String;
		/**
			Computes a new string in which certain characters have been replaced by a hexadecimal escape sequence.
		**/
		function escape(string:String):String;
		/**
			Computes a new string in which hexadecimal escape sequences are replaced with the character that it represents.
		**/
		function unescape(string:String):String;
		var NaN : Float;
		var Infinity : Float;
		var Symbol : js.lib.SymbolConstructor;
		/**
			Provides functionality common to all JavaScript objects.
		**/
		var Object : js.lib.ObjectConstructor;
		/**
			Creates a new function.
		**/
		var Function : js.lib.FunctionConstructor;
		/**
			Allows manipulation and formatting of text strings and determination and location of substrings within strings.
		**/
		var String : js.lib.StringConstructor;
		var Boolean : js.lib.BooleanConstructor;
		/**
			An object that represents a number of any kind. All JavaScript numbers are 64-bit floating-point numbers.
		**/
		var Number : js.lib.NumberConstructor;
		/**
			An intrinsic object that provides basic mathematics functionality and constants.
		**/
		var Math : js.lib.Math;
		/**
			Enables basic storage and retrieval of dates and times.
		**/
		var Date : js.lib.DateConstructor;
		var RegExp : js.lib.RegExpConstructor;
		var Error : js.lib.ErrorConstructor;
		var EvalError : js.lib.EvalErrorConstructor;
		var RangeError : js.lib.RangeErrorConstructor;
		var ReferenceError : js.lib.ReferenceErrorConstructor;
		var SyntaxError : js.lib.SyntaxErrorConstructor;
		var TypeError : js.lib.TypeErrorConstructor;
		var URIError : js.lib.URIErrorConstructor;
		/**
			An intrinsic object that provides functions to convert JavaScript values to and from the JavaScript Object Notation (JSON) format.
		**/
		var JSON : js.lib.JSON;
		var Array : js.lib.ArrayConstructor;
		/**
			Represents the completion of an asynchronous operation
			
			Represents the completion of an asynchronous operation
		**/
		var Promise : js.lib.PromiseConstructor;
		/**
			Represents a raw buffer of binary data, which is used to store data for the
			different typed arrays. ArrayBuffers cannot be read from or written to directly,
			but can be passed to a typed array or DataView Object to interpret the raw
			buffer as needed.
		**/
		var ArrayBuffer : js.lib.ArrayBufferConstructor;
		var DataView : js.lib.DataViewConstructor;
		/**
			A typed array of 8-bit integer values. The contents are initialized to 0. If the requested
			number of bytes could not be allocated an exception is raised.
		**/
		var Int8Array : js.lib.Int8ArrayConstructor;
		/**
			A typed array of 8-bit unsigned integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated an exception is raised.
		**/
		var Uint8Array : js.lib.Uint8ArrayConstructor;
		/**
			A typed array of 8-bit unsigned integer (clamped) values. The contents are initialized to 0.
			If the requested number of bytes could not be allocated an exception is raised.
		**/
		var Uint8ClampedArray : js.lib.Uint8ClampedArrayConstructor;
		/**
			A typed array of 16-bit signed integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated an exception is raised.
		**/
		var Int16Array : js.lib.Int16ArrayConstructor;
		/**
			A typed array of 16-bit unsigned integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated an exception is raised.
		**/
		var Uint16Array : js.lib.Uint16ArrayConstructor;
		/**
			A typed array of 32-bit signed integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated an exception is raised.
		**/
		var Int32Array : js.lib.Int32ArrayConstructor;
		/**
			A typed array of 32-bit unsigned integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated an exception is raised.
		**/
		var Uint32Array : js.lib.Uint32ArrayConstructor;
		/**
			A typed array of 32-bit float values. The contents are initialized to 0. If the requested number
			of bytes could not be allocated an exception is raised.
		**/
		var Float32Array : js.lib.Float32ArrayConstructor;
		/**
			A typed array of 64-bit float values. The contents are initialized to 0. If the requested
			number of bytes could not be allocated an exception is raised.
		**/
		var Float64Array : js.lib.Float64ArrayConstructor;
		function alert(?message:Dynamic):Void;
		function blur():Void;
		function captureEvents():Void;
		function close():Void;
		function confirm(?message:String):Bool;
		function departFocus(navigationReason:js.html.NavigationReason, origin:js.html.FocusNavigationOrigin):Void;
		function focus():Void;
		function getComputedStyle(elt:js.html.DOMElement, ?pseudoElt:String):js.html.CSSStyleDeclaration;
		function getMatchedCSSRules(elt:js.html.DOMElement, ?pseudoElt:String):js.html.CSSRuleList;
		function getSelection():Null<js.html.Selection>;
		function matchMedia(query:String):js.html.MediaQueryList;
		function moveBy(x:Float, y:Float):Void;
		function moveTo(x:Float, y:Float):Void;
		function msWriteProfilerMark(profilerMarkName:String):Void;
		function open(?url:String, ?target:String, ?features:String, ?replace:Bool):Null<js.html.Window>;
		function postMessage(message:Dynamic, targetOrigin:String, ?transfer:Array<js.html.Transferable>):Void;
		function print():Void;
		function prompt(?message:String, ?_default:String):Null<String>;
		function releaseEvents():Void;
		function resizeBy(x:Float, y:Float):Void;
		function resizeTo(x:Float, y:Float):Void;
		@:overload(function(x:Float, y:Float):Void { })
		function scroll(?options:js.html.ScrollToOptions):Void;
		@:overload(function(x:Float, y:Float):Void { })
		function scrollBy(?options:js.html.ScrollToOptions):Void;
		@:overload(function(x:Float, y:Float):Void { })
		function scrollTo(?options:js.html.ScrollToOptions):Void;
		function stop():Void;
		function webkitCancelAnimationFrame(handle:Float):Void;
		function webkitConvertPointFromNodeToPage(node:js.html.Node, pt:js.html.WebKitPoint):js.html.WebKitPoint;
		function webkitConvertPointFromPageToNode(node:js.html.Node, pt:js.html.WebKitPoint):js.html.WebKitPoint;
		function webkitRequestAnimationFrame(callback:js.html.FrameRequestCallback):Float;
		function toString():String;
		/**
			Dispatches a synthetic event event to target and returns true if either event's cancelable attribute value is false or its preventDefault() method was not invoked, and false otherwise.
		**/
		function dispatchEvent(event:js.html.Event):Bool;
		/**
			Decodes a string of Base64-encoded data into bytes, and encodes those bytes
			into a string using Latin-1 (ISO-8859-1).
			
			The `data` may be any JavaScript-value that can be coerced into a string.
			
			**This function is only provided for compatibility with legacy web platform APIs**
			**and should never be used in new code, because they use strings to represent**
			**binary data and predate the introduction of typed arrays in JavaScript.**
			**For code running using Node.js APIs, converting between base64-encoded strings**
			**and binary data should be performed using `Buffer.from(str, 'base64')` and`buf.toString('base64')`.**
		**/
		@:overload(function(data:String):String { })
		@:overload(function(data:String):String { })
		function atob(encodedString:String):String;
		/**
			Decodes a string into bytes using Latin-1 (ISO-8859), and encodes those bytes
			into a string using Base64.
			
			The `data` may be any JavaScript-value that can be coerced into a string.
			
			**This function is only provided for compatibility with legacy web platform APIs**
			**and should never be used in new code, because they use strings to represent**
			**binary data and predate the introduction of typed arrays in JavaScript.**
			**For code running using Node.js APIs, converting between base64-encoded strings**
			**and binary data should be performed using `Buffer.from(str, 'base64')` and`buf.toString('base64')`.**
		**/
		@:overload(function(data:String):String { })
		@:overload(function(data:String):String { })
		function btoa(rawString:String):String;
		function cancelAnimationFrame(handle:Float):Void;
		function requestAnimationFrame(callback:js.html.FrameRequestCallback):Float;
		@:overload(function(intervalId:global.nodejs.Timeout):Void { })
		function clearInterval(?handle:Float):Void;
		@:overload(function(timeoutId:global.nodejs.Timeout):Void { })
		function clearTimeout(?handle:Float):Void;
		@:overload(function(image:js.html.ImageBitmapSource, sx:Float, sy:Float, sw:Float, sh:Float):js.lib.Promise<js.html.ImageBitmap> { })
		function createImageBitmap(image:js.html.ImageBitmapSource):js.lib.Promise<js.html.ImageBitmap>;
		function fetch(input:js.html.RequestInfo, ?init:js.html.RequestInit):js.lib.Promise<js.html.Response>;
		@:overload(function(callback:() -> Void):Void { })
		function queueMicrotask(callback:haxe.Constraints.Function):Void;
		@:overload(function<TArgs>(callback:(args:haxe.extern.Rest<Any>) -> Void, ?ms:Float, args:haxe.extern.Rest<Any>):global.nodejs.Timer { })
		@:overload(function(callback:(args:ts.Undefined) -> Void, ?ms:Float):global.nodejs.Timer { })
		function setInterval(handler:js.html.TimerHandler, ?timeout:Float, arguments:haxe.extern.Rest<Dynamic>):Float;
		@:overload(function<TArgs>(callback:(args:haxe.extern.Rest<Any>) -> Void, ?ms:Float, args:haxe.extern.Rest<Any>):global.nodejs.Timeout { })
		@:overload(function(callback:(args:ts.Undefined) -> Void, ?ms:Float):global.nodejs.Timeout { })
		function setTimeout(handler:js.html.TimerHandler, ?timeout:Float, arguments:haxe.extern.Rest<Dynamic>):Float;
		@:overload(function(type:String, listener:js.html.EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void { })
		function addEventListener<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void;
		@:overload(function(type:String, listener:js.html.EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void { })
		function removeEventListener<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void;
		var RTCStatsReport : {
			var prototype : js.html.rtc.StatsReport;
		};
		/**
			A controller object that allows you to abort one or more DOM requests as and when desired.
			
			A controller object that allows you to abort one or more DOM requests as and when desired.
		**/
		var AbortController : {
			var prototype : js.html.AbortController;
		};
		/**
			A signal object that allows you to communicate with a DOM request (such as a Fetch) and abort it if required via an AbortController object.
			
			A signal object that allows you to communicate with a DOM request (such as a Fetch) and abort it if required via an AbortController object.
		**/
		var AbortSignal : {
			var prototype : js.html.AbortSignal;
		};
		var AbstractRange : {
			var prototype : js.html.AbstractRange;
		};
		/**
			A node able to provide real-time frequency and time-domain analysis information. It is an AudioNode that passes the audio stream unchanged from the input to the output, but allows you to take the generated data, process it, and create audio visualizations.
		**/
		var AnalyserNode : {
			var prototype : js.html.audio.AnalyserNode;
		};
		var Animation : {
			var prototype : js.html.Animation;
		};
		var AnimationEffect : {
			var prototype : js.html.AnimationEffect;
		};
		/**
			Events providing information related to animations.
		**/
		var AnimationEvent : {
			var prototype : js.html.AnimationEvent;
		};
		var AnimationPlaybackEvent : {
			var prototype : js.html.AnimationPlaybackEvent;
		};
		var AnimationTimeline : {
			var prototype : js.html.AnimationTimeline;
		};
		var ApplicationCache : {
			var prototype : js.html.ApplicationCache;
			final CHECKING : Float;
			final DOWNLOADING : Float;
			final IDLE : Float;
			final OBSOLETE : Float;
			final UNCACHED : Float;
			final UPDATEREADY : Float;
		};
		/**
			A DOM element's attribute as an object. In most DOM methods, you will probably directly retrieve the attribute as a string (e.g., Element.getAttribute(), but certain functions (e.g., Element.getAttributeNode()) or means of iterating give Attr types.
		**/
		var Attr : {
			var prototype : js.html.Attr;
		};
		/**
			A short audio asset residing in memory, created from an audio file using the AudioContext.decodeAudioData() method, or from raw data using AudioContext.createBuffer(). Once put into an AudioBuffer, the audio can then be played by being passed into an AudioBufferSourceNode.
		**/
		var AudioBuffer : {
			var prototype : js.html.audio.AudioBuffer;
		};
		/**
			An AudioScheduledSourceNode which represents an audio source consisting of in-memory audio data, stored in an AudioBuffer. It's especially useful for playing back audio which has particularly stringent timing accuracy requirements, such as for sounds that must match a specific rhythm and can be kept in memory rather than being played from disk or the network.
		**/
		var AudioBufferSourceNode : {
			var prototype : js.html.audio.AudioBufferSourceNode;
		};
		/**
			An audio-processing graph built from audio modules linked together, each represented by an AudioNode.
		**/
		var AudioContext : {
			var prototype : js.html.audio.AudioContext;
		};
		/**
			AudioDestinationNode has no output (as it is the output, no more AudioNode can be linked after it in the audio graph) and one input. The number of channels in the input must be between 0 and the maxChannelCount value or an exception is raised.
		**/
		var AudioDestinationNode : {
			var prototype : js.html.audio.AudioDestinationNode;
		};
		/**
			The position and orientation of the unique person listening to the audio scene, and is used in audio spatialization. All PannerNodes spatialize in relation to the AudioListener stored in the BaseAudioContext.listener attribute.
		**/
		var AudioListener : {
			var prototype : js.html.audio.AudioListener;
		};
		/**
			A generic interface for representing an audio processing module. Examples include:
		**/
		var AudioNode : {
			var prototype : js.html.audio.AudioNode;
		};
		/**
			The Web Audio API's AudioParam interface represents an audio-related parameter, usually a parameter of an AudioNode (such as GainNode.gain).
		**/
		var AudioParam : {
			var prototype : js.html.audio.AudioParam;
		};
		var AudioParamMap : {
			var prototype : js.html.AudioParamMap;
		};
		/**
			The Web Audio API events that occur when a ScriptProcessorNode input buffer is ready to be processed.
		**/
		var AudioProcessingEvent : {
			var prototype : js.html.audio.AudioProcessingEvent;
		};
		var AudioScheduledSourceNode : {
			var prototype : js.html.audio.AudioScheduledSourceNode;
		};
		/**
			A single audio track from one of the HTML media elements, <audio> or <video>.
		**/
		var AudioTrack : {
			var prototype : js.html.AudioTrack;
		};
		/**
			Used to represent a list of the audio tracks contained within a given HTML media element, with each track represented by a separate AudioTrack object in the list.
		**/
		var AudioTrackList : {
			var prototype : js.html.AudioTrackList;
		};
		var AudioWorklet : {
			var prototype : js.html.AudioWorklet;
		};
		var AudioWorkletNode : {
			var prototype : js.html.AudioWorkletNode;
		};
		var AuthenticatorAssertionResponse : {
			var prototype : js.html.AuthenticatorAssertionResponse;
		};
		var AuthenticatorAttestationResponse : {
			var prototype : js.html.AuthenticatorAttestationResponse;
		};
		var AuthenticatorResponse : {
			var prototype : js.html.AuthenticatorResponse;
		};
		var BarProp : {
			var prototype : js.html.BarProp;
		};
		var BaseAudioContext : {
			var prototype : js.html.audio.BaseAudioContext;
		};
		/**
			The beforeunload event is fired when the window, the document and its resources are about to be unloaded.
		**/
		var BeforeUnloadEvent : {
			var prototype : js.html.BeforeUnloadEvent;
		};
		var BhxBrowser : {
			var prototype : js.html.BhxBrowser;
		};
		/**
			A simple low-order filter, and is created using the AudioContext.createBiquadFilter() method. It is an AudioNode that can represent different kinds of filters, tone control devices, and graphic equalizers.
		**/
		var BiquadFilterNode : {
			var prototype : js.html.audio.BiquadFilterNode;
		};
		/**
			A file-like object of immutable, raw data. Blobs represent data that isn't necessarily in a JavaScript-native format. The File interface is based on Blob, inheriting blob functionality and expanding it to support files on the user's system.
		**/
		var Blob : {
			var prototype : js.html.Blob;
		};
		var BroadcastChannel : {
			var prototype : js.html.BroadcastChannel;
		};
		/**
			This Streams API interface provides a built-in byte length queuing strategy that can be used when constructing streams.
		**/
		var ByteLengthQueuingStrategy : {
			var prototype : js.html.ByteLengthQueuingStrategy;
		};
		/**
			A CDATA section that can be used within XML to include extended portions of unescaped text. The symbols < and & don’t need escaping as they normally do when inside a CDATA section.
		**/
		var CDATASection : {
			var prototype : js.html.CDATASection;
		};
		/**
			Holds useful CSS-related methods. No object with this interface are implemented: it contains only static methods and therefore is a utilitarian interface.
		**/
		var CSS : js.html.CSS;
		/**
			A single condition CSS at-rule, which consists of a condition and a statement block. It is a child of CSSGroupingRule.
		**/
		var CSSConditionRule : {
			var prototype : js.html.CSSConditionRule;
		};
		var CSSFontFaceRule : {
			var prototype : js.html.CSSFontFaceRule;
		};
		/**
			Any CSS at-rule that contains other rules nested within it.
		**/
		var CSSGroupingRule : {
			var prototype : js.html.CSSGroupingRule;
		};
		var CSSImportRule : {
			var prototype : js.html.CSSImportRule;
		};
		/**
			An object representing a set of style for a given keyframe. It corresponds to the contains of a single keyframe of a @keyframes at-rule. It implements the CSSRule interface with a type value of 8 (CSSRule.KEYFRAME_RULE).
		**/
		var CSSKeyframeRule : {
			var prototype : js.html.CSSKeyframeRule;
		};
		/**
			An object representing a complete set of keyframes for a CSS animation. It corresponds to the contains of a whole @keyframes at-rule. It implements the CSSRule interface with a type value of 7 (CSSRule.KEYFRAMES_RULE).
		**/
		var CSSKeyframesRule : {
			var prototype : js.html.CSSKeyframesRule;
		};
		/**
			A single CSS @media rule. It implements the CSSConditionRule interface, and therefore the CSSGroupingRule and the CSSRule interface with a type value of 4 (CSSRule.MEDIA_RULE).
		**/
		var CSSMediaRule : {
			var prototype : js.html.CSSMediaRule;
		};
		/**
			An object representing a single CSS @namespace at-rule. It implements the CSSRule interface, with a type value of 10 (CSSRule.NAMESPACE_RULE).
		**/
		var CSSNamespaceRule : {
			var prototype : js.html.CSSNamespaceRule;
		};
		/**
			CSSPageRule is an interface representing a single CSS @page rule. It implements the CSSRule interface with a type value of 6 (CSSRule.PAGE_RULE).
		**/
		var CSSPageRule : {
			var prototype : js.html.CSSPageRule;
		};
		/**
			A single CSS rule. There are several types of rules, listed in the Type constants section below.
		**/
		var CSSRule : {
			var prototype : js.html.CSSRule;
			final CHARSET_RULE : Float;
			final FONT_FACE_RULE : Float;
			final IMPORT_RULE : Float;
			final KEYFRAMES_RULE : Float;
			final KEYFRAME_RULE : Float;
			final MEDIA_RULE : Float;
			final NAMESPACE_RULE : Float;
			final PAGE_RULE : Float;
			final STYLE_RULE : Float;
			final SUPPORTS_RULE : Float;
			final UNKNOWN_RULE : Float;
			final VIEWPORT_RULE : Float;
		};
		/**
			A CSSRuleList is an (indirect-modify only) array-like object containing an ordered collection of CSSRule objects.
		**/
		var CSSRuleList : {
			var prototype : js.html.CSSRuleList;
		};
		/**
			An object that is a CSS declaration block, and exposes style information and various style-related methods and properties.
		**/
		var CSSStyleDeclaration : {
			var prototype : js.html.CSSStyleDeclaration;
		};
		/**
			CSSStyleRule represents a single CSS style rule. It implements the CSSRule interface with a type value of 1 (CSSRule.STYLE_RULE).
		**/
		var CSSStyleRule : {
			var prototype : js.html.CSSStyleRule;
		};
		/**
			A single CSS style sheet. It inherits properties and methods from its parent, StyleSheet.
		**/
		var CSSStyleSheet : {
			var prototype : js.html.CSSStyleSheet;
		};
		/**
			An object representing a single CSS @supports at-rule. It implements the CSSConditionRule interface, and therefore the CSSRule and CSSGroupingRule interfaces with a type value of 12 (CSSRule.SUPPORTS_RULE).
		**/
		var CSSSupportsRule : {
			var prototype : js.html.CSSSupportsRule;
		};
		/**
			Provides a storage mechanism for Request / Response object pairs that are cached, for example as part of the ServiceWorker life cycle. Note that the Cache interface is exposed to windowed scopes as well as workers. You don't have to use it in conjunction with service workers, even though it is defined in the service worker spec.
		**/
		var Cache : {
			var prototype : js.html.Cache;
		};
		/**
			The storage for Cache objects.
		**/
		var CacheStorage : {
			var prototype : js.html.CacheStorage;
		};
		/**
			An opaque object describing a gradient. It is returned by the methods CanvasRenderingContext2D.createLinearGradient() or CanvasRenderingContext2D.createRadialGradient().
		**/
		var CanvasGradient : {
			var prototype : js.html.CanvasGradient;
		};
		/**
			An opaque object describing a pattern, based on an image, a canvas, or a video, created by the CanvasRenderingContext2D.createPattern() method.
		**/
		var CanvasPattern : {
			var prototype : js.html.CanvasPattern;
		};
		/**
			The CanvasRenderingContext2D interface, part of the Canvas API, provides the 2D rendering context for the drawing surface of a <canvas> element. It is used for drawing shapes, text, images, and other objects.
		**/
		var CanvasRenderingContext2D : {
			var prototype : js.html.CanvasRenderingContext2D;
		};
		var CaretPosition : {
			var prototype : js.html.CaretPosition;
		};
		/**
			The ChannelMergerNode interface, often used in conjunction with its opposite, ChannelSplitterNode, reunites different mono inputs into a single output. Each input is used to fill a channel of the output. This is useful for accessing each channels separately, e.g. for performing channel mixing where gain must be separately controlled on each channel.
		**/
		var ChannelMergerNode : {
			var prototype : js.html.audio.ChannelMergerNode;
		};
		/**
			The ChannelSplitterNode interface, often used in conjunction with its opposite, ChannelMergerNode, separates the different channels of an audio source into a set of mono outputs. This is useful for accessing each channel separately, e.g. for performing channel mixing where gain must be separately controlled on each channel.
		**/
		var ChannelSplitterNode : {
			var prototype : js.html.audio.ChannelSplitterNode;
		};
		/**
			The CharacterData abstract interface represents a Node object that contains characters. This is an abstract interface, meaning there aren't any object of type CharacterData: it is implemented by other interfaces, like Text, Comment, or ProcessingInstruction which aren't abstract.
		**/
		var CharacterData : {
			var prototype : js.html.CharacterData;
		};
		var ClientRect : {
			var prototype : js.html.ClientRect;
		};
		var ClientRectList : {
			var prototype : js.html.ClientRectList;
		};
		var Clipboard : {
			var prototype : js.html.Clipboard;
		};
		/**
			Events providing information related to modification of the clipboard, that is cut, copy, and paste events.
		**/
		var ClipboardEvent : {
			var prototype : js.html.ClipboardEvent;
		};
		/**
			A CloseEvent is sent to clients using WebSockets when the connection is closed. This is delivered to the listener indicated by the WebSocket object's onclose attribute.
		**/
		var CloseEvent : {
			var prototype : js.html.CloseEvent;
		};
		/**
			Textual notations within markup; although it is generally not visually shown, such comments are available to be read in the source view.
		**/
		var Comment : {
			var prototype : js.html.Comment;
		};
		/**
			The DOM CompositionEvent represents events that occur due to the user indirectly entering text.
		**/
		var CompositionEvent : {
			var prototype : js.html.CompositionEvent;
		};
		/**
			Provides access to the browser's debugging console (e.g. the Web Console in Firefox). The specifics of how it works varies from browser to browser, but there is a de facto set of features that are typically provided.
		**/
		var Console : {
			var prototype : js.html.Console;
		};
		var ConstantSourceNode : {
			var prototype : js.html.audio.ConstantSourceNode;
		};
		/**
			An AudioNode that performs a Linear Convolution on a given AudioBuffer, often used to achieve a reverb effect. A ConvolverNode always has exactly one input and one output.
		**/
		var ConvolverNode : {
			var prototype : js.html.audio.ConvolverNode;
		};
		/**
			This Streams API interface provides a built-in byte length queuing strategy that can be used when constructing streams.
		**/
		var CountQueuingStrategy : {
			var prototype : js.html.CountQueuingStrategy;
		};
		var Credential : {
			var prototype : js.html.Credential;
		};
		var CredentialsContainer : {
			var prototype : js.html.CredentialsContainer;
		};
		/**
			Basic cryptography features available in the current context. It allows access to a cryptographically strong random number generator and to cryptographic primitives.
		**/
		var Crypto : {
			var prototype : js.html.Crypto;
		};
		/**
			The CryptoKey dictionary of the Web Crypto API represents a cryptographic key.
		**/
		var CryptoKey : {
			var prototype : js.html.CryptoKey;
		};
		/**
			The CryptoKeyPair dictionary of the Web Crypto API represents a key pair for an asymmetric cryptography algorithm, also known as a public-key algorithm.
		**/
		var CryptoKeyPair : {
			var prototype : js.html.CryptoKeyPair;
		};
		var CustomElementRegistry : {
			var prototype : js.html.CustomElementRegistry;
		};
		var CustomEvent : {
			var prototype : js.html.CustomEvent<Dynamic>;
		};
		/**
			An error object that contains an error name.
		**/
		var DOMError : {
			var prototype : js.html.DOMError;
		};
		/**
			An abnormal event (called an exception) which occurs as a result of calling a method or accessing a property of a web API.
		**/
		var DOMException : {
			var prototype : js.html.DOMException;
			final ABORT_ERR : Float;
			final DATA_CLONE_ERR : Float;
			final DOMSTRING_SIZE_ERR : Float;
			final HIERARCHY_REQUEST_ERR : Float;
			final INDEX_SIZE_ERR : Float;
			final INUSE_ATTRIBUTE_ERR : Float;
			final INVALID_ACCESS_ERR : Float;
			final INVALID_CHARACTER_ERR : Float;
			final INVALID_MODIFICATION_ERR : Float;
			final INVALID_NODE_TYPE_ERR : Float;
			final INVALID_STATE_ERR : Float;
			final NAMESPACE_ERR : Float;
			final NETWORK_ERR : Float;
			final NOT_FOUND_ERR : Float;
			final NOT_SUPPORTED_ERR : Float;
			final NO_DATA_ALLOWED_ERR : Float;
			final NO_MODIFICATION_ALLOWED_ERR : Float;
			final QUOTA_EXCEEDED_ERR : Float;
			final SECURITY_ERR : Float;
			final SYNTAX_ERR : Float;
			final TIMEOUT_ERR : Float;
			final TYPE_MISMATCH_ERR : Float;
			final URL_MISMATCH_ERR : Float;
			final VALIDATION_ERR : Float;
			final WRONG_DOCUMENT_ERR : Float;
		};
		/**
			An object providing methods which are not dependent on any particular document. Such an object is returned by the Document.implementation property.
		**/
		var DOMImplementation : {
			var prototype : js.html.DOMImplementation;
		};
		var DOMMatrix : {
			var prototype : js.html.DOMMatrix;
			function fromFloat32Array(array32:js.lib.Float32Array):js.html.DOMMatrix;
			function fromFloat64Array(array64:js.lib.Float64Array):js.html.DOMMatrix;
			function fromMatrix(?other:js.html.DOMMatrixInit):js.html.DOMMatrix;
		};
		var SVGMatrix : {
			var prototype : js.html.DOMMatrix;
			function fromFloat32Array(array32:js.lib.Float32Array):js.html.DOMMatrix;
			function fromFloat64Array(array64:js.lib.Float64Array):js.html.DOMMatrix;
			function fromMatrix(?other:js.html.DOMMatrixInit):js.html.DOMMatrix;
		};
		var WebKitCSSMatrix : {
			var prototype : js.html.DOMMatrix;
			function fromFloat32Array(array32:js.lib.Float32Array):js.html.DOMMatrix;
			function fromFloat64Array(array64:js.lib.Float64Array):js.html.DOMMatrix;
			function fromMatrix(?other:js.html.DOMMatrixInit):js.html.DOMMatrix;
		};
		var DOMMatrixReadOnly : {
			var prototype : js.html.DOMMatrixReadOnly;
			function fromFloat32Array(array32:js.lib.Float32Array):js.html.DOMMatrixReadOnly;
			function fromFloat64Array(array64:js.lib.Float64Array):js.html.DOMMatrixReadOnly;
			function fromMatrix(?other:js.html.DOMMatrixInit):js.html.DOMMatrixReadOnly;
		};
		/**
			Provides the ability to parse XML or HTML source code from a string into a DOM Document.
		**/
		var DOMParser : {
			var prototype : js.html.DOMParser;
		};
		var DOMPoint : {
			var prototype : js.html.DOMPoint;
			function fromPoint(?other:js.html.DOMPointInit):js.html.DOMPoint;
		};
		var SVGPoint : {
			var prototype : js.html.DOMPoint;
			function fromPoint(?other:js.html.DOMPointInit):js.html.DOMPoint;
		};
		var DOMPointReadOnly : {
			var prototype : js.html.DOMPointReadOnly;
			function fromPoint(?other:js.html.DOMPointInit):js.html.DOMPointReadOnly;
		};
		var DOMQuad : {
			var prototype : js.html.DOMQuad;
			function fromQuad(?other:js.html.DOMQuadInit):js.html.DOMQuad;
			function fromRect(?other:js.html.DOMRectInit):js.html.DOMQuad;
		};
		var DOMRect : {
			var prototype : js.html.DOMRect;
			function fromRect(?other:js.html.DOMRectInit):js.html.DOMRect;
		};
		var SVGRect : {
			var prototype : js.html.DOMRect;
			function fromRect(?other:js.html.DOMRectInit):js.html.DOMRect;
		};
		var DOMRectList : {
			var prototype : js.html.DOMRectList;
		};
		var DOMRectReadOnly : {
			var prototype : js.html.DOMRectReadOnly;
			function fromRect(?other:js.html.DOMRectInit):js.html.DOMRectReadOnly;
		};
		var DOMSettableTokenList : {
			var prototype : js.html.DOMSettableTokenList;
		};
		/**
			A type returned by some APIs which contains a list of DOMString (strings).
		**/
		var DOMStringList : {
			var prototype : js.html.DOMStringList;
		};
		/**
			Used by the dataset HTML attribute to represent data for custom attributes added to elements.
		**/
		var DOMStringMap : {
			var prototype : js.html.DOMStringMap;
		};
		/**
			A set of space-separated tokens. Such a set is returned by Element.classList, HTMLLinkElement.relList, HTMLAnchorElement.relList, HTMLAreaElement.relList, HTMLIframeElement.sandbox, or HTMLOutputElement.htmlFor. It is indexed beginning with 0 as with JavaScript Array objects. DOMTokenList is always case-sensitive.
		**/
		var DOMTokenList : {
			var prototype : js.html.DOMTokenList;
		};
		var DataCue : {
			var prototype : js.html.DataCue;
		};
		/**
			Used to hold the data that is being dragged during a drag and drop operation. It may hold one or more data items, each of one or more data types. For more information about drag and drop, see HTML Drag and Drop API.
		**/
		var DataTransfer : {
			var prototype : js.html.DataTransfer;
		};
		/**
			One drag data item. During a drag operation, each drag event has a dataTransfer property which contains a list of drag data items. Each item in the list is a DataTransferItem object.
		**/
		var DataTransferItem : {
			var prototype : js.html.DataTransferItem;
		};
		/**
			A list of DataTransferItem objects representing items being dragged. During a drag operation, each DragEvent has a dataTransfer property and that property is a DataTransferItemList.
		**/
		var DataTransferItemList : {
			var prototype : js.html.DataTransferItemList;
		};
		var DeferredPermissionRequest : {
			var prototype : js.html.DeferredPermissionRequest;
		};
		/**
			A delay-line; an AudioNode audio-processing module that causes a delay between the arrival of an input data and its propagation to the output.
		**/
		var DelayNode : {
			var prototype : js.html.audio.DelayNode;
		};
		/**
			Provides information about the amount of acceleration the device is experiencing along all three axes.
		**/
		var DeviceAcceleration : {
			var prototype : js.html.DeviceAcceleration;
		};
		/**
			The DeviceLightEvent provides web developers with information from photo sensors or similiar detectors about ambient light levels near the device. For example this may be useful to adjust the screen's brightness based on the current ambient light level in order to save energy or provide better readability.
		**/
		var DeviceLightEvent : {
			var prototype : js.html.DeviceLightEvent;
		};
		/**
			The DeviceMotionEvent provides web developers with information about the speed of changes for the device's position and orientation.
		**/
		var DeviceMotionEvent : {
			var prototype : js.html.DeviceMotionEvent;
		};
		/**
			The DeviceOrientationEvent provides web developers with information from the physical orientation of the device running the web page.
		**/
		var DeviceOrientationEvent : {
			var prototype : js.html.DeviceOrientationEvent;
		};
		/**
			Provides information about the rate at which the device is rotating around all three axes.
		**/
		var DeviceRotationRate : {
			var prototype : js.html.DeviceRotationRate;
		};
		/**
			Any web page loaded in the browser and serves as an entry point into the web page's content, which is the DOM tree.
		**/
		var Document : {
			var prototype : js.html.Document;
		};
		/**
			A minimal document object that has no parent. It is used as a lightweight version of Document that stores a segment of a document structure comprised of nodes just like a standard document. The key difference is that because the document fragment isn't part of the active document tree structure, changes made to the fragment don't affect the document, cause reflow, or incur any performance impact that can occur when changes are made.
		**/
		var DocumentFragment : {
			var prototype : js.html.DocumentFragment;
		};
		var DocumentTimeline : {
			var prototype : js.html.DocumentTimeline;
		};
		/**
			A Node containing a doctype.
		**/
		var DocumentType : {
			var prototype : js.html.DocumentType;
		};
		/**
			A DOM event that represents a drag and drop interaction. The user initiates a drag by placing a pointer device (such as a mouse) on the touch surface and then dragging the pointer to a new location (such as another DOM element). Applications are free to interpret a drag and drop interaction in an application-specific way.
		**/
		var DragEvent : {
			var prototype : js.html.DragEvent;
		};
		/**
			Inherits properties from its parent, AudioNode.
		**/
		var DynamicsCompressorNode : {
			var prototype : js.html.audio.DynamicsCompressorNode;
		};
		/**
			Element is the most general base class from which all objects in a Document inherit. It only has methods and properties common to all kinds of elements. More specific classes inherit from Element.
		**/
		var Element : {
			var prototype : js.html.DOMElement;
		};
		/**
			Events providing information related to errors in scripts or in files.
		**/
		var ErrorEvent : {
			var prototype : js.html.ErrorEvent;
		};
		/**
			An event which takes place in the DOM.
		**/
		var Event : {
			var prototype : js.html.Event;
			final AT_TARGET : Float;
			final BUBBLING_PHASE : Float;
			final CAPTURING_PHASE : Float;
			final NONE : Float;
		};
		var EventSource : {
			var prototype : js.html.EventSource;
			final CLOSED : Float;
			final CONNECTING : Float;
			final OPEN : Float;
		};
		/**
			EventTarget is a DOM interface implemented by objects that can receive events and may have listeners for them.
		**/
		var EventTarget : {
			var prototype : js.html.EventTarget;
		};
		var ExtensionScriptApis : {
			var prototype : js.html.ExtensionScriptApis;
		};
		var External : {
			var prototype : js.html.External;
		};
		/**
			Provides information about files and allows JavaScript in a web page to access their content.
		**/
		var File : {
			var prototype : js.html.File;
		};
		/**
			An object of this type is returned by the files property of the HTML <input> element; this lets you access the list of files selected with the <input type="file"> element. It's also used for a list of files dropped into web content when using the drag and drop API; see the DataTransfer object for details on this usage.
		**/
		var FileList : {
			var prototype : js.html.FileList;
		};
		/**
			Lets web applications asynchronously read the contents of files (or raw data buffers) stored on the user's computer, using File or Blob objects to specify the file or data to read.
		**/
		var FileReader : {
			var prototype : js.html.FileReader;
			final DONE : Float;
			final EMPTY : Float;
			final LOADING : Float;
		};
		/**
			Focus-related events like focus, blur, focusin, or focusout.
		**/
		var FocusEvent : {
			var prototype : js.html.FocusEvent;
		};
		var FocusNavigationEvent : {
			var prototype : js.html.FocusNavigationEvent;
		};
		/**
			Provides a way to easily construct a set of key/value pairs representing form fields and their values, which can then be easily sent using the XMLHttpRequest.send() method. It uses the same format a form would use if the encoding type were set to "multipart/form-data".
		**/
		var FormData : {
			var prototype : js.html.FormData;
		};
		/**
			A change in volume. It is an AudioNode audio-processing module that causes a given gain to be applied to the input data before its propagation to the output. A GainNode always has exactly one input and one output, both with the same number of channels.
		**/
		var GainNode : {
			var prototype : js.html.audio.GainNode;
		};
		/**
			This Gamepad API interface defines an individual gamepad or other controller, allowing access to information such as button presses, axis positions, and id.
		**/
		var Gamepad : {
			var prototype : js.html.Gamepad;
		};
		/**
			An individual button of a gamepad or other controller, allowing access to the current state of different types of buttons available on the control device.
		**/
		var GamepadButton : {
			var prototype : js.html.GamepadButton;
		};
		/**
			This Gamepad API interface contains references to gamepads connected to the system, which is what the gamepad events Window.gamepadconnected and Window.gamepaddisconnected are fired in response to.
		**/
		var GamepadEvent : {
			var prototype : js.html.GamepadEvent;
		};
		/**
			This Gamepad API interface represents hardware in the controller designed to provide haptic feedback to the user (if available), most commonly vibration hardware.
		**/
		var GamepadHapticActuator : {
			var prototype : js.html.GamepadHapticActuator;
		};
		/**
			This Gamepad API interface represents the pose of a WebVR controller at a given timestamp (which includes orientation, position, velocity, and acceleration information.)
		**/
		var GamepadPose : {
			var prototype : js.html.GamepadPose;
		};
		var HTMLAllCollection : {
			var prototype : js.html.HTMLAllCollection;
		};
		/**
			Hyperlink elements and provides special properties and methods (beyond those of the regular HTMLElement object interface that they inherit from) for manipulating the layout and presentation of such elements.
		**/
		var HTMLAnchorElement : {
			var prototype : js.html.AnchorElement;
		};
		var HTMLAppletElement : {
			var prototype : js.html.HTMLAppletElement;
		};
		/**
			Provides special properties and methods (beyond those of the regular object HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of <area> elements.
		**/
		var HTMLAreaElement : {
			var prototype : js.html.AreaElement;
		};
		/**
			Provides access to the properties of <audio> elements, as well as methods to manipulate them. It derives from the HTMLMediaElement interface.
		**/
		var HTMLAudioElement : {
			var prototype : js.html.AudioElement;
		};
		/**
			A HTML line break element (<br>). It inherits from HTMLElement.
		**/
		var HTMLBRElement : {
			var prototype : js.html.BRElement;
		};
		/**
			Contains the base URI for a document. This object inherits all of the properties and methods as described in the HTMLElement interface.
		**/
		var HTMLBaseElement : {
			var prototype : js.html.BaseElement;
		};
		/**
			Provides special properties (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating <basefont> elements.
		**/
		var HTMLBaseFontElement : {
			var prototype : js.html.HTMLBaseFontElement;
		};
		/**
			Provides special properties (beyond those inherited from the regular HTMLElement interface) for manipulating <body> elements.
		**/
		var HTMLBodyElement : {
			var prototype : js.html.BodyElement;
		};
		/**
			Provides properties and methods (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating <button> elements.
		**/
		var HTMLButtonElement : {
			var prototype : js.html.ButtonElement;
		};
		/**
			Provides properties and methods for manipulating the layout and presentation of <canvas> elements. The HTMLCanvasElement interface also inherits the properties and methods of the HTMLElement interface.
		**/
		var HTMLCanvasElement : {
			var prototype : js.html.CanvasElement;
		};
		var HTMLCollection : {
			var prototype : js.html.HTMLCollection;
		};
		/**
			Provides special properties (beyond those of the regular HTMLElement interface it also has available to it by inheritance) for manipulating definition list (<dl>) elements.
		**/
		var HTMLDListElement : {
			var prototype : js.html.DListElement;
		};
		/**
			Provides special properties (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating <data> elements.
		**/
		var HTMLDataElement : {
			var prototype : js.html.DataElement;
		};
		/**
			Provides special properties (beyond the HTMLElement object interface it also has available to it by inheritance) to manipulate <datalist> elements and their content.
		**/
		var HTMLDataListElement : {
			var prototype : js.html.DataListElement;
		};
		var HTMLDetailsElement : {
			var prototype : js.html.DetailsElement;
		};
		var HTMLDialogElement : {
			var prototype : js.html.HTMLDialogElement;
		};
		var HTMLDirectoryElement : {
			var prototype : js.html.DirectoryElement;
		};
		/**
			Provides special properties (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating <div> elements.
		**/
		var HTMLDivElement : {
			var prototype : js.html.DivElement;
		};
		/**
			The HTMLDocument property of Window objects is an alias that browsers expose for the Document interface object.
		**/
		var HTMLDocument : {
			var prototype : js.html.HTMLDocument;
		};
		/**
			Any HTML element. Some elements directly implement this interface, while others implement it via an interface that inherits it.
		**/
		var HTMLElement : {
			var prototype : js.html.Element;
		};
		/**
			Provides special properties (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating <embed> elements.
		**/
		var HTMLEmbedElement : {
			var prototype : js.html.EmbedElement;
		};
		/**
			Provides special properties and methods (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of <fieldset> elements.
		**/
		var HTMLFieldSetElement : {
			var prototype : js.html.FieldSetElement;
		};
		/**
			Implements the document object model (DOM) representation of the font element. The HTML Font Element <font> defines the font size, font face and color of text.
		**/
		var HTMLFontElement : {
			var prototype : js.html.FontElement;
		};
		/**
			A collection of HTML form control elements.
		**/
		var HTMLFormControlsCollection : {
			var prototype : js.html.HTMLFormControlsCollection;
		};
		/**
			A <form> element in the DOM; it allows access to and in some cases modification of aspects of the form, as well as access to its component elements.
		**/
		var HTMLFormElement : {
			var prototype : js.html.FormElement;
		};
		var HTMLFrameElement : {
			var prototype : js.html.FrameElement;
		};
		/**
			Provides special properties (beyond those of the regular HTMLElement interface they also inherit) for manipulating <frameset> elements.
		**/
		var HTMLFrameSetElement : {
			var prototype : js.html.FrameSetElement;
		};
		/**
			Provides special properties (beyond those of the HTMLElement interface it also has available to it by inheritance) for manipulating <hr> elements.
		**/
		var HTMLHRElement : {
			var prototype : js.html.HRElement;
		};
		/**
			Contains the descriptive information, or metadata, for a document. This object inherits all of the properties and methods described in the HTMLElement interface.
		**/
		var HTMLHeadElement : {
			var prototype : js.html.HeadElement;
		};
		/**
			The different heading elements. It inherits methods and properties from the HTMLElement interface.
		**/
		var HTMLHeadingElement : {
			var prototype : js.html.HeadingElement;
		};
		/**
			Serves as the root node for a given HTML document. This object inherits the properties and methods described in the HTMLElement interface.
		**/
		var HTMLHtmlElement : {
			var prototype : js.html.HtmlElement;
		};
		/**
			Provides special properties and methods (beyond those of the HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of inline frame elements.
		**/
		var HTMLIFrameElement : {
			var prototype : js.html.IFrameElement;
		};
		/**
			Provides special properties and methods for manipulating <img> elements.
		**/
		var HTMLImageElement : {
			var prototype : js.html.ImageElement;
		};
		/**
			Provides special properties and methods for manipulating the options, layout, and presentation of <input> elements.
		**/
		var HTMLInputElement : {
			var prototype : js.html.InputElement;
		};
		/**
			Exposes specific properties and methods (beyond those defined by regular HTMLElement interface it also has available to it by inheritance) for manipulating list elements.
		**/
		var HTMLLIElement : {
			var prototype : js.html.LIElement;
		};
		/**
			Gives access to properties specific to <label> elements. It inherits methods and properties from the base HTMLElement interface.
		**/
		var HTMLLabelElement : {
			var prototype : js.html.LabelElement;
		};
		/**
			The HTMLLegendElement is an interface allowing to access properties of the <legend> elements. It inherits properties and methods from the HTMLElement interface.
		**/
		var HTMLLegendElement : {
			var prototype : js.html.LegendElement;
		};
		/**
			Reference information for external resources and the relationship of those resources to a document and vice-versa. This object inherits all of the properties and methods of the HTMLElement interface.
		**/
		var HTMLLinkElement : {
			var prototype : js.html.LinkElement;
		};
		/**
			Provides special properties and methods (beyond those of the regular object HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of map elements.
		**/
		var HTMLMapElement : {
			var prototype : js.html.MapElement;
		};
		/**
			Provides methods to manipulate <marquee> elements.
		**/
		var HTMLMarqueeElement : {
			var prototype : js.html.HTMLMarqueeElement;
		};
		/**
			Adds to HTMLElement the properties and methods needed to support basic media-related capabilities that are common to audio and video.
		**/
		var HTMLMediaElement : {
			var prototype : js.html.MediaElement;
			final HAVE_CURRENT_DATA : Float;
			final HAVE_ENOUGH_DATA : Float;
			final HAVE_FUTURE_DATA : Float;
			final HAVE_METADATA : Float;
			final HAVE_NOTHING : Float;
			final NETWORK_EMPTY : Float;
			final NETWORK_IDLE : Float;
			final NETWORK_LOADING : Float;
			final NETWORK_NO_SOURCE : Float;
		};
		var HTMLMenuElement : {
			var prototype : js.html.MenuElement;
		};
		/**
			Contains descriptive metadata about a document. It inherits all of the properties and methods described in the HTMLElement interface.
		**/
		var HTMLMetaElement : {
			var prototype : js.html.MetaElement;
		};
		/**
			The HTML <meter> elements expose the HTMLMeterElement interface, which provides special properties and methods (beyond the HTMLElement object interface they also have available to them by inheritance) for manipulating the layout and presentation of <meter> elements.
		**/
		var HTMLMeterElement : {
			var prototype : js.html.MeterElement;
		};
		/**
			Provides special properties (beyond the regular methods and properties available through the HTMLElement interface they also have available to them by inheritance) for manipulating modification elements, that is <del> and <ins>.
		**/
		var HTMLModElement : {
			var prototype : js.html.ModElement;
		};
		/**
			Provides special properties (beyond those defined on the regular HTMLElement interface it also has available to it by inheritance) for manipulating ordered list elements.
		**/
		var HTMLOListElement : {
			var prototype : js.html.OListElement;
		};
		/**
			Provides special properties and methods (beyond those on the HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of <object> element, representing external resources.
		**/
		var HTMLObjectElement : {
			var prototype : js.html.ObjectElement;
		};
		/**
			Provides special properties and methods (beyond the regular HTMLElement object interface they also have available to them by inheritance) for manipulating the layout and presentation of <optgroup> elements.
		**/
		var HTMLOptGroupElement : {
			var prototype : js.html.OptGroupElement;
		};
		/**
			<option> elements and inherits all classes and methods of the HTMLElement interface.
		**/
		var HTMLOptionElement : {
			var prototype : js.html.OptionElement;
		};
		/**
			HTMLOptionsCollection is an interface representing a collection of HTML option elements (in document order) and offers methods and properties for traversing the list as well as optionally altering its items. This type is returned solely by the "options" property of select.
		**/
		var HTMLOptionsCollection : {
			var prototype : js.html.HTMLOptionsCollection;
		};
		/**
			Provides properties and methods (beyond those inherited from HTMLElement) for manipulating the layout and presentation of <output> elements.
		**/
		var HTMLOutputElement : {
			var prototype : js.html.OutputElement;
		};
		/**
			Provides special properties (beyond those of the regular HTMLElement object interface it inherits) for manipulating <p> elements.
		**/
		var HTMLParagraphElement : {
			var prototype : js.html.ParagraphElement;
		};
		/**
			Provides special properties (beyond those of the regular HTMLElement object interface it inherits) for manipulating <param> elements, representing a pair of a key and a value that acts as a parameter for an <object> element.
		**/
		var HTMLParamElement : {
			var prototype : js.html.ParamElement;
		};
		/**
			A <picture> HTML element. It doesn't implement specific properties or methods.
		**/
		var HTMLPictureElement : {
			var prototype : js.html.PictureElement;
		};
		/**
			Exposes specific properties and methods (beyond those of the HTMLElement interface it also has available to it by inheritance) for manipulating a block of preformatted text (<pre>).
		**/
		var HTMLPreElement : {
			var prototype : js.html.PreElement;
		};
		/**
			Provides special properties and methods (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of <progress> elements.
		**/
		var HTMLProgressElement : {
			var prototype : js.html.ProgressElement;
		};
		/**
			Provides special properties and methods (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating quoting elements, like <blockquote> and <q>, but not the <cite> element.
		**/
		var HTMLQuoteElement : {
			var prototype : js.html.QuoteElement;
		};
		/**
			HTML <script> elements expose the HTMLScriptElement interface, which provides special properties and methods for manipulating the behavior and execution of <script> elements (beyond the inherited HTMLElement interface).
		**/
		var HTMLScriptElement : {
			var prototype : js.html.ScriptElement;
		};
		/**
			A <select> HTML Element. These elements also share all of the properties and methods of other HTML elements via the HTMLElement interface.
		**/
		var HTMLSelectElement : {
			var prototype : js.html.SelectElement;
		};
		var HTMLSlotElement : {
			var prototype : js.html.SlotElement;
		};
		/**
			Provides special properties (beyond the regular HTMLElement object interface it also has available to it by inheritance) for manipulating <source> elements.
		**/
		var HTMLSourceElement : {
			var prototype : js.html.SourceElement;
		};
		/**
			A <span> element and derives from the HTMLElement interface, but without implementing any additional properties or methods.
		**/
		var HTMLSpanElement : {
			var prototype : js.html.SpanElement;
		};
		/**
			A <style> element. It inherits properties and methods from its parent, HTMLElement, and from LinkStyle.
		**/
		var HTMLStyleElement : {
			var prototype : js.html.StyleElement;
		};
		/**
			Special properties (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating table caption elements.
		**/
		var HTMLTableCaptionElement : {
			var prototype : js.html.TableCaptionElement;
		};
		/**
			Provides special properties and methods (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of table cells, either header or data cells, in an HTML document.
		**/
		var HTMLTableCellElement : {
			var prototype : js.html.TableCellElement;
		};
		/**
			Provides special properties (beyond the HTMLElement interface it also has available to it inheritance) for manipulating single or grouped table column elements.
		**/
		var HTMLTableColElement : {
			var prototype : js.html.TableColElement;
		};
		var HTMLTableDataCellElement : {
			var prototype : js.html.HTMLTableDataCellElement;
		};
		/**
			Provides special properties and methods (beyond the regular HTMLElement object interface it also has available to it by inheritance) for manipulating the layout and presentation of tables in an HTML document.
		**/
		var HTMLTableElement : {
			var prototype : js.html.TableElement;
		};
		var HTMLTableHeaderCellElement : {
			var prototype : js.html.HTMLTableHeaderCellElement;
		};
		/**
			Provides special properties and methods (beyond the HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of rows in an HTML table.
		**/
		var HTMLTableRowElement : {
			var prototype : js.html.TableRowElement;
		};
		/**
			Provides special properties and methods (beyond the HTMLElement interface it also has available to it by inheritance) for manipulating the layout and presentation of sections, that is headers, footers and bodies, in an HTML table.
		**/
		var HTMLTableSectionElement : {
			var prototype : js.html.TableSectionElement;
		};
		/**
			Enables access to the contents of an HTML <template> element.
		**/
		var HTMLTemplateElement : {
			var prototype : js.html.TemplateElement;
		};
		/**
			Provides special properties and methods for manipulating the layout and presentation of <textarea> elements.
		**/
		var HTMLTextAreaElement : {
			var prototype : js.html.TextAreaElement;
		};
		/**
			Provides special properties (beyond the regular HTMLElement interface it also has available to it by inheritance) for manipulating <time> elements.
		**/
		var HTMLTimeElement : {
			var prototype : js.html.TimeElement;
		};
		/**
			Contains the title for a document. This element inherits all of the properties and methods of the HTMLElement interface.
		**/
		var HTMLTitleElement : {
			var prototype : js.html.TitleElement;
		};
		/**
			The HTMLTrackElement
		**/
		var HTMLTrackElement : {
			var prototype : js.html.TrackElement;
			final ERROR : Float;
			final LOADED : Float;
			final LOADING : Float;
			final NONE : Float;
		};
		/**
			Provides special properties (beyond those defined on the regular HTMLElement interface it also has available to it by inheritance) for manipulating unordered list elements.
		**/
		var HTMLUListElement : {
			var prototype : js.html.UListElement;
		};
		/**
			An invalid HTML element and derives from the HTMLElement interface, but without implementing any additional properties or methods.
		**/
		var HTMLUnknownElement : {
			var prototype : js.html.UnknownElement;
		};
		/**
			Provides special properties and methods for manipulating video objects. It also inherits properties and methods of HTMLMediaElement and HTMLElement.
		**/
		var HTMLVideoElement : {
			var prototype : js.html.VideoElement;
		};
		/**
			Events that fire when the fragment identifier of the URL has changed.
		**/
		var HashChangeEvent : {
			var prototype : js.html.HashChangeEvent;
		};
		/**
			This Fetch API interface allows you to perform various actions on HTTP request and response headers. These actions include retrieving, setting, adding to, and removing. A Headers object has an associated header list, which is initially empty and consists of zero or more name and value pairs.  You can add to this using methods like append() (see Examples.) In all methods of this interface, header names are matched by case-insensitive byte sequence.
		**/
		var Headers : {
			var prototype : js.html.Headers;
		};
		/**
			Allows manipulation of the browser session history, that is the pages visited in the tab or frame that the current page is loaded in.
		**/
		var History : {
			var prototype : js.html.History;
		};
		/**
			This IndexedDB API interface represents a cursor for traversing or iterating over multiple records in a database.
		**/
		var IDBCursor : {
			var prototype : js.html.idb.Cursor;
		};
		/**
			This IndexedDB API interface represents a cursor for traversing or iterating over multiple records in a database. It is the same as the IDBCursor, except that it includes the value property.
		**/
		var IDBCursorWithValue : {
			var prototype : js.html.idb.CursorWithValue;
		};
		/**
			This IndexedDB API interface provides a connection to a database; you can use an IDBDatabase object to open a transaction on your database then create, manipulate, and delete objects (data) in that database. The interface provides the only way to get and manage versions of the database.
		**/
		var IDBDatabase : {
			var prototype : js.html.idb.Database;
		};
		/**
			In the following code snippet, we make a request to open a database, and include handlers for the success and error cases. For a full working example, see our To-do Notifications app (view example live.)
		**/
		var IDBFactory : {
			var prototype : js.html.idb.Factory;
		};
		/**
			IDBIndex interface of the IndexedDB API provides asynchronous access to an index in a database. An index is a kind of object store for looking up records in another object store, called the referenced object store. You use this interface to retrieve data.
		**/
		var IDBIndex : {
			var prototype : js.html.idb.Index;
		};
		/**
			A key range can be a single value or a range with upper and lower bounds or endpoints. If the key range has both upper and lower bounds, then it is bounded; if it has no bounds, it is unbounded. A bounded key range can either be open (the endpoints are excluded) or closed (the endpoints are included). To retrieve all keys within a certain range, you can use the following code constructs:
		**/
		var IDBKeyRange : {
			var prototype : js.html.idb.KeyRange;
			/**
				Returns a new IDBKeyRange spanning from lower to upper. If lowerOpen is true, lower is not included in the range. If upperOpen is true, upper is not included in the range.
			**/
			function bound(lower:Dynamic, upper:Dynamic, ?lowerOpen:Bool, ?upperOpen:Bool):js.html.idb.KeyRange;
			/**
				Returns a new IDBKeyRange starting at key with no upper bound. If open is true, key is not included in the range.
			**/
			function lowerBound(lower:Dynamic, ?open:Bool):js.html.idb.KeyRange;
			/**
				Returns a new IDBKeyRange spanning only key.
			**/
			function only(value:Dynamic):js.html.idb.KeyRange;
			/**
				Returns a new IDBKeyRange with no lower bound and ending at key. If open is true, key is not included in the range.
			**/
			function upperBound(upper:Dynamic, ?open:Bool):js.html.idb.KeyRange;
		};
		/**
			This example shows a variety of different uses of object stores, from updating the data structure with IDBObjectStore.createIndex inside an onupgradeneeded function, to adding a new item to our object store with IDBObjectStore.add. For a full working example, see our To-do Notifications app (view example live.)
		**/
		var IDBObjectStore : {
			var prototype : js.html.idb.ObjectStore;
		};
		/**
			Also inherits methods from its parents IDBRequest and EventTarget.
		**/
		var IDBOpenDBRequest : {
			var prototype : js.html.idb.OpenDBRequest;
		};
		/**
			The request object does not initially contain any information about the result of the operation, but once information becomes available, an event is fired on the request, and the information becomes available through the properties of the IDBRequest instance.
		**/
		var IDBRequest : {
			var prototype : js.html.IDBRequest<Dynamic>;
		};
		var IDBTransaction : {
			var prototype : js.html.idb.Transaction;
		};
		/**
			This IndexedDB API interface indicates that the version of the database has changed, as the result of an IDBOpenDBRequest.onupgradeneeded event handler function.
		**/
		var IDBVersionChangeEvent : {
			var prototype : js.html.idb.VersionChangeEvent;
		};
		/**
			The IIRFilterNode interface of the Web Audio API is a AudioNode processor which implements a general infinite impulse response (IIR)  filter; this type of filter can be used to implement tone control devices and graphic equalizers as well. It lets the parameters of the filter response be specified, so that it can be tuned as needed.
		**/
		var IIRFilterNode : {
			var prototype : js.html.audio.IIRFilterNode;
		};
		var ImageBitmap : {
			var prototype : js.html.ImageBitmap;
		};
		var ImageBitmapRenderingContext : {
			var prototype : js.html.ImageBitmapRenderingContext;
		};
		/**
			The underlying pixel data of an area of a <canvas> element. It is created using the ImageData() constructor or creator methods on the CanvasRenderingContext2D object associated with a canvas: createImageData() and getImageData(). It can also be used to set a part of the canvas by using putImageData().
		**/
		var ImageData : {
			var prototype : js.html.ImageData;
		};
		var InputDeviceInfo : {
			var prototype : js.html.InputDeviceInfo;
		};
		var InputEvent : {
			var prototype : js.html.InputEvent;
		};
		/**
			provides a way to asynchronously observe changes in the intersection of a target element with an ancestor element or with a top-level document's viewport.
		**/
		var IntersectionObserver : {
			var prototype : js.html.IntersectionObserver;
		};
		/**
			This Intersection Observer API interface describes the intersection between the target element and its root container at a specific moment of transition.
		**/
		var IntersectionObserverEntry : {
			var prototype : js.html.IntersectionObserverEntry;
		};
		/**
			KeyboardEvent objects describe a user interaction with the keyboard; each event describes a single interaction between the user and a key (or combination of a key with modifier keys) on the keyboard.
		**/
		var KeyboardEvent : {
			var prototype : js.html.KeyboardEvent;
			final DOM_KEY_LOCATION_LEFT : Float;
			final DOM_KEY_LOCATION_NUMPAD : Float;
			final DOM_KEY_LOCATION_RIGHT : Float;
			final DOM_KEY_LOCATION_STANDARD : Float;
		};
		var KeyframeEffect : {
			var prototype : js.html.KeyframeEffect;
		};
		var ListeningStateChangedEvent : {
			var prototype : js.html.ListeningStateChangedEvent;
		};
		/**
			The location (URL) of the object it is linked to. Changes done on it are reflected on the object it relates to. Both the Document and Window interface have such a linked Location, accessible via Document.location and Window.location respectively.
		**/
		var Location : {
			var prototype : js.html.Location;
		};
		var MSAssertion : {
			var prototype : js.html.MSAssertion;
		};
		var MSBlobBuilder : {
			var prototype : js.html.MSBlobBuilder;
		};
		var MSFIDOCredentialAssertion : {
			var prototype : js.html.MSFIDOCredentialAssertion;
		};
		var MSFIDOSignature : {
			var prototype : js.html.MSFIDOSignature;
		};
		var MSFIDOSignatureAssertion : {
			var prototype : js.html.MSFIDOSignatureAssertion;
		};
		var MSGesture : {
			var prototype : js.html.MSGesture;
		};
		/**
			The MSGestureEvent is a proprietary interface specific to Internet Explorer and Microsoft Edge which represents events that occur due to touch gestures. Events using this interface include MSGestureStart, MSGestureEnd, MSGestureTap, MSGestureHold, MSGestureChange, and MSInertiaStart.
		**/
		var MSGestureEvent : {
			var prototype : js.html.MSGestureEvent;
			final MSGESTURE_FLAG_BEGIN : Float;
			final MSGESTURE_FLAG_CANCEL : Float;
			final MSGESTURE_FLAG_END : Float;
			final MSGESTURE_FLAG_INERTIA : Float;
			final MSGESTURE_FLAG_NONE : Float;
		};
		/**
			The msGraphicsTrust() constructor returns an object that provides properties for info on protected video playback.
		**/
		var MSGraphicsTrust : {
			var prototype : js.html.MSGraphicsTrust;
		};
		var MSInputMethodContext : {
			var prototype : js.html.MSInputMethodContext;
		};
		var MSMediaKeyError : {
			var prototype : js.html.MSMediaKeyError;
			final MS_MEDIA_KEYERR_CLIENT : Float;
			final MS_MEDIA_KEYERR_DOMAIN : Float;
			final MS_MEDIA_KEYERR_HARDWARECHANGE : Float;
			final MS_MEDIA_KEYERR_OUTPUT : Float;
			final MS_MEDIA_KEYERR_SERVICE : Float;
			final MS_MEDIA_KEYERR_UNKNOWN : Float;
		};
		var MSMediaKeyMessageEvent : {
			var prototype : js.html.MSMediaKeyMessageEvent;
		};
		var MSMediaKeyNeededEvent : {
			var prototype : js.html.MSMediaKeyNeededEvent;
		};
		var MSMediaKeySession : {
			var prototype : js.html.MSMediaKeySession;
		};
		var MSMediaKeys : {
			var prototype : js.html.MSMediaKeys;
			function isTypeSupported(keySystem:String, ?type:String):Bool;
			function isTypeSupportedWithFeatures(keySystem:String, ?type:String):String;
		};
		var MSPointerEvent : {
			var prototype : js.html.MSPointerEvent;
		};
		var MSStream : {
			var prototype : js.html.MSStream;
		};
		/**
			The MediaDevicesInfo interface contains information that describes a single media input or output device.
		**/
		var MediaDeviceInfo : {
			var prototype : js.html.MediaDeviceInfo;
		};
		/**
			Provides access to connected media input devices like cameras and microphones, as well as screen sharing. In essence, it lets you obtain access to any hardware source of media data.
		**/
		var MediaDevices : {
			var prototype : js.html.MediaDevices;
		};
		/**
			A MediaElementSourceNode has no inputs and exactly one output, and is created using the AudioContext.createMediaElementSource method. The amount of channels in the output equals the number of channels of the audio referenced by the HTMLMediaElement used in the creation of the node, or is 1 if the HTMLMediaElement has no audio.
		**/
		var MediaElementAudioSourceNode : {
			var prototype : js.html.audio.MediaElementAudioSourceNode;
		};
		var MediaEncryptedEvent : {
			var prototype : js.html.eme.MediaEncryptedEvent;
		};
		/**
			An error which occurred while handling media in an HTML media element based on HTMLMediaElement, such as <audio> or <video>.
		**/
		var MediaError : {
			var prototype : js.html.MediaError;
			final MEDIA_ERR_ABORTED : Float;
			final MEDIA_ERR_DECODE : Float;
			final MEDIA_ERR_NETWORK : Float;
			final MEDIA_ERR_SRC_NOT_SUPPORTED : Float;
			final MS_MEDIA_ERR_ENCRYPTED : Float;
		};
		/**
			This EncryptedMediaExtensions API interface contains the content and related data when the content decryption module generates a message for the session.
		**/
		var MediaKeyMessageEvent : {
			var prototype : js.html.eme.MediaKeyMessageEvent;
		};
		/**
			This EncryptedMediaExtensions API interface represents a context for message exchange with a content decryption module (CDM).
		**/
		var MediaKeySession : {
			var prototype : js.html.eme.MediaKeySession;
		};
		/**
			This EncryptedMediaExtensions API interface is a read-only map of media key statuses by key IDs.
		**/
		var MediaKeyStatusMap : {
			var prototype : js.html.eme.MediaKeyStatusMap;
		};
		/**
			This EncryptedMediaExtensions API interface provides access to a Key System for decryption and/or a content protection provider. You can request an instance of this object using the Navigator.requestMediaKeySystemAccess method.
		**/
		var MediaKeySystemAccess : {
			var prototype : js.html.eme.MediaKeySystemAccess;
		};
		/**
			This EncryptedMediaExtensions API interface the represents a set of keys that an associated HTMLMediaElement can use for decryption of media data during playback.
		**/
		var MediaKeys : {
			var prototype : js.html.eme.MediaKeys;
		};
		var MediaList : {
			var prototype : js.html.MediaList;
		};
		/**
			Stores information on a media query applied to a document, and handles sending notifications to listeners when the media query state change (i.e. when the media query test starts or stops evaluating to true).
		**/
		var MediaQueryList : {
			var prototype : js.html.MediaQueryList;
		};
		var MediaQueryListEvent : {
			var prototype : js.html.MediaQueryListEvent;
		};
		/**
			This Media Source Extensions API interface represents a source of media data for an HTMLMediaElement object. A MediaSource object can be attached to a HTMLMediaElement to be played in the user agent.
		**/
		var MediaSource : {
			var prototype : js.html.MediaSource;
			function isTypeSupported(type:String):Bool;
		};
		/**
			A stream of media content. A stream consists of several tracks such as video or audio tracks. Each track is specified as an instance of MediaStreamTrack.
		**/
		var MediaStream : {
			var prototype : js.html.MediaStream;
		};
		var MediaStreamAudioDestinationNode : {
			var prototype : js.html.audio.MediaStreamAudioDestinationNode;
		};
		/**
			A type of AudioNode which operates as an audio source whose media is received from a MediaStream obtained using the WebRTC or Media Capture and Streams APIs.
		**/
		var MediaStreamAudioSourceNode : {
			var prototype : js.html.audio.MediaStreamAudioSourceNode;
		};
		var MediaStreamError : {
			var prototype : js.html.MediaStreamError;
		};
		var MediaStreamErrorEvent : {
			var prototype : js.html.MediaStreamErrorEvent;
		};
		/**
			Events that occurs in relation to a MediaStream. Two events of this type can be thrown: addstream and removestream.
		**/
		var MediaStreamEvent : {
			var prototype : js.html.MediaStreamEvent;
		};
		/**
			A single media track within a stream; typically, these are audio or video tracks, but other track types may exist as well.
		**/
		var MediaStreamTrack : {
			var prototype : js.html.MediaStreamTrack;
		};
		var MediaStreamTrackAudioSourceNode : {
			var prototype : js.html.MediaStreamTrackAudioSourceNode;
		};
		/**
			Events which indicate that a MediaStream has had tracks added to or removed from the stream through calls to Media Stream API methods. These events are sent to the stream when these changes occur.
		**/
		var MediaStreamTrackEvent : {
			var prototype : js.html.MediaStreamTrackEvent;
		};
		/**
			This Channel Messaging API interface allows us to create a new message channel and send data through it via its two MessagePort properties.
		**/
		var MessageChannel : {
			var prototype : js.html.MessageChannel;
		};
		/**
			A message received by a target object.
		**/
		var MessageEvent : {
			var prototype : js.html.MessageEvent;
		};
		/**
			This Channel Messaging API interface represents one of the two ports of a MessageChannel, allowing messages to be sent from one port and listening out for them arriving at the other.
		**/
		var MessagePort : {
			var prototype : js.html.MessagePort;
		};
		/**
			Provides contains information about a MIME type associated with a particular plugin. NavigatorPlugins.mimeTypes returns an array of this object.
		**/
		var MimeType : {
			var prototype : js.html.MimeType;
		};
		/**
			Returns an array of MimeType instances, each of which contains information about a supported browser plugins. This object is returned by NavigatorPlugins.mimeTypes.
		**/
		var MimeTypeArray : {
			var prototype : js.html.MimeTypeArray;
		};
		/**
			Events that occur due to the user interacting with a pointing device (such as a mouse). Common events using this interface include click, dblclick, mouseup, mousedown.
		**/
		var MouseEvent : {
			var prototype : js.html.MouseEvent;
		};
		/**
			Provides event properties that are specific to modifications to the Document Object Model (DOM) hierarchy and nodes.
		**/
		var MutationEvent : {
			var prototype : js.html.MutationEvent;
			final ADDITION : Float;
			final MODIFICATION : Float;
			final REMOVAL : Float;
		};
		/**
			Provides the ability to watch for changes being made to the DOM tree. It is designed as a replacement for the older Mutation Events feature which was part of the DOM3 Events specification.
		**/
		var MutationObserver : {
			var prototype : js.html.MutationObserver;
		};
		/**
			A MutationRecord represents an individual DOM mutation. It is the object that is passed to MutationObserver's callback.
		**/
		var MutationRecord : {
			var prototype : js.html.MutationRecord;
		};
		/**
			A collection of Attr objects. Objects inside a NamedNodeMap are not in any particular order, unlike NodeList, although they may be accessed by an index as in an array.
		**/
		var NamedNodeMap : {
			var prototype : js.html.NamedNodeMap;
		};
		var NavigationPreloadManager : {
			var prototype : js.html.NavigationPreloadManager;
		};
		/**
			The state and the identity of the user agent. It allows scripts to query it and to register themselves to carry on some activities.
		**/
		var Navigator : {
			var prototype : js.html.Navigator;
		};
		/**
			Node is an interface from which a number of DOM API object types inherit. It allows those types to be treated similarly; for example, inheriting the same set of methods, or being tested in the same way.
		**/
		var Node : {
			var prototype : js.html.Node;
			final ATTRIBUTE_NODE : Float;
			/**
				node is a CDATASection node.
			**/
			final CDATA_SECTION_NODE : Float;
			/**
				node is a Comment node.
			**/
			final COMMENT_NODE : Float;
			/**
				node is a DocumentFragment node.
			**/
			final DOCUMENT_FRAGMENT_NODE : Float;
			/**
				node is a document.
			**/
			final DOCUMENT_NODE : Float;
			/**
				Set when other is a descendant of node.
			**/
			final DOCUMENT_POSITION_CONTAINED_BY : Float;
			/**
				Set when other is an ancestor of node.
			**/
			final DOCUMENT_POSITION_CONTAINS : Float;
			/**
				Set when node and other are not in the same tree.
			**/
			final DOCUMENT_POSITION_DISCONNECTED : Float;
			/**
				Set when other is following node.
			**/
			final DOCUMENT_POSITION_FOLLOWING : Float;
			final DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC : Float;
			/**
				Set when other is preceding node.
			**/
			final DOCUMENT_POSITION_PRECEDING : Float;
			/**
				node is a doctype.
			**/
			final DOCUMENT_TYPE_NODE : Float;
			/**
				node is an element.
			**/
			final ELEMENT_NODE : Float;
			final ENTITY_NODE : Float;
			final ENTITY_REFERENCE_NODE : Float;
			final NOTATION_NODE : Float;
			/**
				node is a ProcessingInstruction node.
			**/
			final PROCESSING_INSTRUCTION_NODE : Float;
			/**
				node is a Text node.
			**/
			final TEXT_NODE : Float;
		};
		/**
			An object used to filter the nodes in a NodeIterator or TreeWalker. They don't know anything about the DOM or how to traverse nodes; they just know how to evaluate a single node against the provided filter.
		**/
		var NodeFilter : {
			final FILTER_ACCEPT : Float;
			final FILTER_REJECT : Float;
			final FILTER_SKIP : Float;
			final SHOW_ALL : Float;
			final SHOW_ATTRIBUTE : Float;
			final SHOW_CDATA_SECTION : Float;
			final SHOW_COMMENT : Float;
			final SHOW_DOCUMENT : Float;
			final SHOW_DOCUMENT_FRAGMENT : Float;
			final SHOW_DOCUMENT_TYPE : Float;
			final SHOW_ELEMENT : Float;
			final SHOW_ENTITY : Float;
			final SHOW_ENTITY_REFERENCE : Float;
			final SHOW_NOTATION : Float;
			final SHOW_PROCESSING_INSTRUCTION : Float;
			final SHOW_TEXT : Float;
		};
		/**
			An iterator over the members of a list of the nodes in a subtree of the DOM. The nodes will be returned in document order.
		**/
		var NodeIterator : {
			var prototype : js.html.NodeIterator;
		};
		/**
			NodeList objects are collections of nodes, usually returned by properties such as Node.childNodes and methods such as document.querySelectorAll().
		**/
		var NodeList : {
			var prototype : js.html.NodeList;
		};
		/**
			This Notifications API interface is used to configure and display desktop notifications to the user.
		**/
		var Notification : {
			var prototype : js.html.Notification;
			final maxActions : Float;
			final permission : js.html.NotificationPermission;
			function requestPermission(?deprecatedCallback:js.html.NotificationPermissionCallback):js.lib.Promise<js.html.NotificationPermission>;
		};
		/**
			The Web Audio API OfflineAudioCompletionEvent interface represents events that occur when the processing of an OfflineAudioContext is terminated. The complete event implements this interface.
		**/
		var OfflineAudioCompletionEvent : {
			var prototype : js.html.audio.OfflineAudioCompletionEvent;
		};
		/**
			An AudioContext interface representing an audio-processing graph built from linked together AudioNodes. In contrast with a standard AudioContext, an OfflineAudioContext doesn't render the audio to the device hardware; instead, it generates it, as fast as it can, and outputs the result to an AudioBuffer.
		**/
		var OfflineAudioContext : {
			var prototype : js.html.audio.OfflineAudioContext;
		};
		var OffscreenCanvas : {
			var prototype : js.html.OffscreenCanvas;
		};
		var OffscreenCanvasRenderingContext2D : {
			var prototype : js.html.OffscreenCanvasRenderingContext2D;
		};
		/**
			The OscillatorNode interface represents a periodic waveform, such as a sine wave. It is an AudioScheduledSourceNode audio-processing module that causes a specified frequency of a given wave to be created—in effect, a constant tone.
		**/
		var OscillatorNode : {
			var prototype : js.html.audio.OscillatorNode;
		};
		var OverconstrainedError : {
			var prototype : js.html.OverconstrainedError;
		};
		var OverflowEvent : {
			var prototype : js.html.OverflowEvent;
			final BOTH : Float;
			final HORIZONTAL : Float;
			final VERTICAL : Float;
		};
		/**
			The PageTransitionEvent is fired when a document is being loaded or unloaded.
		**/
		var PageTransitionEvent : {
			var prototype : js.html.PageTransitionEvent;
		};
		/**
			A PannerNode always has exactly one input and one output: the input can be mono or stereo but the output is always stereo (2 channels); you can't have panning effects without at least two audio channels!
		**/
		var PannerNode : {
			var prototype : js.html.audio.PannerNode;
		};
		/**
			This Canvas 2D API interface is used to declare a path that can then be used on a CanvasRenderingContext2D object. The path methods of the CanvasRenderingContext2D interface are also present on this interface, which gives you the convenience of being able to retain and replay your path whenever desired.
		**/
		var Path2D : {
			var prototype : js.html.Path2D;
		};
		/**
			This Payment Request API interface is used to store shipping or payment address information.
		**/
		var PaymentAddress : {
			var prototype : js.html.PaymentAddress;
		};
		/**
			This Payment Request API interface is the primary access point into the API, and lets web content and apps accept payments from the end user.
		**/
		var PaymentRequest : {
			var prototype : js.html.PaymentRequest;
		};
		/**
			This Payment Request API interface enables a web page to update the details of a PaymentRequest in response to a user action.
		**/
		var PaymentRequestUpdateEvent : {
			var prototype : js.html.PaymentRequestUpdateEvent;
		};
		/**
			This Payment Request API interface is returned after a user selects a payment method and approves a payment request.
		**/
		var PaymentResponse : {
			var prototype : js.html.PaymentResponse;
		};
		var PerfWidgetExternal : {
			var prototype : js.html.PerfWidgetExternal;
		};
		/**
			Provides access to performance-related information for the current page. It's part of the High Resolution Time API, but is enhanced by the Performance Timeline API, the Navigation Timing API, the User Timing API, and the Resource Timing API.
		**/
		var Performance : {
			var prototype : js.html.Performance;
		};
		/**
			Encapsulates a single performance metric that is part of the performance timeline. A performance entry can be directly created by making a performance mark or measure (for example by calling the mark() method) at an explicit point in an application. Performance entries are also created in indirect ways such as loading a resource (such as an image).
		**/
		var PerformanceEntry : {
			var prototype : js.html.PerformanceEntry;
		};
		/**
			PerformanceMark is an abstract interface for PerformanceEntry objects with an entryType of "mark". Entries of this type are created by calling performance.mark() to add a named DOMHighResTimeStamp (the mark) to the browser's performance timeline.
		**/
		var PerformanceMark : {
			var prototype : js.html.PerformanceMark;
		};
		/**
			PerformanceMeasure is an abstract interface for PerformanceEntry objects with an entryType of "measure". Entries of this type are created by calling performance.measure() to add a named DOMHighResTimeStamp (the measure) between two marks to the browser's performance timeline.
		**/
		var PerformanceMeasure : {
			var prototype : js.html.PerformanceMeasure;
		};
		/**
			The legacy PerformanceNavigation interface represents information about how the navigation to the current document was done.
		**/
		var PerformanceNavigation : {
			var prototype : js.html.PerformanceNavigation;
			final TYPE_BACK_FORWARD : Float;
			final TYPE_NAVIGATE : Float;
			final TYPE_RELOAD : Float;
			final TYPE_RESERVED : Float;
		};
		/**
			Provides methods and properties to store and retrieve metrics regarding the browser's document navigation events. For example, this interface can be used to determine how much time it takes to load or unload a document.
		**/
		var PerformanceNavigationTiming : {
			var prototype : js.html.PerformanceNavigationTiming;
		};
		var PerformanceObserver : {
			var prototype : js.html.PerformanceObserver;
			final supportedEntryTypes : haxe.ds.ReadOnlyArray<String>;
		};
		var PerformanceObserverEntryList : {
			var prototype : js.html.PerformanceObserverEntryList;
		};
		/**
			Enables retrieval and analysis of detailed network timing data regarding the loading of an application's resources. An application can use the timing metrics to determine, for example, the length of time it takes to fetch a specific resource, such as an XMLHttpRequest, <SVG>, image, or script.
		**/
		var PerformanceResourceTiming : {
			var prototype : js.html.PerformanceResourceTiming;
		};
		/**
			A legacy interface kept for backwards compatibility and contains properties that offer performance timing information for various events which occur during the loading and use of the current page. You get a PerformanceTiming object describing your page using the window.performance.timing property.
		**/
		var PerformanceTiming : {
			var prototype : js.html.PerformanceTiming;
		};
		/**
			PeriodicWave has no inputs or outputs; it is used to define custom oscillators when calling OscillatorNode.setPeriodicWave(). The PeriodicWave itself is created/returned by AudioContext.createPeriodicWave().
		**/
		var PeriodicWave : {
			var prototype : js.html.audio.PeriodicWave;
		};
		var PermissionRequest : {
			var prototype : js.html.PermissionRequest;
		};
		var PermissionRequestedEvent : {
			var prototype : js.html.PermissionRequestedEvent;
		};
		var PermissionStatus : {
			var prototype : js.html.PermissionStatus;
		};
		var Permissions : {
			var prototype : js.html.Permissions;
		};
		/**
			Provides information about a browser plugin.
		**/
		var Plugin : {
			var prototype : js.html.Plugin;
		};
		/**
			Used to store a list of Plugin objects describing the available plugins; it's returned by the window.navigator.plugins property. The PluginArray is not a JavaScript array, but has the length property and supports accessing individual items using bracket notation (plugins[2]), as well as via item(index) and namedItem("name") methods.
		**/
		var PluginArray : {
			var prototype : js.html.PluginArray;
		};
		/**
			The state of a DOM event produced by a pointer such as the geometry of the contact point, the device type that generated the event, the amount of pressure that was applied on the contact surface, etc.
		**/
		var PointerEvent : {
			var prototype : js.html.PointerEvent;
		};
		/**
			PopStateEvent is an event handler for the popstate event on the window.
		**/
		var PopStateEvent : {
			var prototype : js.html.PopStateEvent;
		};
		/**
			A processing instruction embeds application-specific instructions in XML which can be ignored by other applications that don't recognize them.
		**/
		var ProcessingInstruction : {
			var prototype : js.html.ProcessingInstruction;
		};
		/**
			Events measuring progress of an underlying process, like an HTTP request (for an XMLHttpRequest, or the loading of the underlying resource of an <img>, <audio>, <video>, <style> or <link>).
		**/
		var ProgressEvent : {
			var prototype : js.html.ProgressEvent<js.html.EventTarget>;
		};
		var PromiseRejectionEvent : {
			var prototype : js.html.PromiseRejectionEvent;
		};
		var PublicKeyCredential : {
			var prototype : js.html.PublicKeyCredential;
			function isUserVerifyingPlatformAuthenticatorAvailable():js.lib.Promise<Bool>;
		};
		/**
			This Push API interface provides a way to receive notifications from third-party servers as well as request URLs for push notifications.
		**/
		var PushManager : {
			var prototype : js.html.push.PushManager;
			final supportedContentEncodings : haxe.ds.ReadOnlyArray<String>;
		};
		/**
			This Push API interface provides a subcription's URL endpoint and allows unsubscription from a push service.
		**/
		var PushSubscription : {
			var prototype : js.html.push.PushSubscription;
		};
		var PushSubscriptionOptions : {
			var prototype : js.html.push.PushSubscriptionOptions;
		};
		var RTCCertificate : {
			var prototype : js.html.rtc.Certificate;
			function getSupportedAlgorithms():Array<js.html.AlgorithmIdentifier>;
		};
		var RTCDTMFSender : {
			var prototype : js.html.rtc.DTMFSender;
		};
		/**
			Events sent to indicate that DTMF tones have started or finished playing. This interface is used by the tonechange event.
		**/
		var RTCDTMFToneChangeEvent : {
			var prototype : js.html.rtc.DTMFToneChangeEvent;
		};
		var RTCDataChannel : {
			var prototype : js.html.rtc.DataChannel;
		};
		var RTCDataChannelEvent : {
			var prototype : js.html.rtc.DataChannelEvent;
		};
		var RTCDtlsTransport : {
			var prototype : js.html.RTCDtlsTransport;
		};
		var RTCDtlsTransportStateChangedEvent : {
			var prototype : js.html.RTCDtlsTransportStateChangedEvent;
		};
		var RTCDtmfSender : {
			var prototype : js.html.RTCDtmfSender;
		};
		var RTCError : {
			var prototype : js.html.RTCError;
		};
		var RTCErrorEvent : {
			var prototype : js.html.RTCErrorEvent;
		};
		/**
			The RTCIceCandidate interface—part of the WebRTC API—represents a candidate Internet Connectivity Establishment (ICE) configuration which may be used to establish an RTCPeerConnection.
		**/
		var RTCIceCandidate : {
			var prototype : js.html.rtc.IceCandidate;
		};
		var RTCIceCandidatePairChangedEvent : {
			var prototype : js.html.RTCIceCandidatePairChangedEvent;
		};
		var RTCIceGatherer : {
			var prototype : js.html.RTCIceGatherer;
		};
		var RTCIceGathererEvent : {
			var prototype : js.html.RTCIceGathererEvent;
		};
		/**
			Provides access to information about the ICE transport layer over which the data is being sent and received.
		**/
		var RTCIceTransport : {
			var prototype : js.html.RTCIceTransport;
		};
		var RTCIceTransportStateChangedEvent : {
			var prototype : js.html.RTCIceTransportStateChangedEvent;
		};
		var RTCIdentityAssertion : {
			var prototype : js.html.RTCIdentityAssertion;
		};
		/**
			A WebRTC connection between the local computer and a remote peer. It provides methods to connect to a remote peer, maintain and monitor the connection, and close the connection once it's no longer needed.
		**/
		var RTCPeerConnection : {
			var prototype : js.html.rtc.PeerConnection;
			function generateCertificate(keygenAlgorithm:js.html.AlgorithmIdentifier):js.lib.Promise<js.html.rtc.Certificate>;
			function getDefaultIceServers():Array<js.html.RTCIceServer>;
		};
		var RTCPeerConnectionIceErrorEvent : {
			var prototype : js.html.RTCPeerConnectionIceErrorEvent;
		};
		/**
			Events that occurs in relation to ICE candidates with the target, usually an RTCPeerConnection. Only one event is of this type: icecandidate.
		**/
		var RTCPeerConnectionIceEvent : {
			var prototype : js.html.rtc.PeerConnectionIceEvent;
		};
		/**
			This WebRTC API interface manages the reception and decoding of data for a MediaStreamTrack on an RTCPeerConnection.
		**/
		var RTCRtpReceiver : {
			var prototype : js.html.rtc.RtpReceiver;
			function getCapabilities(kind:String):Null<js.html.RTCRtpCapabilities>;
		};
		/**
			Provides the ability to control and obtain details about how a particular MediaStreamTrack is encoded and sent to a remote peer.
		**/
		var RTCRtpSender : {
			var prototype : js.html.rtc.RtpSender;
			function getCapabilities(kind:String):Null<js.html.RTCRtpCapabilities>;
		};
		var RTCRtpTransceiver : {
			var prototype : js.html.rtc.RtpTransceiver;
		};
		var RTCSctpTransport : {
			var prototype : js.html.RTCSctpTransport;
		};
		/**
			One end of a connection—or potential connection—and how it's configured. Each RTCSessionDescription consists of a description type indicating which part of the offer/answer negotiation process it describes and of the SDP descriptor of the session.
		**/
		var RTCSessionDescription : {
			var prototype : js.html.rtc.SessionDescription;
		};
		var RTCSrtpSdesTransport : {
			var prototype : js.html.RTCSrtpSdesTransport;
			function getLocalParameters():Array<js.html.RTCSrtpSdesParameters>;
		};
		var RTCSsrcConflictEvent : {
			var prototype : js.html.RTCSsrcConflictEvent;
		};
		var RTCStatsEvent : {
			var prototype : js.html.RTCStatsEvent;
		};
		var RTCStatsProvider : {
			var prototype : js.html.RTCStatsProvider;
		};
		var RTCTrackEvent : {
			var prototype : js.html.rtc.TrackEvent;
		};
		var RadioNodeList : {
			var prototype : js.html.RadioNodeList;
		};
		var RandomSource : {
			var prototype : js.html.RandomSource;
		};
		/**
			A fragment of a document that can contain nodes and parts of text nodes.
		**/
		var Range : {
			var prototype : js.html.Range;
			final END_TO_END : Float;
			final END_TO_START : Float;
			final START_TO_END : Float;
			final START_TO_START : Float;
		};
		/**
			This Streams API interface represents a readable stream of byte data. The Fetch API offers a concrete instance of a ReadableStream through the body property of a Response object.
		**/
		var ReadableStream : {
			var prototype : js.html.ReadableStream<Dynamic>;
		};
		var ReadableStreamReader : {
			var prototype : js.html.ReadableStreamReader<Dynamic>;
		};
		/**
			This Fetch API interface represents a resource request.
		**/
		var Request : {
			var prototype : js.html.Request;
		};
		/**
			This Fetch API interface represents the response to a request.
		**/
		var Response : {
			var prototype : js.html.Response;
			function error():js.html.Response;
			function redirect(url:String, ?status:Float):js.html.Response;
		};
		/**
			Provides access to the properties of <a> element, as well as methods to manipulate them.
		**/
		var SVGAElement : {
			var prototype : js.html.svg.AElement;
		};
		/**
			Used to represent a value that can be an <angle> or <number> value. An SVGAngle reflected through the animVal attribute is always read only.
		**/
		var SVGAngle : {
			var prototype : js.html.svg.Angle;
			final SVG_ANGLETYPE_DEG : Float;
			final SVG_ANGLETYPE_GRAD : Float;
			final SVG_ANGLETYPE_RAD : Float;
			final SVG_ANGLETYPE_UNKNOWN : Float;
			final SVG_ANGLETYPE_UNSPECIFIED : Float;
		};
		var SVGAnimateElement : {
			var prototype : js.html.svg.AnimateElement;
		};
		var SVGAnimateMotionElement : {
			var prototype : js.html.svg.AnimateMotionElement;
		};
		var SVGAnimateTransformElement : {
			var prototype : js.html.svg.AnimateTransformElement;
		};
		/**
			Used for attributes of basic type <angle> which can be animated.
		**/
		var SVGAnimatedAngle : {
			var prototype : js.html.svg.AnimatedAngle;
		};
		/**
			Used for attributes of type boolean which can be animated.
		**/
		var SVGAnimatedBoolean : {
			var prototype : js.html.svg.AnimatedBoolean;
		};
		/**
			Used for attributes whose value must be a constant from a particular enumeration and which can be animated.
		**/
		var SVGAnimatedEnumeration : {
			var prototype : js.html.svg.AnimatedEnumeration;
		};
		/**
			Used for attributes of basic type <integer> which can be animated.
		**/
		var SVGAnimatedInteger : {
			var prototype : js.html.svg.AnimatedInteger;
		};
		/**
			Used for attributes of basic type <length> which can be animated.
		**/
		var SVGAnimatedLength : {
			var prototype : js.html.svg.AnimatedLength;
		};
		/**
			Used for attributes of type SVGLengthList which can be animated.
		**/
		var SVGAnimatedLengthList : {
			var prototype : js.html.svg.AnimatedLengthList;
		};
		/**
			Used for attributes of basic type <Number> which can be animated.
		**/
		var SVGAnimatedNumber : {
			var prototype : js.html.svg.AnimatedNumber;
		};
		/**
			The SVGAnimatedNumber interface is used for attributes which take a list of numbers and which can be animated.
		**/
		var SVGAnimatedNumberList : {
			var prototype : js.html.svg.AnimatedNumberList;
		};
		/**
			Used for attributes of type SVGPreserveAspectRatio which can be animated.
		**/
		var SVGAnimatedPreserveAspectRatio : {
			var prototype : js.html.svg.AnimatedPreserveAspectRatio;
		};
		/**
			Used for attributes of basic SVGRect which can be animated.
		**/
		var SVGAnimatedRect : {
			var prototype : js.html.svg.AnimatedRect;
		};
		/**
			The SVGAnimatedString interface represents string attributes which can be animated from each SVG declaration. You need to create SVG attribute before doing anything else, everything should be declared inside this.
		**/
		var SVGAnimatedString : {
			var prototype : js.html.svg.AnimatedString;
		};
		/**
			Used for attributes which take a list of numbers and which can be animated.
		**/
		var SVGAnimatedTransformList : {
			var prototype : js.html.svg.AnimatedTransformList;
		};
		var SVGAnimationElement : {
			var prototype : js.html.svg.AnimationElement;
		};
		/**
			An interface for the <circle> element. The circle element is defined by the cx and cy attributes that denote the coordinates of the centre of the circle.
		**/
		var SVGCircleElement : {
			var prototype : js.html.svg.CircleElement;
		};
		/**
			Provides access to the properties of <clipPath> elements, as well as methods to manipulate them.
		**/
		var SVGClipPathElement : {
			var prototype : js.html.svg.ClipPathElement;
		};
		/**
			A base interface used by the component transfer function interfaces.
		**/
		var SVGComponentTransferFunctionElement : {
			var prototype : js.html.svg.ComponentTransferFunctionElement;
			final SVG_FECOMPONENTTRANSFER_TYPE_DISCRETE : Float;
			final SVG_FECOMPONENTTRANSFER_TYPE_GAMMA : Float;
			final SVG_FECOMPONENTTRANSFER_TYPE_IDENTITY : Float;
			final SVG_FECOMPONENTTRANSFER_TYPE_LINEAR : Float;
			final SVG_FECOMPONENTTRANSFER_TYPE_TABLE : Float;
			final SVG_FECOMPONENTTRANSFER_TYPE_UNKNOWN : Float;
		};
		var SVGCursorElement : {
			var prototype : js.html.SVGCursorElement;
		};
		/**
			Corresponds to the <defs> element.
		**/
		var SVGDefsElement : {
			var prototype : js.html.svg.DefsElement;
		};
		/**
			Corresponds to the <desc> element.
		**/
		var SVGDescElement : {
			var prototype : js.html.svg.DescElement;
		};
		/**
			All of the SVG DOM interfaces that correspond directly to elements in the SVG language derive from the SVGElement interface.
		**/
		var SVGElement : {
			var prototype : js.html.svg.Element;
		};
		var SVGElementInstance : {
			var prototype : js.html.SVGElementInstance;
		};
		var SVGElementInstanceList : {
			var prototype : js.html.SVGElementInstanceList;
		};
		/**
			Provides access to the properties of <ellipse> elements.
		**/
		var SVGEllipseElement : {
			var prototype : js.html.svg.EllipseElement;
		};
		/**
			Corresponds to the <feBlend> element.
		**/
		var SVGFEBlendElement : {
			var prototype : js.html.svg.FEBlendElement;
			final SVG_FEBLEND_MODE_COLOR : Float;
			final SVG_FEBLEND_MODE_COLOR_BURN : Float;
			final SVG_FEBLEND_MODE_COLOR_DODGE : Float;
			final SVG_FEBLEND_MODE_DARKEN : Float;
			final SVG_FEBLEND_MODE_DIFFERENCE : Float;
			final SVG_FEBLEND_MODE_EXCLUSION : Float;
			final SVG_FEBLEND_MODE_HARD_LIGHT : Float;
			final SVG_FEBLEND_MODE_HUE : Float;
			final SVG_FEBLEND_MODE_LIGHTEN : Float;
			final SVG_FEBLEND_MODE_LUMINOSITY : Float;
			final SVG_FEBLEND_MODE_MULTIPLY : Float;
			final SVG_FEBLEND_MODE_NORMAL : Float;
			final SVG_FEBLEND_MODE_OVERLAY : Float;
			final SVG_FEBLEND_MODE_SATURATION : Float;
			final SVG_FEBLEND_MODE_SCREEN : Float;
			final SVG_FEBLEND_MODE_SOFT_LIGHT : Float;
			final SVG_FEBLEND_MODE_UNKNOWN : Float;
		};
		/**
			Corresponds to the <feColorMatrix> element.
		**/
		var SVGFEColorMatrixElement : {
			var prototype : js.html.svg.FEColorMatrixElement;
			final SVG_FECOLORMATRIX_TYPE_HUEROTATE : Float;
			final SVG_FECOLORMATRIX_TYPE_LUMINANCETOALPHA : Float;
			final SVG_FECOLORMATRIX_TYPE_MATRIX : Float;
			final SVG_FECOLORMATRIX_TYPE_SATURATE : Float;
			final SVG_FECOLORMATRIX_TYPE_UNKNOWN : Float;
		};
		/**
			Corresponds to the <feComponentTransfer> element.
		**/
		var SVGFEComponentTransferElement : {
			var prototype : js.html.svg.FEComponentTransferElement;
		};
		/**
			Corresponds to the <feComposite> element.
		**/
		var SVGFECompositeElement : {
			var prototype : js.html.svg.FECompositeElement;
			final SVG_FECOMPOSITE_OPERATOR_ARITHMETIC : Float;
			final SVG_FECOMPOSITE_OPERATOR_ATOP : Float;
			final SVG_FECOMPOSITE_OPERATOR_IN : Float;
			final SVG_FECOMPOSITE_OPERATOR_OUT : Float;
			final SVG_FECOMPOSITE_OPERATOR_OVER : Float;
			final SVG_FECOMPOSITE_OPERATOR_UNKNOWN : Float;
			final SVG_FECOMPOSITE_OPERATOR_XOR : Float;
		};
		/**
			Corresponds to the <feConvolveMatrix> element.
		**/
		var SVGFEConvolveMatrixElement : {
			var prototype : js.html.svg.FEConvolveMatrixElement;
			final SVG_EDGEMODE_DUPLICATE : Float;
			final SVG_EDGEMODE_NONE : Float;
			final SVG_EDGEMODE_UNKNOWN : Float;
			final SVG_EDGEMODE_WRAP : Float;
		};
		/**
			Corresponds to the <feDiffuseLighting> element.
		**/
		var SVGFEDiffuseLightingElement : {
			var prototype : js.html.svg.FEDiffuseLightingElement;
		};
		/**
			Corresponds to the <feDisplacementMap> element.
		**/
		var SVGFEDisplacementMapElement : {
			var prototype : js.html.svg.FEDisplacementMapElement;
			final SVG_CHANNEL_A : Float;
			final SVG_CHANNEL_B : Float;
			final SVG_CHANNEL_G : Float;
			final SVG_CHANNEL_R : Float;
			final SVG_CHANNEL_UNKNOWN : Float;
		};
		/**
			Corresponds to the <feDistantLight> element.
		**/
		var SVGFEDistantLightElement : {
			var prototype : js.html.svg.FEDistantLightElement;
		};
		var SVGFEDropShadowElement : {
			var prototype : js.html.svg.FEDropShadowElement;
		};
		/**
			Corresponds to the <feFlood> element.
		**/
		var SVGFEFloodElement : {
			var prototype : js.html.svg.FEFloodElement;
		};
		/**
			Corresponds to the <feFuncA> element.
		**/
		var SVGFEFuncAElement : {
			var prototype : js.html.svg.FEFuncAElement;
		};
		/**
			Corresponds to the <feFuncB> element.
		**/
		var SVGFEFuncBElement : {
			var prototype : js.html.svg.FEFuncBElement;
		};
		/**
			Corresponds to the <feFuncG> element.
		**/
		var SVGFEFuncGElement : {
			var prototype : js.html.svg.FEFuncGElement;
		};
		/**
			Corresponds to the <feFuncR> element.
		**/
		var SVGFEFuncRElement : {
			var prototype : js.html.svg.FEFuncRElement;
		};
		/**
			Corresponds to the <feGaussianBlur> element.
		**/
		var SVGFEGaussianBlurElement : {
			var prototype : js.html.svg.FEGaussianBlurElement;
		};
		/**
			Corresponds to the <feImage> element.
		**/
		var SVGFEImageElement : {
			var prototype : js.html.svg.FEImageElement;
		};
		/**
			Corresponds to the <feMerge> element.
		**/
		var SVGFEMergeElement : {
			var prototype : js.html.svg.FEMergeElement;
		};
		/**
			Corresponds to the <feMergeNode> element.
		**/
		var SVGFEMergeNodeElement : {
			var prototype : js.html.svg.FEMergeNodeElement;
		};
		/**
			Corresponds to the <feMorphology> element.
		**/
		var SVGFEMorphologyElement : {
			var prototype : js.html.svg.FEMorphologyElement;
			final SVG_MORPHOLOGY_OPERATOR_DILATE : Float;
			final SVG_MORPHOLOGY_OPERATOR_ERODE : Float;
			final SVG_MORPHOLOGY_OPERATOR_UNKNOWN : Float;
		};
		/**
			Corresponds to the <feOffset> element.
		**/
		var SVGFEOffsetElement : {
			var prototype : js.html.svg.FEOffsetElement;
		};
		/**
			Corresponds to the <fePointLight> element.
		**/
		var SVGFEPointLightElement : {
			var prototype : js.html.svg.FEPointLightElement;
		};
		/**
			Corresponds to the <feSpecularLighting> element.
		**/
		var SVGFESpecularLightingElement : {
			var prototype : js.html.svg.FESpecularLightingElement;
		};
		/**
			Corresponds to the <feSpotLight> element.
		**/
		var SVGFESpotLightElement : {
			var prototype : js.html.svg.FESpotLightElement;
		};
		/**
			Corresponds to the <feTile> element.
		**/
		var SVGFETileElement : {
			var prototype : js.html.svg.FETileElement;
		};
		/**
			Corresponds to the <feTurbulence> element.
		**/
		var SVGFETurbulenceElement : {
			var prototype : js.html.svg.FETurbulenceElement;
			final SVG_STITCHTYPE_NOSTITCH : Float;
			final SVG_STITCHTYPE_STITCH : Float;
			final SVG_STITCHTYPE_UNKNOWN : Float;
			final SVG_TURBULENCE_TYPE_FRACTALNOISE : Float;
			final SVG_TURBULENCE_TYPE_TURBULENCE : Float;
			final SVG_TURBULENCE_TYPE_UNKNOWN : Float;
		};
		/**
			Provides access to the properties of <filter> elements, as well as methods to manipulate them.
		**/
		var SVGFilterElement : {
			var prototype : js.html.svg.FilterElement;
		};
		/**
			Provides access to the properties of <foreignObject> elements, as well as methods to manipulate them.
		**/
		var SVGForeignObjectElement : {
			var prototype : js.html.svg.ForeignObjectElement;
		};
		/**
			Corresponds to the <g> element.
		**/
		var SVGGElement : {
			var prototype : js.html.svg.GElement;
		};
		var SVGGeometryElement : {
			var prototype : js.html.svg.GeometryElement;
		};
		/**
			The SVGGradient interface is a base interface used by SVGLinearGradientElement and SVGRadialGradientElement.
		**/
		var SVGGradientElement : {
			var prototype : js.html.svg.GradientElement;
			final SVG_SPREADMETHOD_PAD : Float;
			final SVG_SPREADMETHOD_REFLECT : Float;
			final SVG_SPREADMETHOD_REPEAT : Float;
			final SVG_SPREADMETHOD_UNKNOWN : Float;
		};
		/**
			SVG elements whose primary purpose is to directly render graphics into a group.
		**/
		var SVGGraphicsElement : {
			var prototype : js.html.svg.GraphicsElement;
		};
		/**
			Corresponds to the <image> element.
		**/
		var SVGImageElement : {
			var prototype : js.html.svg.ImageElement;
		};
		/**
			Correspond to the <length> basic data type.
		**/
		var SVGLength : {
			var prototype : js.html.svg.Length;
			final SVG_LENGTHTYPE_CM : Float;
			final SVG_LENGTHTYPE_EMS : Float;
			final SVG_LENGTHTYPE_EXS : Float;
			final SVG_LENGTHTYPE_IN : Float;
			final SVG_LENGTHTYPE_MM : Float;
			final SVG_LENGTHTYPE_NUMBER : Float;
			final SVG_LENGTHTYPE_PC : Float;
			final SVG_LENGTHTYPE_PERCENTAGE : Float;
			final SVG_LENGTHTYPE_PT : Float;
			final SVG_LENGTHTYPE_PX : Float;
			final SVG_LENGTHTYPE_UNKNOWN : Float;
		};
		/**
			The SVGLengthList defines a list of SVGLength objects.
		**/
		var SVGLengthList : {
			var prototype : js.html.svg.LengthList;
		};
		/**
			Provides access to the properties of <line> elements, as well as methods to manipulate them.
		**/
		var SVGLineElement : {
			var prototype : js.html.svg.LineElement;
		};
		/**
			Corresponds to the <linearGradient> element.
		**/
		var SVGLinearGradientElement : {
			var prototype : js.html.svg.LinearGradientElement;
		};
		var SVGMarkerElement : {
			var prototype : js.html.svg.MarkerElement;
			final SVG_MARKERUNITS_STROKEWIDTH : Float;
			final SVG_MARKERUNITS_UNKNOWN : Float;
			final SVG_MARKERUNITS_USERSPACEONUSE : Float;
			final SVG_MARKER_ORIENT_ANGLE : Float;
			final SVG_MARKER_ORIENT_AUTO : Float;
			final SVG_MARKER_ORIENT_UNKNOWN : Float;
		};
		/**
			Provides access to the properties of <mask> elements, as well as methods to manipulate them.
		**/
		var SVGMaskElement : {
			var prototype : js.html.svg.MaskElement;
		};
		/**
			Corresponds to the <metadata> element.
		**/
		var SVGMetadataElement : {
			var prototype : js.html.svg.MetadataElement;
		};
		/**
			Corresponds to the <number> basic data type.
		**/
		var SVGNumber : {
			var prototype : js.html.svg.Number;
		};
		/**
			The SVGNumberList defines a list of SVGNumber objects.
		**/
		var SVGNumberList : {
			var prototype : js.html.svg.NumberList;
		};
		/**
			Corresponds to the <path> element.
		**/
		var SVGPathElement : {
			var prototype : js.html.svg.PathElement;
		};
		var SVGPathSeg : {
			var prototype : js.html.svg.PathSeg;
			final PATHSEG_ARC_ABS : Float;
			final PATHSEG_ARC_REL : Float;
			final PATHSEG_CLOSEPATH : Float;
			final PATHSEG_CURVETO_CUBIC_ABS : Float;
			final PATHSEG_CURVETO_CUBIC_REL : Float;
			final PATHSEG_CURVETO_CUBIC_SMOOTH_ABS : Float;
			final PATHSEG_CURVETO_CUBIC_SMOOTH_REL : Float;
			final PATHSEG_CURVETO_QUADRATIC_ABS : Float;
			final PATHSEG_CURVETO_QUADRATIC_REL : Float;
			final PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS : Float;
			final PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL : Float;
			final PATHSEG_LINETO_ABS : Float;
			final PATHSEG_LINETO_HORIZONTAL_ABS : Float;
			final PATHSEG_LINETO_HORIZONTAL_REL : Float;
			final PATHSEG_LINETO_REL : Float;
			final PATHSEG_LINETO_VERTICAL_ABS : Float;
			final PATHSEG_LINETO_VERTICAL_REL : Float;
			final PATHSEG_MOVETO_ABS : Float;
			final PATHSEG_MOVETO_REL : Float;
			final PATHSEG_UNKNOWN : Float;
		};
		var SVGPathSegArcAbs : {
			var prototype : js.html.SVGPathSegArcAbs;
		};
		var SVGPathSegArcRel : {
			var prototype : js.html.SVGPathSegArcRel;
		};
		var SVGPathSegClosePath : {
			var prototype : js.html.SVGPathSegClosePath;
		};
		var SVGPathSegCurvetoCubicAbs : {
			var prototype : js.html.SVGPathSegCurvetoCubicAbs;
		};
		var SVGPathSegCurvetoCubicRel : {
			var prototype : js.html.SVGPathSegCurvetoCubicRel;
		};
		var SVGPathSegCurvetoCubicSmoothAbs : {
			var prototype : js.html.SVGPathSegCurvetoCubicSmoothAbs;
		};
		var SVGPathSegCurvetoCubicSmoothRel : {
			var prototype : js.html.SVGPathSegCurvetoCubicSmoothRel;
		};
		var SVGPathSegCurvetoQuadraticAbs : {
			var prototype : js.html.SVGPathSegCurvetoQuadraticAbs;
		};
		var SVGPathSegCurvetoQuadraticRel : {
			var prototype : js.html.SVGPathSegCurvetoQuadraticRel;
		};
		var SVGPathSegCurvetoQuadraticSmoothAbs : {
			var prototype : js.html.SVGPathSegCurvetoQuadraticSmoothAbs;
		};
		var SVGPathSegCurvetoQuadraticSmoothRel : {
			var prototype : js.html.SVGPathSegCurvetoQuadraticSmoothRel;
		};
		var SVGPathSegLinetoAbs : {
			var prototype : js.html.SVGPathSegLinetoAbs;
		};
		var SVGPathSegLinetoHorizontalAbs : {
			var prototype : js.html.SVGPathSegLinetoHorizontalAbs;
		};
		var SVGPathSegLinetoHorizontalRel : {
			var prototype : js.html.SVGPathSegLinetoHorizontalRel;
		};
		var SVGPathSegLinetoRel : {
			var prototype : js.html.SVGPathSegLinetoRel;
		};
		var SVGPathSegLinetoVerticalAbs : {
			var prototype : js.html.SVGPathSegLinetoVerticalAbs;
		};
		var SVGPathSegLinetoVerticalRel : {
			var prototype : js.html.SVGPathSegLinetoVerticalRel;
		};
		var SVGPathSegList : {
			var prototype : js.html.svg.PathSegList;
		};
		var SVGPathSegMovetoAbs : {
			var prototype : js.html.SVGPathSegMovetoAbs;
		};
		var SVGPathSegMovetoRel : {
			var prototype : js.html.SVGPathSegMovetoRel;
		};
		/**
			Corresponds to the <pattern> element.
		**/
		var SVGPatternElement : {
			var prototype : js.html.svg.PatternElement;
		};
		var SVGPointList : {
			var prototype : js.html.svg.PointList;
		};
		/**
			Provides access to the properties of <polygon> elements, as well as methods to manipulate them.
		**/
		var SVGPolygonElement : {
			var prototype : js.html.svg.PolygonElement;
		};
		/**
			Provides access to the properties of <polyline> elements, as well as methods to manipulate them.
		**/
		var SVGPolylineElement : {
			var prototype : js.html.svg.PolylineElement;
		};
		/**
			Corresponds to the preserveAspectRatio attribute, which is available for some of SVG's elements.
		**/
		var SVGPreserveAspectRatio : {
			var prototype : js.html.svg.PreserveAspectRatio;
			final SVG_MEETORSLICE_MEET : Float;
			final SVG_MEETORSLICE_SLICE : Float;
			final SVG_MEETORSLICE_UNKNOWN : Float;
			final SVG_PRESERVEASPECTRATIO_NONE : Float;
			final SVG_PRESERVEASPECTRATIO_UNKNOWN : Float;
			final SVG_PRESERVEASPECTRATIO_XMAXYMAX : Float;
			final SVG_PRESERVEASPECTRATIO_XMAXYMID : Float;
			final SVG_PRESERVEASPECTRATIO_XMAXYMIN : Float;
			final SVG_PRESERVEASPECTRATIO_XMIDYMAX : Float;
			final SVG_PRESERVEASPECTRATIO_XMIDYMID : Float;
			final SVG_PRESERVEASPECTRATIO_XMIDYMIN : Float;
			final SVG_PRESERVEASPECTRATIO_XMINYMAX : Float;
			final SVG_PRESERVEASPECTRATIO_XMINYMID : Float;
			final SVG_PRESERVEASPECTRATIO_XMINYMIN : Float;
		};
		/**
			Corresponds to the <RadialGradient> element.
		**/
		var SVGRadialGradientElement : {
			var prototype : js.html.svg.RadialGradientElement;
		};
		/**
			Provides access to the properties of <rect> elements, as well as methods to manipulate them.
		**/
		var SVGRectElement : {
			var prototype : js.html.svg.RectElement;
		};
		/**
			Provides access to the properties of <svg> elements, as well as methods to manipulate them. This interface contains also various miscellaneous commonly-used utility methods, such as matrix operations and the ability to control the time of redraw on visual rendering devices.
		**/
		var SVGSVGElement : {
			var prototype : js.html.svg.SVGElement;
			final SVG_ZOOMANDPAN_DISABLE : Float;
			final SVG_ZOOMANDPAN_MAGNIFY : Float;
			final SVG_ZOOMANDPAN_UNKNOWN : Float;
		};
		/**
			Corresponds to the SVG <script> element.
		**/
		var SVGScriptElement : {
			var prototype : js.html.svg.ScriptElement;
		};
		/**
			Corresponds to the <stop> element.
		**/
		var SVGStopElement : {
			var prototype : js.html.svg.StopElement;
		};
		/**
			The SVGStringList defines a list of DOMString objects.
		**/
		var SVGStringList : {
			var prototype : js.html.svg.StringList;
		};
		/**
			Corresponds to the SVG <style> element.
		**/
		var SVGStyleElement : {
			var prototype : js.html.svg.StyleElement;
		};
		/**
			Corresponds to the <switch> element.
		**/
		var SVGSwitchElement : {
			var prototype : js.html.svg.SwitchElement;
		};
		/**
			Corresponds to the <symbol> element.
		**/
		var SVGSymbolElement : {
			var prototype : js.html.svg.SymbolElement;
		};
		/**
			A <tspan> element.
		**/
		var SVGTSpanElement : {
			var prototype : js.html.svg.TSpanElement;
		};
		/**
			Implemented by elements that support rendering child text content. It is inherited by various text-related interfaces, such as SVGTextElement, SVGTSpanElement, SVGTRefElement, SVGAltGlyphElement and SVGTextPathElement.
		**/
		var SVGTextContentElement : {
			var prototype : js.html.svg.TextContentElement;
			final LENGTHADJUST_SPACING : Float;
			final LENGTHADJUST_SPACINGANDGLYPHS : Float;
			final LENGTHADJUST_UNKNOWN : Float;
		};
		/**
			Corresponds to the <text> elements.
		**/
		var SVGTextElement : {
			var prototype : js.html.svg.TextElement;
		};
		/**
			Corresponds to the <textPath> element.
		**/
		var SVGTextPathElement : {
			var prototype : js.html.svg.TextPathElement;
			final TEXTPATH_METHODTYPE_ALIGN : Float;
			final TEXTPATH_METHODTYPE_STRETCH : Float;
			final TEXTPATH_METHODTYPE_UNKNOWN : Float;
			final TEXTPATH_SPACINGTYPE_AUTO : Float;
			final TEXTPATH_SPACINGTYPE_EXACT : Float;
			final TEXTPATH_SPACINGTYPE_UNKNOWN : Float;
		};
		/**
			Implemented by elements that support attributes that position individual text glyphs. It is inherited by SVGTextElement, SVGTSpanElement, SVGTRefElement and SVGAltGlyphElement.
		**/
		var SVGTextPositioningElement : {
			var prototype : js.html.svg.TextPositioningElement;
		};
		/**
			Corresponds to the <title> element.
		**/
		var SVGTitleElement : {
			var prototype : js.html.svg.TitleElement;
		};
		/**
			SVGTransform is the interface for one of the component transformations within an SVGTransformList; thus, an SVGTransform object corresponds to a single component (e.g., scale(…) or matrix(…)) within a transform attribute.
		**/
		var SVGTransform : {
			var prototype : js.html.svg.Transform;
			final SVG_TRANSFORM_MATRIX : Float;
			final SVG_TRANSFORM_ROTATE : Float;
			final SVG_TRANSFORM_SCALE : Float;
			final SVG_TRANSFORM_SKEWX : Float;
			final SVG_TRANSFORM_SKEWY : Float;
			final SVG_TRANSFORM_TRANSLATE : Float;
			final SVG_TRANSFORM_UNKNOWN : Float;
		};
		/**
			The SVGTransformList defines a list of SVGTransform objects.
		**/
		var SVGTransformList : {
			var prototype : js.html.svg.TransformList;
		};
		/**
			A commonly used set of constants used for reflecting gradientUnits, patternContentUnits and other similar attributes.
		**/
		var SVGUnitTypes : {
			var prototype : js.html.svg.UnitTypes;
			final SVG_UNIT_TYPE_OBJECTBOUNDINGBOX : Float;
			final SVG_UNIT_TYPE_UNKNOWN : Float;
			final SVG_UNIT_TYPE_USERSPACEONUSE : Float;
		};
		/**
			Corresponds to the <use> element.
		**/
		var SVGUseElement : {
			var prototype : js.html.svg.UseElement;
		};
		/**
			Provides access to the properties of <view> elements, as well as methods to manipulate them.
		**/
		var SVGViewElement : {
			var prototype : js.html.svg.ViewElement;
			final SVG_ZOOMANDPAN_DISABLE : Float;
			final SVG_ZOOMANDPAN_MAGNIFY : Float;
			final SVG_ZOOMANDPAN_UNKNOWN : Float;
		};
		/**
			Used to reflect the zoomAndPan attribute, and is mixed in to other interfaces for elements that support this attribute.
		**/
		var SVGZoomAndPan : {
			final SVG_ZOOMANDPAN_DISABLE : Float;
			final SVG_ZOOMANDPAN_MAGNIFY : Float;
			final SVG_ZOOMANDPAN_UNKNOWN : Float;
		};
		var SVGZoomEvent : {
			var prototype : js.html.SVGZoomEvent;
		};
		var ScopedCredential : {
			var prototype : js.html.ScopedCredential;
		};
		var ScopedCredentialInfo : {
			var prototype : js.html.ScopedCredentialInfo;
		};
		/**
			A screen, usually the one on which the current window is being rendered, and is obtained using window.screen.
		**/
		var Screen : {
			var prototype : js.html.Screen;
		};
		var ScreenOrientation : {
			var prototype : js.html.ScreenOrientation;
		};
		/**
			Allows the generation, processing, or analyzing of audio using JavaScript.
		**/
		var ScriptProcessorNode : {
			var prototype : js.html.audio.ScriptProcessorNode;
		};
		/**
			Inherits from Event, and represents the event object of an event sent on a document or worker when its content security policy is violated.
		**/
		var SecurityPolicyViolationEvent : {
			var prototype : js.html.SecurityPolicyViolationEvent;
		};
		/**
			A Selection object represents the range of text selected by the user or the current position of the caret. To obtain a Selection object for examination or modification, call Window.getSelection().
		**/
		var Selection : {
			var prototype : js.html.Selection;
		};
		var ServiceUIFrameContext : js.html.ServiceUIFrameContext;
		/**
			This ServiceWorker API interface provides a reference to a service worker. Multiple browsing contexts (e.g. pages, workers, etc.) can be associated with the same service worker, each through a unique ServiceWorker object.
		**/
		var ServiceWorker : {
			var prototype : js.html.ServiceWorker;
		};
		/**
			The ServiceWorkerContainer interface of the ServiceWorker API provides an object representing the service worker as an overall unit in the network ecosystem, including facilities to register, unregister and update service workers, and access the state of service workers and their registrations.
		**/
		var ServiceWorkerContainer : {
			var prototype : js.html.ServiceWorkerContainer;
		};
		/**
			This ServiceWorker API interface contains information about an event sent to a ServiceWorkerContainer target. This extends the default message event to allow setting a ServiceWorker object as the source of a message. The event object is accessed via the handler function of a message event, when fired by a message received from a service worker.
		**/
		var ServiceWorkerMessageEvent : {
			var prototype : js.html.ServiceWorkerMessageEvent;
		};
		/**
			This ServiceWorker API interface represents the service worker registration. You register a service worker to control one or more pages that share the same origin.
		**/
		var ServiceWorkerRegistration : {
			var prototype : js.html.ServiceWorkerRegistration;
		};
		var ShadowRoot : {
			var prototype : js.html.ShadowRoot;
		};
		/**
			A chunk of media to be passed into an HTMLMediaElement and played, via a MediaSource object. This can be made up of one or several media segments.
		**/
		var SourceBuffer : {
			var prototype : js.html.SourceBuffer;
		};
		/**
			A simple container list for multiple SourceBuffer objects.
		**/
		var SourceBufferList : {
			var prototype : js.html.SourceBufferList;
		};
		var SpeechGrammar : {
			var prototype : js.html.SpeechGrammar;
		};
		var SpeechGrammarList : {
			var prototype : js.html.SpeechGrammarList;
		};
		var SpeechRecognition : {
			var prototype : js.html.SpeechRecognition;
		};
		var SpeechRecognitionAlternative : {
			var prototype : js.html.SpeechRecognitionAlternative;
		};
		var SpeechRecognitionError : {
			var prototype : js.html.SpeechRecognitionError;
		};
		var SpeechRecognitionEvent : {
			var prototype : js.html.SpeechRecognitionEvent;
		};
		var SpeechRecognitionResult : {
			var prototype : js.html.SpeechRecognitionResult;
		};
		var SpeechRecognitionResultList : {
			var prototype : js.html.SpeechRecognitionResultList;
		};
		/**
			This Web Speech API interface is the controller interface for the speech service; this can be used to retrieve information about the synthesis voices available on the device, start and pause speech, and other commands besides.
		**/
		var SpeechSynthesis : {
			var prototype : js.html.SpeechSynthesis;
		};
		var SpeechSynthesisErrorEvent : {
			var prototype : js.html.SpeechSynthesisErrorEvent;
		};
		/**
			This Web Speech API interface contains information about the current state of SpeechSynthesisUtterance objects that have been processed in the speech service.
		**/
		var SpeechSynthesisEvent : {
			var prototype : js.html.SpeechSynthesisEvent;
		};
		/**
			This Web Speech API interface represents a speech request. It contains the content the speech service should read and information about how to read it (e.g. language, pitch and volume.)
		**/
		var SpeechSynthesisUtterance : {
			var prototype : js.html.SpeechSynthesisUtterance;
		};
		/**
			This Web Speech API interface represents a voice that the system supports. Every SpeechSynthesisVoice has its own relative speech service including information about language, name and URI.
		**/
		var SpeechSynthesisVoice : {
			var prototype : js.html.SpeechSynthesisVoice;
		};
		var StaticRange : {
			var prototype : js.html.StaticRange;
		};
		/**
			The pan property takes a unitless value between -1 (full left pan) and 1 (full right pan). This interface was introduced as a much simpler way to apply a simple panning effect than having to use a full PannerNode.
		**/
		var StereoPannerNode : {
			var prototype : js.html.audio.StereoPannerNode;
		};
		/**
			This Web Storage API interface provides access to a particular domain's session or local storage. It allows, for example, the addition, modification, or deletion of stored data items.
		**/
		var Storage : {
			var prototype : js.html.Storage;
		};
		/**
			A StorageEvent is sent to a window when a storage area it has access to is changed within the context of another document.
		**/
		var StorageEvent : {
			var prototype : js.html.StorageEvent;
		};
		var StorageManager : {
			var prototype : js.html.StorageManager;
		};
		var StyleMedia : {
			var prototype : js.html.StyleMedia;
		};
		/**
			A single style sheet. CSS style sheets will further implement the more specialized CSSStyleSheet interface.
		**/
		var StyleSheet : {
			var prototype : js.html.StyleSheet;
		};
		/**
			A list of StyleSheet.
		**/
		var StyleSheetList : {
			var prototype : js.html.StyleSheetList;
		};
		/**
			This Web Crypto API interface provides a number of low-level cryptographic functions. It is accessed via the Crypto.subtle properties available in a window context (via Window.crypto).
		**/
		var SubtleCrypto : {
			var prototype : js.html.SubtleCrypto;
		};
		/**
			This ServiceWorker API interface provides an interface for registering and listing sync registrations.
		**/
		var SyncManager : {
			var prototype : js.html.SyncManager;
		};
		/**
			The textual content of Element or Attr. If an element has no markup within its content, it has a single child implementing Text that contains the element's text. However, if the element contains markup, it is parsed into information items and Text nodes that form its children.
		**/
		var Text : {
			var prototype : js.html.Text;
		};
		/**
			A decoder for a specific method, that is a specific character encoding, like utf-8, iso-8859-2, koi8, cp1261, gbk, etc. A decoder takes a stream of bytes as input and emits a stream of code points. For a more scalable, non-native library, see StringView – a C-like representation of strings based on typed arrays.
		**/
		var TextDecoder : {
			var prototype : js.html.TextDecoder;
		};
		var TextDecoderStream : {
			var prototype : js.html.TextDecoderStream;
		};
		/**
			TextEncoder takes a stream of code points as input and emits a stream of bytes. For a more scalable, non-native library, see StringView – a C-like representation of strings based on typed arrays.
		**/
		var TextEncoder : {
			var prototype : js.html.TextEncoder;
		};
		var TextEncoderStream : {
			var prototype : js.html.TextEncoderStream;
		};
		var TextEvent : {
			var prototype : js.html.TextEvent;
			final DOM_INPUT_METHOD_DROP : Float;
			final DOM_INPUT_METHOD_HANDWRITING : Float;
			final DOM_INPUT_METHOD_IME : Float;
			final DOM_INPUT_METHOD_KEYBOARD : Float;
			final DOM_INPUT_METHOD_MULTIMODAL : Float;
			final DOM_INPUT_METHOD_OPTION : Float;
			final DOM_INPUT_METHOD_PASTE : Float;
			final DOM_INPUT_METHOD_SCRIPT : Float;
			final DOM_INPUT_METHOD_UNKNOWN : Float;
			final DOM_INPUT_METHOD_VOICE : Float;
		};
		/**
			The dimensions of a piece of text in the canvas, as created by the CanvasRenderingContext2D.measureText() method.
		**/
		var TextMetrics : {
			var prototype : js.html.TextMetrics;
		};
		/**
			This interface also inherits properties from EventTarget.
		**/
		var TextTrack : {
			var prototype : js.html.TextTrack;
			final DISABLED : Float;
			final ERROR : Float;
			final HIDDEN : Float;
			final LOADED : Float;
			final LOADING : Float;
			final NONE : Float;
			final SHOWING : Float;
		};
		/**
			TextTrackCues represent a string of text that will be displayed for some duration of time on a TextTrack. This includes the start and end times that the cue will be displayed. A TextTrackCue cannot be used directly, instead one of the derived types (e.g. VTTCue) must be used.
		**/
		var TextTrackCue : {
			var prototype : js.html.TextTrackCue;
		};
		var TextTrackCueList : {
			var prototype : js.html.TextTrackCueList;
		};
		var TextTrackList : {
			var prototype : js.html.TextTrackList;
		};
		/**
			Used to represent a set of time ranges, primarily for the purpose of tracking which portions of media have been buffered when loading it for use by the <audio> and <video> elements.
		**/
		var TimeRanges : {
			var prototype : js.html.TimeRanges;
		};
		/**
			A single contact point on a touch-sensitive device. The contact point is commonly a finger or stylus and the device may be a touchscreen or trackpad.
		**/
		var Touch : {
			var prototype : js.html.Touch;
		};
		/**
			An event sent when the state of contacts with a touch-sensitive surface changes. This surface can be a touch screen or trackpad, for example. The event can describe one or more points of contact with the screen and includes support for detecting movement, addition and removal of contact points, and so forth.
		**/
		var TouchEvent : {
			var prototype : js.html.TouchEvent;
		};
		/**
			A list of contact points on a touch surface. For example, if the user has three fingers on the touch surface (such as a screen or trackpad), the corresponding TouchList object would have one Touch object for each finger, for a total of three entries.
		**/
		var TouchList : {
			var prototype : js.html.TouchList;
		};
		/**
			The TrackEvent interface, part of the HTML DOM specification, is used for events which represent changes to the set of available tracks on an HTML media element; these events are addtrack and removetrack.
		**/
		var TrackEvent : {
			var prototype : js.html.TrackEvent;
		};
		var TransformStream : {
			var prototype : js.html.TransformStream<Dynamic, Dynamic>;
		};
		/**
			Events providing information related to transitions.
		**/
		var TransitionEvent : {
			var prototype : js.html.TransitionEvent;
		};
		/**
			The nodes of a document subtree and a position within them.
		**/
		var TreeWalker : {
			var prototype : js.html.TreeWalker;
		};
		/**
			Simple user interface events.
		**/
		var UIEvent : {
			var prototype : js.html.UIEvent;
		};
		/**
			The URL interface represents an object providing static methods used for creating object URLs.
		**/
		var URL : {
			var prototype : js.html.URL;
			function createObjectURL(object:Dynamic):String;
			function revokeObjectURL(url:String):Void;
		};
		var webkitURL : {
			var prototype : js.html.URL;
			function createObjectURL(object:Dynamic):String;
			function revokeObjectURL(url:String):Void;
		};
		var URLSearchParams : {
			var prototype : js.html.URLSearchParams;
		};
		/**
			This WebVR API interface represents any VR device supported by this API. It includes generic information such as device IDs and descriptions, as well as methods for starting to present a VR scene, retrieving eye parameters and display capabilities, and other important functionality.
		**/
		var VRDisplay : {
			var prototype : js.html.VRDisplay;
		};
		/**
			This WebVR API interface describes the capabilities of a VRDisplay — its features can be used to perform VR device capability tests, for example can it return position information.
		**/
		var VRDisplayCapabilities : {
			var prototype : js.html.VRDisplayCapabilities;
		};
		/**
			This WebVR API interface represents represents the event object of WebVR-related events (see the list of WebVR window extensions).
		**/
		var VRDisplayEvent : {
			var prototype : js.html.VRDisplayEvent;
		};
		/**
			This WebVR API interface represents all the information required to correctly render a scene for a given eye, including field of view information.
		**/
		var VREyeParameters : {
			var prototype : js.html.VREyeParameters;
		};
		/**
			This WebVR API interface represents a field of view defined by 4 different degree values describing the view from a center point.
		**/
		var VRFieldOfView : {
			var prototype : js.html.VRFieldOfView;
		};
		/**
			This WebVR API interface represents all the information needed to render a single frame of a VR scene; constructed by VRDisplay.getFrameData().
		**/
		var VRFrameData : {
			var prototype : js.html.VRFrameData;
		};
		/**
			This WebVR API interface represents the state of a VR sensor at a given timestamp (which includes orientation, position, velocity, and acceleration information.)
		**/
		var VRPose : {
			var prototype : js.html.VRPose;
		};
		var VTTCue : {
			var prototype : js.html.VTTCue;
		};
		var VTTRegion : {
			var prototype : js.html.VTTRegion;
		};
		/**
			The validity states that an element can be in, with respect to constraint validation. Together, they help explain why an element's value fails to validate, if it's not valid.
		**/
		var ValidityState : {
			var prototype : js.html.ValidityState;
		};
		/**
			Returned by the HTMLVideoElement.getVideoPlaybackQuality() method and contains metrics that can be used to determine the playback quality of a video.
		**/
		var VideoPlaybackQuality : {
			var prototype : js.html.VideoPlaybackQuality;
		};
		/**
			A single video track from a <video> element.
		**/
		var VideoTrack : {
			var prototype : js.html.VideoTrack;
		};
		/**
			Used to represent a list of the video tracks contained within a <video> element, with each track represented by a separate VideoTrack object in the list.
		**/
		var VideoTrackList : {
			var prototype : js.html.VideoTrackList;
		};
		/**
			A WaveShaperNode always has exactly one input and one output.
		**/
		var WaveShaperNode : {
			var prototype : js.html.audio.WaveShaperNode;
		};
		var WebAuthentication : {
			var prototype : js.html.WebAuthentication;
		};
		var WebAuthnAssertion : {
			var prototype : js.html.WebAuthnAssertion;
		};
		var WebGL2RenderingContext : {
			var prototype : js.html.webgl.WebGL2RenderingContext;
			final ACTIVE_ATTRIBUTES : Float;
			final ACTIVE_TEXTURE : Float;
			final ACTIVE_UNIFORMS : Float;
			final ALIASED_LINE_WIDTH_RANGE : Float;
			final ALIASED_POINT_SIZE_RANGE : Float;
			final ALPHA : Float;
			final ALPHA_BITS : Float;
			final ALWAYS : Float;
			final ARRAY_BUFFER : Float;
			final ARRAY_BUFFER_BINDING : Float;
			final ATTACHED_SHADERS : Float;
			final BACK : Float;
			final BLEND : Float;
			final BLEND_COLOR : Float;
			final BLEND_DST_ALPHA : Float;
			final BLEND_DST_RGB : Float;
			final BLEND_EQUATION : Float;
			final BLEND_EQUATION_ALPHA : Float;
			final BLEND_EQUATION_RGB : Float;
			final BLEND_SRC_ALPHA : Float;
			final BLEND_SRC_RGB : Float;
			final BLUE_BITS : Float;
			final BOOL : Float;
			final BOOL_VEC2 : Float;
			final BOOL_VEC3 : Float;
			final BOOL_VEC4 : Float;
			final BROWSER_DEFAULT_WEBGL : Float;
			final BUFFER_SIZE : Float;
			final BUFFER_USAGE : Float;
			final BYTE : Float;
			final CCW : Float;
			final CLAMP_TO_EDGE : Float;
			final COLOR_ATTACHMENT0 : Float;
			final COLOR_BUFFER_BIT : Float;
			final COLOR_CLEAR_VALUE : Float;
			final COLOR_WRITEMASK : Float;
			final COMPILE_STATUS : Float;
			final COMPRESSED_TEXTURE_FORMATS : Float;
			final CONSTANT_ALPHA : Float;
			final CONSTANT_COLOR : Float;
			final CONTEXT_LOST_WEBGL : Float;
			final CULL_FACE : Float;
			final CULL_FACE_MODE : Float;
			final CURRENT_PROGRAM : Float;
			final CURRENT_VERTEX_ATTRIB : Float;
			final CW : Float;
			final DECR : Float;
			final DECR_WRAP : Float;
			final DELETE_STATUS : Float;
			final DEPTH_ATTACHMENT : Float;
			final DEPTH_BITS : Float;
			final DEPTH_BUFFER_BIT : Float;
			final DEPTH_CLEAR_VALUE : Float;
			final DEPTH_COMPONENT : Float;
			final DEPTH_COMPONENT16 : Float;
			final DEPTH_FUNC : Float;
			final DEPTH_RANGE : Float;
			final DEPTH_STENCIL : Float;
			final DEPTH_STENCIL_ATTACHMENT : Float;
			final DEPTH_TEST : Float;
			final DEPTH_WRITEMASK : Float;
			final DITHER : Float;
			final DONT_CARE : Float;
			final DST_ALPHA : Float;
			final DST_COLOR : Float;
			final DYNAMIC_DRAW : Float;
			final ELEMENT_ARRAY_BUFFER : Float;
			final ELEMENT_ARRAY_BUFFER_BINDING : Float;
			final EQUAL : Float;
			final FASTEST : Float;
			final FLOAT : Float;
			final FLOAT_MAT2 : Float;
			final FLOAT_MAT3 : Float;
			final FLOAT_MAT4 : Float;
			final FLOAT_VEC2 : Float;
			final FLOAT_VEC3 : Float;
			final FLOAT_VEC4 : Float;
			final FRAGMENT_SHADER : Float;
			final FRAMEBUFFER : Float;
			final FRAMEBUFFER_ATTACHMENT_OBJECT_NAME : Float;
			final FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE : Float;
			final FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE : Float;
			final FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL : Float;
			final FRAMEBUFFER_BINDING : Float;
			final FRAMEBUFFER_COMPLETE : Float;
			final FRAMEBUFFER_INCOMPLETE_ATTACHMENT : Float;
			final FRAMEBUFFER_INCOMPLETE_DIMENSIONS : Float;
			final FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT : Float;
			final FRAMEBUFFER_UNSUPPORTED : Float;
			final FRONT : Float;
			final FRONT_AND_BACK : Float;
			final FRONT_FACE : Float;
			final FUNC_ADD : Float;
			final FUNC_REVERSE_SUBTRACT : Float;
			final FUNC_SUBTRACT : Float;
			final GENERATE_MIPMAP_HINT : Float;
			final GEQUAL : Float;
			final GREATER : Float;
			final GREEN_BITS : Float;
			final HIGH_FLOAT : Float;
			final HIGH_INT : Float;
			final IMPLEMENTATION_COLOR_READ_FORMAT : Float;
			final IMPLEMENTATION_COLOR_READ_TYPE : Float;
			final INCR : Float;
			final INCR_WRAP : Float;
			final INT : Float;
			final INT_VEC2 : Float;
			final INT_VEC3 : Float;
			final INT_VEC4 : Float;
			final INVALID_ENUM : Float;
			final INVALID_FRAMEBUFFER_OPERATION : Float;
			final INVALID_OPERATION : Float;
			final INVALID_VALUE : Float;
			final INVERT : Float;
			final KEEP : Float;
			final LEQUAL : Float;
			final LESS : Float;
			final LINEAR : Float;
			final LINEAR_MIPMAP_LINEAR : Float;
			final LINEAR_MIPMAP_NEAREST : Float;
			final LINES : Float;
			final LINE_LOOP : Float;
			final LINE_STRIP : Float;
			final LINE_WIDTH : Float;
			final LINK_STATUS : Float;
			final LOW_FLOAT : Float;
			final LOW_INT : Float;
			final LUMINANCE : Float;
			final LUMINANCE_ALPHA : Float;
			final MAX_COMBINED_TEXTURE_IMAGE_UNITS : Float;
			final MAX_CUBE_MAP_TEXTURE_SIZE : Float;
			final MAX_FRAGMENT_UNIFORM_VECTORS : Float;
			final MAX_RENDERBUFFER_SIZE : Float;
			final MAX_TEXTURE_IMAGE_UNITS : Float;
			final MAX_TEXTURE_SIZE : Float;
			final MAX_VARYING_VECTORS : Float;
			final MAX_VERTEX_ATTRIBS : Float;
			final MAX_VERTEX_TEXTURE_IMAGE_UNITS : Float;
			final MAX_VERTEX_UNIFORM_VECTORS : Float;
			final MAX_VIEWPORT_DIMS : Float;
			final MEDIUM_FLOAT : Float;
			final MEDIUM_INT : Float;
			final MIRRORED_REPEAT : Float;
			final NEAREST : Float;
			final NEAREST_MIPMAP_LINEAR : Float;
			final NEAREST_MIPMAP_NEAREST : Float;
			final NEVER : Float;
			final NICEST : Float;
			final NONE : Float;
			final NOTEQUAL : Float;
			final NO_ERROR : Float;
			final ONE : Float;
			final ONE_MINUS_CONSTANT_ALPHA : Float;
			final ONE_MINUS_CONSTANT_COLOR : Float;
			final ONE_MINUS_DST_ALPHA : Float;
			final ONE_MINUS_DST_COLOR : Float;
			final ONE_MINUS_SRC_ALPHA : Float;
			final ONE_MINUS_SRC_COLOR : Float;
			final OUT_OF_MEMORY : Float;
			final PACK_ALIGNMENT : Float;
			final POINTS : Float;
			final POLYGON_OFFSET_FACTOR : Float;
			final POLYGON_OFFSET_FILL : Float;
			final POLYGON_OFFSET_UNITS : Float;
			final RED_BITS : Float;
			final RENDERBUFFER : Float;
			final RENDERBUFFER_ALPHA_SIZE : Float;
			final RENDERBUFFER_BINDING : Float;
			final RENDERBUFFER_BLUE_SIZE : Float;
			final RENDERBUFFER_DEPTH_SIZE : Float;
			final RENDERBUFFER_GREEN_SIZE : Float;
			final RENDERBUFFER_HEIGHT : Float;
			final RENDERBUFFER_INTERNAL_FORMAT : Float;
			final RENDERBUFFER_RED_SIZE : Float;
			final RENDERBUFFER_STENCIL_SIZE : Float;
			final RENDERBUFFER_WIDTH : Float;
			final RENDERER : Float;
			final REPEAT : Float;
			final REPLACE : Float;
			final RGB : Float;
			final RGB565 : Float;
			final RGB5_A1 : Float;
			final RGBA : Float;
			final RGBA4 : Float;
			final SAMPLER_2D : Float;
			final SAMPLER_CUBE : Float;
			final SAMPLES : Float;
			final SAMPLE_ALPHA_TO_COVERAGE : Float;
			final SAMPLE_BUFFERS : Float;
			final SAMPLE_COVERAGE : Float;
			final SAMPLE_COVERAGE_INVERT : Float;
			final SAMPLE_COVERAGE_VALUE : Float;
			final SCISSOR_BOX : Float;
			final SCISSOR_TEST : Float;
			final SHADER_TYPE : Float;
			final SHADING_LANGUAGE_VERSION : Float;
			final SHORT : Float;
			final SRC_ALPHA : Float;
			final SRC_ALPHA_SATURATE : Float;
			final SRC_COLOR : Float;
			final STATIC_DRAW : Float;
			final STENCIL_ATTACHMENT : Float;
			final STENCIL_BACK_FAIL : Float;
			final STENCIL_BACK_FUNC : Float;
			final STENCIL_BACK_PASS_DEPTH_FAIL : Float;
			final STENCIL_BACK_PASS_DEPTH_PASS : Float;
			final STENCIL_BACK_REF : Float;
			final STENCIL_BACK_VALUE_MASK : Float;
			final STENCIL_BACK_WRITEMASK : Float;
			final STENCIL_BITS : Float;
			final STENCIL_BUFFER_BIT : Float;
			final STENCIL_CLEAR_VALUE : Float;
			final STENCIL_FAIL : Float;
			final STENCIL_FUNC : Float;
			final STENCIL_INDEX8 : Float;
			final STENCIL_PASS_DEPTH_FAIL : Float;
			final STENCIL_PASS_DEPTH_PASS : Float;
			final STENCIL_REF : Float;
			final STENCIL_TEST : Float;
			final STENCIL_VALUE_MASK : Float;
			final STENCIL_WRITEMASK : Float;
			final STREAM_DRAW : Float;
			final SUBPIXEL_BITS : Float;
			final TEXTURE : Float;
			final TEXTURE0 : Float;
			final TEXTURE1 : Float;
			final TEXTURE10 : Float;
			final TEXTURE11 : Float;
			final TEXTURE12 : Float;
			final TEXTURE13 : Float;
			final TEXTURE14 : Float;
			final TEXTURE15 : Float;
			final TEXTURE16 : Float;
			final TEXTURE17 : Float;
			final TEXTURE18 : Float;
			final TEXTURE19 : Float;
			final TEXTURE2 : Float;
			final TEXTURE20 : Float;
			final TEXTURE21 : Float;
			final TEXTURE22 : Float;
			final TEXTURE23 : Float;
			final TEXTURE24 : Float;
			final TEXTURE25 : Float;
			final TEXTURE26 : Float;
			final TEXTURE27 : Float;
			final TEXTURE28 : Float;
			final TEXTURE29 : Float;
			final TEXTURE3 : Float;
			final TEXTURE30 : Float;
			final TEXTURE31 : Float;
			final TEXTURE4 : Float;
			final TEXTURE5 : Float;
			final TEXTURE6 : Float;
			final TEXTURE7 : Float;
			final TEXTURE8 : Float;
			final TEXTURE9 : Float;
			final TEXTURE_2D : Float;
			final TEXTURE_BINDING_2D : Float;
			final TEXTURE_BINDING_CUBE_MAP : Float;
			final TEXTURE_CUBE_MAP : Float;
			final TEXTURE_CUBE_MAP_NEGATIVE_X : Float;
			final TEXTURE_CUBE_MAP_NEGATIVE_Y : Float;
			final TEXTURE_CUBE_MAP_NEGATIVE_Z : Float;
			final TEXTURE_CUBE_MAP_POSITIVE_X : Float;
			final TEXTURE_CUBE_MAP_POSITIVE_Y : Float;
			final TEXTURE_CUBE_MAP_POSITIVE_Z : Float;
			final TEXTURE_MAG_FILTER : Float;
			final TEXTURE_MIN_FILTER : Float;
			final TEXTURE_WRAP_S : Float;
			final TEXTURE_WRAP_T : Float;
			final TRIANGLES : Float;
			final TRIANGLE_FAN : Float;
			final TRIANGLE_STRIP : Float;
			final UNPACK_ALIGNMENT : Float;
			final UNPACK_COLORSPACE_CONVERSION_WEBGL : Float;
			final UNPACK_FLIP_Y_WEBGL : Float;
			final UNPACK_PREMULTIPLY_ALPHA_WEBGL : Float;
			final UNSIGNED_BYTE : Float;
			final UNSIGNED_INT : Float;
			final UNSIGNED_SHORT : Float;
			final UNSIGNED_SHORT_4_4_4_4 : Float;
			final UNSIGNED_SHORT_5_5_5_1 : Float;
			final UNSIGNED_SHORT_5_6_5 : Float;
			final VALIDATE_STATUS : Float;
			final VENDOR : Float;
			final VERSION : Float;
			final VERTEX_ATTRIB_ARRAY_BUFFER_BINDING : Float;
			final VERTEX_ATTRIB_ARRAY_ENABLED : Float;
			final VERTEX_ATTRIB_ARRAY_NORMALIZED : Float;
			final VERTEX_ATTRIB_ARRAY_POINTER : Float;
			final VERTEX_ATTRIB_ARRAY_SIZE : Float;
			final VERTEX_ATTRIB_ARRAY_STRIDE : Float;
			final VERTEX_ATTRIB_ARRAY_TYPE : Float;
			final VERTEX_SHADER : Float;
			final VIEWPORT : Float;
			final ZERO : Float;
			final ACTIVE_UNIFORM_BLOCKS : Float;
			final ALREADY_SIGNALED : Float;
			final ANY_SAMPLES_PASSED : Float;
			final ANY_SAMPLES_PASSED_CONSERVATIVE : Float;
			final COLOR : Float;
			final COLOR_ATTACHMENT1 : Float;
			final COLOR_ATTACHMENT10 : Float;
			final COLOR_ATTACHMENT11 : Float;
			final COLOR_ATTACHMENT12 : Float;
			final COLOR_ATTACHMENT13 : Float;
			final COLOR_ATTACHMENT14 : Float;
			final COLOR_ATTACHMENT15 : Float;
			final COLOR_ATTACHMENT2 : Float;
			final COLOR_ATTACHMENT3 : Float;
			final COLOR_ATTACHMENT4 : Float;
			final COLOR_ATTACHMENT5 : Float;
			final COLOR_ATTACHMENT6 : Float;
			final COLOR_ATTACHMENT7 : Float;
			final COLOR_ATTACHMENT8 : Float;
			final COLOR_ATTACHMENT9 : Float;
			final COMPARE_REF_TO_TEXTURE : Float;
			final CONDITION_SATISFIED : Float;
			final COPY_READ_BUFFER : Float;
			final COPY_READ_BUFFER_BINDING : Float;
			final COPY_WRITE_BUFFER : Float;
			final COPY_WRITE_BUFFER_BINDING : Float;
			final CURRENT_QUERY : Float;
			final DEPTH : Float;
			final DEPTH24_STENCIL8 : Float;
			final DEPTH32F_STENCIL8 : Float;
			final DEPTH_COMPONENT24 : Float;
			final DEPTH_COMPONENT32F : Float;
			final DRAW_BUFFER0 : Float;
			final DRAW_BUFFER1 : Float;
			final DRAW_BUFFER10 : Float;
			final DRAW_BUFFER11 : Float;
			final DRAW_BUFFER12 : Float;
			final DRAW_BUFFER13 : Float;
			final DRAW_BUFFER14 : Float;
			final DRAW_BUFFER15 : Float;
			final DRAW_BUFFER2 : Float;
			final DRAW_BUFFER3 : Float;
			final DRAW_BUFFER4 : Float;
			final DRAW_BUFFER5 : Float;
			final DRAW_BUFFER6 : Float;
			final DRAW_BUFFER7 : Float;
			final DRAW_BUFFER8 : Float;
			final DRAW_BUFFER9 : Float;
			final DRAW_FRAMEBUFFER : Float;
			final DRAW_FRAMEBUFFER_BINDING : Float;
			final DYNAMIC_COPY : Float;
			final DYNAMIC_READ : Float;
			final FLOAT_32_UNSIGNED_INT_24_8_REV : Float;
			final FLOAT_MAT2x3 : Float;
			final FLOAT_MAT2x4 : Float;
			final FLOAT_MAT3x2 : Float;
			final FLOAT_MAT3x4 : Float;
			final FLOAT_MAT4x2 : Float;
			final FLOAT_MAT4x3 : Float;
			final FRAGMENT_SHADER_DERIVATIVE_HINT : Float;
			final FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE : Float;
			final FRAMEBUFFER_ATTACHMENT_BLUE_SIZE : Float;
			final FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING : Float;
			final FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE : Float;
			final FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE : Float;
			final FRAMEBUFFER_ATTACHMENT_GREEN_SIZE : Float;
			final FRAMEBUFFER_ATTACHMENT_RED_SIZE : Float;
			final FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE : Float;
			final FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER : Float;
			final FRAMEBUFFER_DEFAULT : Float;
			final FRAMEBUFFER_INCOMPLETE_MULTISAMPLE : Float;
			final HALF_FLOAT : Float;
			final INTERLEAVED_ATTRIBS : Float;
			final INT_2_10_10_10_REV : Float;
			final INT_SAMPLER_2D : Float;
			final INT_SAMPLER_2D_ARRAY : Float;
			final INT_SAMPLER_3D : Float;
			final INT_SAMPLER_CUBE : Float;
			final INVALID_INDEX : Float;
			final MAX : Float;
			final MAX_3D_TEXTURE_SIZE : Float;
			final MAX_ARRAY_TEXTURE_LAYERS : Float;
			final MAX_CLIENT_WAIT_TIMEOUT_WEBGL : Float;
			final MAX_COLOR_ATTACHMENTS : Float;
			final MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS : Float;
			final MAX_COMBINED_UNIFORM_BLOCKS : Float;
			final MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS : Float;
			final MAX_DRAW_BUFFERS : Float;
			final MAX_ELEMENTS_INDICES : Float;
			final MAX_ELEMENTS_VERTICES : Float;
			final MAX_ELEMENT_INDEX : Float;
			final MAX_FRAGMENT_INPUT_COMPONENTS : Float;
			final MAX_FRAGMENT_UNIFORM_BLOCKS : Float;
			final MAX_FRAGMENT_UNIFORM_COMPONENTS : Float;
			final MAX_PROGRAM_TEXEL_OFFSET : Float;
			final MAX_SAMPLES : Float;
			final MAX_SERVER_WAIT_TIMEOUT : Float;
			final MAX_TEXTURE_LOD_BIAS : Float;
			final MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS : Float;
			final MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS : Float;
			final MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS : Float;
			final MAX_UNIFORM_BLOCK_SIZE : Float;
			final MAX_UNIFORM_BUFFER_BINDINGS : Float;
			final MAX_VARYING_COMPONENTS : Float;
			final MAX_VERTEX_OUTPUT_COMPONENTS : Float;
			final MAX_VERTEX_UNIFORM_BLOCKS : Float;
			final MAX_VERTEX_UNIFORM_COMPONENTS : Float;
			final MIN : Float;
			final MIN_PROGRAM_TEXEL_OFFSET : Float;
			final OBJECT_TYPE : Float;
			final PACK_ROW_LENGTH : Float;
			final PACK_SKIP_PIXELS : Float;
			final PACK_SKIP_ROWS : Float;
			final PIXEL_PACK_BUFFER : Float;
			final PIXEL_PACK_BUFFER_BINDING : Float;
			final PIXEL_UNPACK_BUFFER : Float;
			final PIXEL_UNPACK_BUFFER_BINDING : Float;
			final QUERY_RESULT : Float;
			final QUERY_RESULT_AVAILABLE : Float;
			final R11F_G11F_B10F : Float;
			final R16F : Float;
			final R16I : Float;
			final R16UI : Float;
			final R32F : Float;
			final R32I : Float;
			final R32UI : Float;
			final R8 : Float;
			final R8I : Float;
			final R8UI : Float;
			final R8_SNORM : Float;
			final RASTERIZER_DISCARD : Float;
			final READ_BUFFER : Float;
			final READ_FRAMEBUFFER : Float;
			final READ_FRAMEBUFFER_BINDING : Float;
			final RED : Float;
			final RED_INTEGER : Float;
			final RENDERBUFFER_SAMPLES : Float;
			final RG : Float;
			final RG16F : Float;
			final RG16I : Float;
			final RG16UI : Float;
			final RG32F : Float;
			final RG32I : Float;
			final RG32UI : Float;
			final RG8 : Float;
			final RG8I : Float;
			final RG8UI : Float;
			final RG8_SNORM : Float;
			final RGB10_A2 : Float;
			final RGB10_A2UI : Float;
			final RGB16F : Float;
			final RGB16I : Float;
			final RGB16UI : Float;
			final RGB32F : Float;
			final RGB32I : Float;
			final RGB32UI : Float;
			final RGB8 : Float;
			final RGB8I : Float;
			final RGB8UI : Float;
			final RGB8_SNORM : Float;
			final RGB9_E5 : Float;
			final RGBA16F : Float;
			final RGBA16I : Float;
			final RGBA16UI : Float;
			final RGBA32F : Float;
			final RGBA32I : Float;
			final RGBA32UI : Float;
			final RGBA8 : Float;
			final RGBA8I : Float;
			final RGBA8UI : Float;
			final RGBA8_SNORM : Float;
			final RGBA_INTEGER : Float;
			final RGB_INTEGER : Float;
			final RG_INTEGER : Float;
			final SAMPLER_2D_ARRAY : Float;
			final SAMPLER_2D_ARRAY_SHADOW : Float;
			final SAMPLER_2D_SHADOW : Float;
			final SAMPLER_3D : Float;
			final SAMPLER_BINDING : Float;
			final SAMPLER_CUBE_SHADOW : Float;
			final SEPARATE_ATTRIBS : Float;
			final SIGNALED : Float;
			final SIGNED_NORMALIZED : Float;
			final SRGB : Float;
			final SRGB8 : Float;
			final SRGB8_ALPHA8 : Float;
			final STATIC_COPY : Float;
			final STATIC_READ : Float;
			final STENCIL : Float;
			final STREAM_COPY : Float;
			final STREAM_READ : Float;
			final SYNC_CONDITION : Float;
			final SYNC_FENCE : Float;
			final SYNC_FLAGS : Float;
			final SYNC_FLUSH_COMMANDS_BIT : Float;
			final SYNC_GPU_COMMANDS_COMPLETE : Float;
			final SYNC_STATUS : Float;
			final TEXTURE_2D_ARRAY : Float;
			final TEXTURE_3D : Float;
			final TEXTURE_BASE_LEVEL : Float;
			final TEXTURE_BINDING_2D_ARRAY : Float;
			final TEXTURE_BINDING_3D : Float;
			final TEXTURE_COMPARE_FUNC : Float;
			final TEXTURE_COMPARE_MODE : Float;
			final TEXTURE_IMMUTABLE_FORMAT : Float;
			final TEXTURE_IMMUTABLE_LEVELS : Float;
			final TEXTURE_MAX_LEVEL : Float;
			final TEXTURE_MAX_LOD : Float;
			final TEXTURE_MIN_LOD : Float;
			final TEXTURE_WRAP_R : Float;
			final TIMEOUT_EXPIRED : Float;
			final TIMEOUT_IGNORED : Float;
			final TRANSFORM_FEEDBACK : Float;
			final TRANSFORM_FEEDBACK_ACTIVE : Float;
			final TRANSFORM_FEEDBACK_BINDING : Float;
			final TRANSFORM_FEEDBACK_BUFFER : Float;
			final TRANSFORM_FEEDBACK_BUFFER_BINDING : Float;
			final TRANSFORM_FEEDBACK_BUFFER_MODE : Float;
			final TRANSFORM_FEEDBACK_BUFFER_SIZE : Float;
			final TRANSFORM_FEEDBACK_BUFFER_START : Float;
			final TRANSFORM_FEEDBACK_PAUSED : Float;
			final TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN : Float;
			final TRANSFORM_FEEDBACK_VARYINGS : Float;
			final UNIFORM_ARRAY_STRIDE : Float;
			final UNIFORM_BLOCK_ACTIVE_UNIFORMS : Float;
			final UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES : Float;
			final UNIFORM_BLOCK_BINDING : Float;
			final UNIFORM_BLOCK_DATA_SIZE : Float;
			final UNIFORM_BLOCK_INDEX : Float;
			final UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER : Float;
			final UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER : Float;
			final UNIFORM_BUFFER : Float;
			final UNIFORM_BUFFER_BINDING : Float;
			final UNIFORM_BUFFER_OFFSET_ALIGNMENT : Float;
			final UNIFORM_BUFFER_SIZE : Float;
			final UNIFORM_BUFFER_START : Float;
			final UNIFORM_IS_ROW_MAJOR : Float;
			final UNIFORM_MATRIX_STRIDE : Float;
			final UNIFORM_OFFSET : Float;
			final UNIFORM_SIZE : Float;
			final UNIFORM_TYPE : Float;
			final UNPACK_IMAGE_HEIGHT : Float;
			final UNPACK_ROW_LENGTH : Float;
			final UNPACK_SKIP_IMAGES : Float;
			final UNPACK_SKIP_PIXELS : Float;
			final UNPACK_SKIP_ROWS : Float;
			final UNSIGNALED : Float;
			final UNSIGNED_INT_10F_11F_11F_REV : Float;
			final UNSIGNED_INT_24_8 : Float;
			final UNSIGNED_INT_2_10_10_10_REV : Float;
			final UNSIGNED_INT_5_9_9_9_REV : Float;
			final UNSIGNED_INT_SAMPLER_2D : Float;
			final UNSIGNED_INT_SAMPLER_2D_ARRAY : Float;
			final UNSIGNED_INT_SAMPLER_3D : Float;
			final UNSIGNED_INT_SAMPLER_CUBE : Float;
			final UNSIGNED_INT_VEC2 : Float;
			final UNSIGNED_INT_VEC3 : Float;
			final UNSIGNED_INT_VEC4 : Float;
			final UNSIGNED_NORMALIZED : Float;
			final VERTEX_ARRAY_BINDING : Float;
			final VERTEX_ATTRIB_ARRAY_DIVISOR : Float;
			final VERTEX_ATTRIB_ARRAY_INTEGER : Float;
			final WAIT_FAILED : Float;
		};
		/**
			Part of the WebGL API and represents the information returned by calling the WebGLRenderingContext.getActiveAttrib() and WebGLRenderingContext.getActiveUniform() methods.
		**/
		var WebGLActiveInfo : {
			var prototype : js.html.webgl.ActiveInfo;
		};
		/**
			Part of the WebGL API and represents an opaque buffer object storing data such as vertices or colors.
		**/
		var WebGLBuffer : {
			var prototype : js.html.webgl.Buffer;
		};
		/**
			The WebContextEvent interface is part of the WebGL API and is an interface for an event that is generated in response to a status change to the WebGL rendering context.
		**/
		var WebGLContextEvent : {
			var prototype : js.html.webgl.ContextEvent;
		};
		/**
			Part of the WebGL API and represents a collection of buffers that serve as a rendering destination.
		**/
		var WebGLFramebuffer : {
			var prototype : js.html.webgl.Framebuffer;
		};
		var WebGLObject : {
			var prototype : js.html.WebGLObject;
		};
		/**
			The WebGLProgram is part of the WebGL API and is a combination of two compiled WebGLShaders consisting of a vertex shader and a fragment shader (both written in GLSL).
		**/
		var WebGLProgram : {
			var prototype : js.html.webgl.Program;
		};
		var WebGLQuery : {
			var prototype : js.html.webgl.Query;
		};
		/**
			Part of the WebGL API and represents a buffer that can contain an image, or can be source or target of an rendering operation.
		**/
		var WebGLRenderbuffer : {
			var prototype : js.html.webgl.Renderbuffer;
		};
		/**
			Provides an interface to the OpenGL ES 2.0 graphics rendering context for the drawing surface of an HTML <canvas> element.
		**/
		var WebGLRenderingContext : {
			var prototype : js.html.webgl.RenderingContext;
			final ACTIVE_ATTRIBUTES : Float;
			final ACTIVE_TEXTURE : Float;
			final ACTIVE_UNIFORMS : Float;
			final ALIASED_LINE_WIDTH_RANGE : Float;
			final ALIASED_POINT_SIZE_RANGE : Float;
			final ALPHA : Float;
			final ALPHA_BITS : Float;
			final ALWAYS : Float;
			final ARRAY_BUFFER : Float;
			final ARRAY_BUFFER_BINDING : Float;
			final ATTACHED_SHADERS : Float;
			final BACK : Float;
			final BLEND : Float;
			final BLEND_COLOR : Float;
			final BLEND_DST_ALPHA : Float;
			final BLEND_DST_RGB : Float;
			final BLEND_EQUATION : Float;
			final BLEND_EQUATION_ALPHA : Float;
			final BLEND_EQUATION_RGB : Float;
			final BLEND_SRC_ALPHA : Float;
			final BLEND_SRC_RGB : Float;
			final BLUE_BITS : Float;
			final BOOL : Float;
			final BOOL_VEC2 : Float;
			final BOOL_VEC3 : Float;
			final BOOL_VEC4 : Float;
			final BROWSER_DEFAULT_WEBGL : Float;
			final BUFFER_SIZE : Float;
			final BUFFER_USAGE : Float;
			final BYTE : Float;
			final CCW : Float;
			final CLAMP_TO_EDGE : Float;
			final COLOR_ATTACHMENT0 : Float;
			final COLOR_BUFFER_BIT : Float;
			final COLOR_CLEAR_VALUE : Float;
			final COLOR_WRITEMASK : Float;
			final COMPILE_STATUS : Float;
			final COMPRESSED_TEXTURE_FORMATS : Float;
			final CONSTANT_ALPHA : Float;
			final CONSTANT_COLOR : Float;
			final CONTEXT_LOST_WEBGL : Float;
			final CULL_FACE : Float;
			final CULL_FACE_MODE : Float;
			final CURRENT_PROGRAM : Float;
			final CURRENT_VERTEX_ATTRIB : Float;
			final CW : Float;
			final DECR : Float;
			final DECR_WRAP : Float;
			final DELETE_STATUS : Float;
			final DEPTH_ATTACHMENT : Float;
			final DEPTH_BITS : Float;
			final DEPTH_BUFFER_BIT : Float;
			final DEPTH_CLEAR_VALUE : Float;
			final DEPTH_COMPONENT : Float;
			final DEPTH_COMPONENT16 : Float;
			final DEPTH_FUNC : Float;
			final DEPTH_RANGE : Float;
			final DEPTH_STENCIL : Float;
			final DEPTH_STENCIL_ATTACHMENT : Float;
			final DEPTH_TEST : Float;
			final DEPTH_WRITEMASK : Float;
			final DITHER : Float;
			final DONT_CARE : Float;
			final DST_ALPHA : Float;
			final DST_COLOR : Float;
			final DYNAMIC_DRAW : Float;
			final ELEMENT_ARRAY_BUFFER : Float;
			final ELEMENT_ARRAY_BUFFER_BINDING : Float;
			final EQUAL : Float;
			final FASTEST : Float;
			final FLOAT : Float;
			final FLOAT_MAT2 : Float;
			final FLOAT_MAT3 : Float;
			final FLOAT_MAT4 : Float;
			final FLOAT_VEC2 : Float;
			final FLOAT_VEC3 : Float;
			final FLOAT_VEC4 : Float;
			final FRAGMENT_SHADER : Float;
			final FRAMEBUFFER : Float;
			final FRAMEBUFFER_ATTACHMENT_OBJECT_NAME : Float;
			final FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE : Float;
			final FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE : Float;
			final FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL : Float;
			final FRAMEBUFFER_BINDING : Float;
			final FRAMEBUFFER_COMPLETE : Float;
			final FRAMEBUFFER_INCOMPLETE_ATTACHMENT : Float;
			final FRAMEBUFFER_INCOMPLETE_DIMENSIONS : Float;
			final FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT : Float;
			final FRAMEBUFFER_UNSUPPORTED : Float;
			final FRONT : Float;
			final FRONT_AND_BACK : Float;
			final FRONT_FACE : Float;
			final FUNC_ADD : Float;
			final FUNC_REVERSE_SUBTRACT : Float;
			final FUNC_SUBTRACT : Float;
			final GENERATE_MIPMAP_HINT : Float;
			final GEQUAL : Float;
			final GREATER : Float;
			final GREEN_BITS : Float;
			final HIGH_FLOAT : Float;
			final HIGH_INT : Float;
			final IMPLEMENTATION_COLOR_READ_FORMAT : Float;
			final IMPLEMENTATION_COLOR_READ_TYPE : Float;
			final INCR : Float;
			final INCR_WRAP : Float;
			final INT : Float;
			final INT_VEC2 : Float;
			final INT_VEC3 : Float;
			final INT_VEC4 : Float;
			final INVALID_ENUM : Float;
			final INVALID_FRAMEBUFFER_OPERATION : Float;
			final INVALID_OPERATION : Float;
			final INVALID_VALUE : Float;
			final INVERT : Float;
			final KEEP : Float;
			final LEQUAL : Float;
			final LESS : Float;
			final LINEAR : Float;
			final LINEAR_MIPMAP_LINEAR : Float;
			final LINEAR_MIPMAP_NEAREST : Float;
			final LINES : Float;
			final LINE_LOOP : Float;
			final LINE_STRIP : Float;
			final LINE_WIDTH : Float;
			final LINK_STATUS : Float;
			final LOW_FLOAT : Float;
			final LOW_INT : Float;
			final LUMINANCE : Float;
			final LUMINANCE_ALPHA : Float;
			final MAX_COMBINED_TEXTURE_IMAGE_UNITS : Float;
			final MAX_CUBE_MAP_TEXTURE_SIZE : Float;
			final MAX_FRAGMENT_UNIFORM_VECTORS : Float;
			final MAX_RENDERBUFFER_SIZE : Float;
			final MAX_TEXTURE_IMAGE_UNITS : Float;
			final MAX_TEXTURE_SIZE : Float;
			final MAX_VARYING_VECTORS : Float;
			final MAX_VERTEX_ATTRIBS : Float;
			final MAX_VERTEX_TEXTURE_IMAGE_UNITS : Float;
			final MAX_VERTEX_UNIFORM_VECTORS : Float;
			final MAX_VIEWPORT_DIMS : Float;
			final MEDIUM_FLOAT : Float;
			final MEDIUM_INT : Float;
			final MIRRORED_REPEAT : Float;
			final NEAREST : Float;
			final NEAREST_MIPMAP_LINEAR : Float;
			final NEAREST_MIPMAP_NEAREST : Float;
			final NEVER : Float;
			final NICEST : Float;
			final NONE : Float;
			final NOTEQUAL : Float;
			final NO_ERROR : Float;
			final ONE : Float;
			final ONE_MINUS_CONSTANT_ALPHA : Float;
			final ONE_MINUS_CONSTANT_COLOR : Float;
			final ONE_MINUS_DST_ALPHA : Float;
			final ONE_MINUS_DST_COLOR : Float;
			final ONE_MINUS_SRC_ALPHA : Float;
			final ONE_MINUS_SRC_COLOR : Float;
			final OUT_OF_MEMORY : Float;
			final PACK_ALIGNMENT : Float;
			final POINTS : Float;
			final POLYGON_OFFSET_FACTOR : Float;
			final POLYGON_OFFSET_FILL : Float;
			final POLYGON_OFFSET_UNITS : Float;
			final RED_BITS : Float;
			final RENDERBUFFER : Float;
			final RENDERBUFFER_ALPHA_SIZE : Float;
			final RENDERBUFFER_BINDING : Float;
			final RENDERBUFFER_BLUE_SIZE : Float;
			final RENDERBUFFER_DEPTH_SIZE : Float;
			final RENDERBUFFER_GREEN_SIZE : Float;
			final RENDERBUFFER_HEIGHT : Float;
			final RENDERBUFFER_INTERNAL_FORMAT : Float;
			final RENDERBUFFER_RED_SIZE : Float;
			final RENDERBUFFER_STENCIL_SIZE : Float;
			final RENDERBUFFER_WIDTH : Float;
			final RENDERER : Float;
			final REPEAT : Float;
			final REPLACE : Float;
			final RGB : Float;
			final RGB565 : Float;
			final RGB5_A1 : Float;
			final RGBA : Float;
			final RGBA4 : Float;
			final SAMPLER_2D : Float;
			final SAMPLER_CUBE : Float;
			final SAMPLES : Float;
			final SAMPLE_ALPHA_TO_COVERAGE : Float;
			final SAMPLE_BUFFERS : Float;
			final SAMPLE_COVERAGE : Float;
			final SAMPLE_COVERAGE_INVERT : Float;
			final SAMPLE_COVERAGE_VALUE : Float;
			final SCISSOR_BOX : Float;
			final SCISSOR_TEST : Float;
			final SHADER_TYPE : Float;
			final SHADING_LANGUAGE_VERSION : Float;
			final SHORT : Float;
			final SRC_ALPHA : Float;
			final SRC_ALPHA_SATURATE : Float;
			final SRC_COLOR : Float;
			final STATIC_DRAW : Float;
			final STENCIL_ATTACHMENT : Float;
			final STENCIL_BACK_FAIL : Float;
			final STENCIL_BACK_FUNC : Float;
			final STENCIL_BACK_PASS_DEPTH_FAIL : Float;
			final STENCIL_BACK_PASS_DEPTH_PASS : Float;
			final STENCIL_BACK_REF : Float;
			final STENCIL_BACK_VALUE_MASK : Float;
			final STENCIL_BACK_WRITEMASK : Float;
			final STENCIL_BITS : Float;
			final STENCIL_BUFFER_BIT : Float;
			final STENCIL_CLEAR_VALUE : Float;
			final STENCIL_FAIL : Float;
			final STENCIL_FUNC : Float;
			final STENCIL_INDEX8 : Float;
			final STENCIL_PASS_DEPTH_FAIL : Float;
			final STENCIL_PASS_DEPTH_PASS : Float;
			final STENCIL_REF : Float;
			final STENCIL_TEST : Float;
			final STENCIL_VALUE_MASK : Float;
			final STENCIL_WRITEMASK : Float;
			final STREAM_DRAW : Float;
			final SUBPIXEL_BITS : Float;
			final TEXTURE : Float;
			final TEXTURE0 : Float;
			final TEXTURE1 : Float;
			final TEXTURE10 : Float;
			final TEXTURE11 : Float;
			final TEXTURE12 : Float;
			final TEXTURE13 : Float;
			final TEXTURE14 : Float;
			final TEXTURE15 : Float;
			final TEXTURE16 : Float;
			final TEXTURE17 : Float;
			final TEXTURE18 : Float;
			final TEXTURE19 : Float;
			final TEXTURE2 : Float;
			final TEXTURE20 : Float;
			final TEXTURE21 : Float;
			final TEXTURE22 : Float;
			final TEXTURE23 : Float;
			final TEXTURE24 : Float;
			final TEXTURE25 : Float;
			final TEXTURE26 : Float;
			final TEXTURE27 : Float;
			final TEXTURE28 : Float;
			final TEXTURE29 : Float;
			final TEXTURE3 : Float;
			final TEXTURE30 : Float;
			final TEXTURE31 : Float;
			final TEXTURE4 : Float;
			final TEXTURE5 : Float;
			final TEXTURE6 : Float;
			final TEXTURE7 : Float;
			final TEXTURE8 : Float;
			final TEXTURE9 : Float;
			final TEXTURE_2D : Float;
			final TEXTURE_BINDING_2D : Float;
			final TEXTURE_BINDING_CUBE_MAP : Float;
			final TEXTURE_CUBE_MAP : Float;
			final TEXTURE_CUBE_MAP_NEGATIVE_X : Float;
			final TEXTURE_CUBE_MAP_NEGATIVE_Y : Float;
			final TEXTURE_CUBE_MAP_NEGATIVE_Z : Float;
			final TEXTURE_CUBE_MAP_POSITIVE_X : Float;
			final TEXTURE_CUBE_MAP_POSITIVE_Y : Float;
			final TEXTURE_CUBE_MAP_POSITIVE_Z : Float;
			final TEXTURE_MAG_FILTER : Float;
			final TEXTURE_MIN_FILTER : Float;
			final TEXTURE_WRAP_S : Float;
			final TEXTURE_WRAP_T : Float;
			final TRIANGLES : Float;
			final TRIANGLE_FAN : Float;
			final TRIANGLE_STRIP : Float;
			final UNPACK_ALIGNMENT : Float;
			final UNPACK_COLORSPACE_CONVERSION_WEBGL : Float;
			final UNPACK_FLIP_Y_WEBGL : Float;
			final UNPACK_PREMULTIPLY_ALPHA_WEBGL : Float;
			final UNSIGNED_BYTE : Float;
			final UNSIGNED_INT : Float;
			final UNSIGNED_SHORT : Float;
			final UNSIGNED_SHORT_4_4_4_4 : Float;
			final UNSIGNED_SHORT_5_5_5_1 : Float;
			final UNSIGNED_SHORT_5_6_5 : Float;
			final VALIDATE_STATUS : Float;
			final VENDOR : Float;
			final VERSION : Float;
			final VERTEX_ATTRIB_ARRAY_BUFFER_BINDING : Float;
			final VERTEX_ATTRIB_ARRAY_ENABLED : Float;
			final VERTEX_ATTRIB_ARRAY_NORMALIZED : Float;
			final VERTEX_ATTRIB_ARRAY_POINTER : Float;
			final VERTEX_ATTRIB_ARRAY_SIZE : Float;
			final VERTEX_ATTRIB_ARRAY_STRIDE : Float;
			final VERTEX_ATTRIB_ARRAY_TYPE : Float;
			final VERTEX_SHADER : Float;
			final VIEWPORT : Float;
			final ZERO : Float;
		};
		var WebGLSampler : {
			var prototype : js.html.webgl.Sampler;
		};
		/**
			The WebGLShader is part of the WebGL API and can either be a vertex or a fragment shader. A WebGLProgram requires both types of shaders.
		**/
		var WebGLShader : {
			var prototype : js.html.webgl.Shader;
		};
		/**
			Part of the WebGL API and represents the information returned by calling the WebGLRenderingContext.getShaderPrecisionFormat() method.
		**/
		var WebGLShaderPrecisionFormat : {
			var prototype : js.html.webgl.ShaderPrecisionFormat;
		};
		var WebGLSync : {
			var prototype : js.html.webgl.Sync;
		};
		/**
			Part of the WebGL API and represents an opaque texture object providing storage and state for texturing operations.
		**/
		var WebGLTexture : {
			var prototype : js.html.webgl.Texture;
		};
		var WebGLTransformFeedback : {
			var prototype : js.html.webgl.TransformFeedback;
		};
		/**
			Part of the WebGL API and represents the location of a uniform variable in a shader program.
		**/
		var WebGLUniformLocation : {
			var prototype : js.html.webgl.UniformLocation;
		};
		var WebGLVertexArrayObject : {
			var prototype : js.html.webgl.VertexArrayObject;
		};
		var WebKitPoint : {
			var prototype : js.html.WebKitPoint;
		};
		/**
			Provides the API for creating and managing a WebSocket connection to a server, as well as for sending and receiving data on the connection.
		**/
		var WebSocket : {
			var prototype : js.html.WebSocket;
			final CLOSED : Float;
			final CLOSING : Float;
			final CONNECTING : Float;
			final OPEN : Float;
		};
		/**
			Events that occur due to the user moving a mouse wheel or similar input device.
		**/
		var WheelEvent : {
			var prototype : js.html.WheelEvent;
			final DOM_DELTA_LINE : Float;
			final DOM_DELTA_PAGE : Float;
			final DOM_DELTA_PIXEL : Float;
		};
		/**
			A window containing a DOM document; the document property points to the DOM document loaded in that window.
		**/
		var Window : {
			var prototype : js.html.Window;
		};
		/**
			This Web Workers API interface represents a background task that can be easily created and can send messages back to its creator. Creating a worker is as simple as calling the Worker() constructor and specifying a script to be run in the worker thread.
		**/
		var Worker : {
			var prototype : js.html.Worker;
		};
		var Worklet : {
			var prototype : js.html.Worklet;
		};
		/**
			This Streams API interface provides a standard abstraction for writing streaming data to a destination, known as a sink. This object comes with built-in backpressure and queuing.
		**/
		var WritableStream : {
			var prototype : js.html.WritableStream<Dynamic>;
		};
		/**
			An XML document. It inherits from the generic Document and does not add any specific methods or properties to it: nevertheless, several algorithms behave differently with the two types of documents.
		**/
		var XMLDocument : {
			var prototype : js.html.XMLDocument;
		};
		/**
			Use XMLHttpRequest (XHR) objects to interact with servers. You can retrieve data from a URL without having to do a full page refresh. This enables a Web page to update just part of a page without disrupting what the user is doing.
		**/
		var XMLHttpRequest : {
			var prototype : js.html.XMLHttpRequest;
			final DONE : Float;
			final HEADERS_RECEIVED : Float;
			final LOADING : Float;
			final OPENED : Float;
			final UNSENT : Float;
		};
		var XMLHttpRequestEventTarget : {
			var prototype : js.html.XMLHttpRequestEventTarget;
		};
		var XMLHttpRequestUpload : {
			var prototype : js.html.XMLHttpRequestUpload;
		};
		/**
			Provides the serializeToString() method to construct an XML string representing a DOM tree.
		**/
		var XMLSerializer : {
			var prototype : js.html.XMLSerializer;
		};
		/**
			The XPathEvaluator interface allows to compile and evaluate XPath expressions.
		**/
		var XPathEvaluator : {
			var prototype : js.html.XPathEvaluator;
		};
		/**
			This interface is a compiled XPath expression that can be evaluated on a document or specific node to return information its DOM tree.
		**/
		var XPathExpression : {
			var prototype : js.html.XPathExpression;
		};
		/**
			The results generated by evaluating an XPath expression within the context of a given node.
		**/
		var XPathResult : {
			var prototype : js.html.XPathResult;
			final ANY_TYPE : Float;
			final ANY_UNORDERED_NODE_TYPE : Float;
			final BOOLEAN_TYPE : Float;
			final FIRST_ORDERED_NODE_TYPE : Float;
			final NUMBER_TYPE : Float;
			final ORDERED_NODE_ITERATOR_TYPE : Float;
			final ORDERED_NODE_SNAPSHOT_TYPE : Float;
			final STRING_TYPE : Float;
			final UNORDERED_NODE_ITERATOR_TYPE : Float;
			final UNORDERED_NODE_SNAPSHOT_TYPE : Float;
		};
		/**
			An XSLTProcessor applies an XSLT stylesheet transformation to an XML document to produce a new XML document as output. It has methods to load the XSLT stylesheet, to manipulate <xsl:param> parameter values, and to apply the transformation to documents.
		**/
		var XSLTProcessor : {
			var prototype : js.html.XSLTProcessor;
		};
		var webkitRTCPeerConnection : {
			var prototype : js.html.WebkitRTCPeerConnection;
		};
		var Audio : { };
		var Image : { };
		var Option : { };
		var applicationCache : js.html.ApplicationCache;
		var caches : js.html.CacheStorage;
		var clientInformation : js.html.Navigator;
		var closed : Bool;
		var crypto : js.html.Crypto;
		var customElements : js.html.CustomElementRegistry;
		var defaultStatus : String;
		var devicePixelRatio : Float;
		var doNotTrack : String;
		var document : js.html.Document;
		var event : Null<js.html.Event>;
		var external : js.html.External;
		var frameElement : js.html.DOMElement;
		var frames : js.html.Window;
		var history : js.html.History;
		var innerHeight : Float;
		var innerWidth : Float;
		var isSecureContext : Bool;
		var length : Float;
		var location : js.html.Location;
		var locationbar : js.html.BarProp;
		var menubar : js.html.BarProp;
		var msContentScript : js.html.ExtensionScriptApis;
		var navigator : js.html.Navigator;
		var offscreenBuffering : ts.AnyOf2<String, Bool>;
		@:optional
		dynamic function oncompassneedscalibration(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function ondevicelight(ev:js.html.DeviceLightEvent):Dynamic;
		@:optional
		dynamic function ondevicemotion(ev:js.html.DeviceMotionEvent):Dynamic;
		@:optional
		dynamic function ondeviceorientation(ev:js.html.DeviceOrientationEvent):Dynamic;
		@:optional
		dynamic function ondeviceorientationabsolute(ev:js.html.DeviceOrientationEvent):Dynamic;
		@:optional
		dynamic function onmousewheel(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsgesturechange(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsgesturedoubletap(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsgestureend(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsgesturehold(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsgesturestart(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsgesturetap(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmsinertiastart(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointercancel(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointerdown(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointerenter(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointerleave(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointermove(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointerout(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointerover(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmspointerup(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onorientationchange(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onreadystatechange(ev:js.html.ProgressEvent<js.html.Window>):Dynamic;
		@:optional
		dynamic function onvrdisplayactivate(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplayblur(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplayconnect(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplaydeactivate(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplaydisconnect(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplayfocus(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplaypointerrestricted(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplaypointerunrestricted(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onvrdisplaypresentchange(ev:js.html.Event):Dynamic;
		var opener : Dynamic;
		var orientation : ts.AnyOf2<String, Float>;
		var outerHeight : Float;
		var outerWidth : Float;
		var pageXOffset : Float;
		var pageYOffset : Float;
		var parent : js.html.Window;
		var performance : js.html.Performance;
		var personalbar : js.html.BarProp;
		var screen : js.html.Screen;
		var screenLeft : Float;
		var screenTop : Float;
		var screenX : Float;
		var screenY : Float;
		var scrollX : Float;
		var scrollY : Float;
		var scrollbars : js.html.BarProp;
		var self : Dynamic;
		var speechSynthesis : js.html.SpeechSynthesis;
		var status : String;
		var statusbar : js.html.BarProp;
		var styleMedia : js.html.StyleMedia;
		var toolbar : js.html.BarProp;
		var top : js.html.Window;
		var window : Dynamic;
		var sessionStorage : js.html.Storage;
		var localStorage : js.html.Storage;
		/**
			The `console` module provides a simple debugging console that is similar to the
			JavaScript console mechanism provided by web browsers.
			
			The module exports two specific components:
			
			* A `Console` class with methods such as `console.log()`, `console.error()` and`console.warn()` that can be used to write to any Node.js stream.
			* A global `console` instance configured to write to `process.stdout` and `process.stderr`. The global `console` can be used without calling`require('console')`.
			
			_**Warning**_: The global console object's methods are neither consistently
			synchronous like the browser APIs they resemble, nor are they consistently
			asynchronous like all other Node.js streams. See the `note on process I/O` for
			more information.
			
			Example using the global `console`:
			
			```js
			console.log('hello world');
			// Prints: hello world, to stdout
			console.log('hello %s', 'world');
			// Prints: hello world, to stdout
			console.error(new Error('Whoops, something bad happened'));
			// Prints error message and stack trace to stderr:
			//   Error: Whoops, something bad happened
			//     at [eval]:5:15
			//     at Script.runInThisContext (node:vm:132:18)
			//     at Object.runInThisContext (node:vm:309:38)
			//     at node:internal/process/execution:77:19
			//     at [eval]-wrapper:6:22
			//     at evalScript (node:internal/process/execution:76:60)
			//     at node:internal/main/eval_string:23:3
			
			const name = 'Will Robinson';
			console.warn(`Danger ${name}! Danger!`);
			// Prints: Danger Will Robinson! Danger!, to stderr
			```
			
			Example using the `Console` class:
			
			```js
			const out = getStreamSomehow();
			const err = getStreamSomehow();
			const myConsole = new console.Console(out, err);
			
			myConsole.log('hello world');
			// Prints: hello world, to out
			myConsole.log('hello %s', 'world');
			// Prints: hello world, to out
			myConsole.error(new Error('Whoops, something bad happened'));
			// Prints: [Error: Whoops, something bad happened], to err
			
			const name = 'Will Robinson';
			myConsole.warn(`Danger ${name}! Danger!`);
			// Prints: Danger Will Robinson! Danger!, to err
			```
		**/
		var console : js.html.Console;
		/**
			Fires when the user aborts the download.
		**/
		@:optional
		dynamic function onabort(ev:js.html.UIEvent):Dynamic;
		@:optional
		dynamic function onanimationcancel(ev:js.html.AnimationEvent):Dynamic;
		@:optional
		dynamic function onanimationend(ev:js.html.AnimationEvent):Dynamic;
		@:optional
		dynamic function onanimationiteration(ev:js.html.AnimationEvent):Dynamic;
		@:optional
		dynamic function onanimationstart(ev:js.html.AnimationEvent):Dynamic;
		@:optional
		dynamic function onauxclick(ev:js.html.MouseEvent):Dynamic;
		/**
			Fires when the object loses the input focus.
		**/
		@:optional
		dynamic function onblur(ev:js.html.FocusEvent):Dynamic;
		@:optional
		dynamic function oncancel(ev:js.html.Event):Dynamic;
		/**
			Occurs when playback is possible, but would require further buffering.
		**/
		@:optional
		dynamic function oncanplay(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function oncanplaythrough(ev:js.html.Event):Dynamic;
		/**
			Fires when the contents of the object or selection have changed.
		**/
		@:optional
		dynamic function onchange(ev:js.html.Event):Dynamic;
		/**
			Fires when the user clicks the left mouse button on the object
		**/
		@:optional
		dynamic function onclick(ev:js.html.MouseEvent):Dynamic;
		@:optional
		dynamic function onclose(ev:js.html.Event):Dynamic;
		/**
			Fires when the user clicks the right mouse button in the client area, opening the context menu.
		**/
		@:optional
		dynamic function oncontextmenu(ev:js.html.MouseEvent):Dynamic;
		@:optional
		dynamic function oncuechange(ev:js.html.Event):Dynamic;
		/**
			Fires when the user double-clicks the object.
		**/
		@:optional
		dynamic function ondblclick(ev:js.html.MouseEvent):Dynamic;
		/**
			Fires on the source object continuously during a drag operation.
		**/
		@:optional
		dynamic function ondrag(ev:js.html.DragEvent):Dynamic;
		/**
			Fires on the source object when the user releases the mouse at the close of a drag operation.
		**/
		@:optional
		dynamic function ondragend(ev:js.html.DragEvent):Dynamic;
		/**
			Fires on the target element when the user drags the object to a valid drop target.
		**/
		@:optional
		dynamic function ondragenter(ev:js.html.DragEvent):Dynamic;
		@:optional
		dynamic function ondragexit(ev:js.html.Event):Dynamic;
		/**
			Fires on the target object when the user moves the mouse out of a valid drop target during a drag operation.
		**/
		@:optional
		dynamic function ondragleave(ev:js.html.DragEvent):Dynamic;
		/**
			Fires on the target element continuously while the user drags the object over a valid drop target.
		**/
		@:optional
		dynamic function ondragover(ev:js.html.DragEvent):Dynamic;
		/**
			Fires on the source object when the user starts to drag a text selection or selected object.
		**/
		@:optional
		dynamic function ondragstart(ev:js.html.DragEvent):Dynamic;
		@:optional
		dynamic function ondrop(ev:js.html.DragEvent):Dynamic;
		/**
			Occurs when the duration attribute is updated.
		**/
		@:optional
		dynamic function ondurationchange(ev:js.html.Event):Dynamic;
		/**
			Occurs when the media element is reset to its initial state.
		**/
		@:optional
		dynamic function onemptied(ev:js.html.Event):Dynamic;
		/**
			Occurs when the end of playback is reached.
		**/
		@:optional
		dynamic function onended(ev:js.html.Event):Dynamic;
		/**
			Fires when an error occurs during object loading.
		**/
		@:optional
		dynamic function onerror(event:ts.AnyOf2<String, js.html.Event>, ?source:String, ?lineno:Float, ?colno:Float, ?error:js.lib.Error):Dynamic;
		/**
			Fires when the object receives focus.
		**/
		@:optional
		dynamic function onfocus(ev:js.html.FocusEvent):Dynamic;
		@:optional
		dynamic function ongotpointercapture(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function oninput(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function oninvalid(ev:js.html.Event):Dynamic;
		/**
			Fires when the user presses a key.
		**/
		@:optional
		dynamic function onkeydown(ev:js.html.KeyboardEvent):Dynamic;
		/**
			Fires when the user presses an alphanumeric key.
		**/
		@:optional
		dynamic function onkeypress(ev:js.html.KeyboardEvent):Dynamic;
		/**
			Fires when the user releases a key.
		**/
		@:optional
		dynamic function onkeyup(ev:js.html.KeyboardEvent):Dynamic;
		/**
			Fires immediately after the browser loads the object.
		**/
		@:optional
		dynamic function onload(ev:js.html.Event):Dynamic;
		/**
			Occurs when media data is loaded at the current playback position.
		**/
		@:optional
		dynamic function onloadeddata(ev:js.html.Event):Dynamic;
		/**
			Occurs when the duration and dimensions of the media have been determined.
		**/
		@:optional
		dynamic function onloadedmetadata(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onloadend(ev:js.html.ProgressEvent<js.html.EventTarget>):Dynamic;
		/**
			Occurs when Internet Explorer begins looking for media data.
		**/
		@:optional
		dynamic function onloadstart(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onlostpointercapture(ev:js.html.PointerEvent):Dynamic;
		/**
			Fires when the user clicks the object with either mouse button.
		**/
		@:optional
		dynamic function onmousedown(ev:js.html.MouseEvent):Dynamic;
		@:optional
		dynamic function onmouseenter(ev:js.html.MouseEvent):Dynamic;
		@:optional
		dynamic function onmouseleave(ev:js.html.MouseEvent):Dynamic;
		/**
			Fires when the user moves the mouse over the object.
		**/
		@:optional
		dynamic function onmousemove(ev:js.html.MouseEvent):Dynamic;
		/**
			Fires when the user moves the mouse pointer outside the boundaries of the object.
		**/
		@:optional
		dynamic function onmouseout(ev:js.html.MouseEvent):Dynamic;
		/**
			Fires when the user moves the mouse pointer into the object.
		**/
		@:optional
		dynamic function onmouseover(ev:js.html.MouseEvent):Dynamic;
		/**
			Fires when the user releases a mouse button while the mouse is over the object.
		**/
		@:optional
		dynamic function onmouseup(ev:js.html.MouseEvent):Dynamic;
		/**
			Occurs when playback is paused.
		**/
		@:optional
		dynamic function onpause(ev:js.html.Event):Dynamic;
		/**
			Occurs when the play method is requested.
		**/
		@:optional
		dynamic function onplay(ev:js.html.Event):Dynamic;
		/**
			Occurs when the audio or video has started playing.
		**/
		@:optional
		dynamic function onplaying(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onpointercancel(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointerdown(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointerenter(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointerleave(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointermove(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointerout(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointerover(ev:js.html.PointerEvent):Dynamic;
		@:optional
		dynamic function onpointerup(ev:js.html.PointerEvent):Dynamic;
		/**
			Occurs to indicate progress while downloading media data.
		**/
		@:optional
		dynamic function onprogress(ev:js.html.ProgressEvent<js.html.EventTarget>):Dynamic;
		/**
			Occurs when the playback rate is increased or decreased.
		**/
		@:optional
		dynamic function onratechange(ev:js.html.Event):Dynamic;
		/**
			Fires when the user resets a form.
		**/
		@:optional
		dynamic function onreset(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onresize(ev:js.html.UIEvent):Dynamic;
		/**
			Fires when the user repositions the scroll box in the scroll bar on the object.
		**/
		@:optional
		dynamic function onscroll(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onsecuritypolicyviolation(ev:js.html.SecurityPolicyViolationEvent):Dynamic;
		/**
			Occurs when the seek operation ends.
		**/
		@:optional
		dynamic function onseeked(ev:js.html.Event):Dynamic;
		/**
			Occurs when the current playback position is moved.
		**/
		@:optional
		dynamic function onseeking(ev:js.html.Event):Dynamic;
		/**
			Fires when the current selection changes.
		**/
		@:optional
		dynamic function onselect(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onselectionchange(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onselectstart(ev:js.html.Event):Dynamic;
		/**
			Occurs when the download has stopped.
		**/
		@:optional
		dynamic function onstalled(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onsubmit(ev:js.html.Event):Dynamic;
		/**
			Occurs if the load operation has been intentionally halted.
		**/
		@:optional
		dynamic function onsuspend(ev:js.html.Event):Dynamic;
		/**
			Occurs to indicate the current playback position.
		**/
		@:optional
		dynamic function ontimeupdate(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function ontoggle(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function ontouchcancel(ev:js.html.TouchEvent):Dynamic;
		@:optional
		dynamic function ontouchend(ev:js.html.TouchEvent):Dynamic;
		@:optional
		dynamic function ontouchmove(ev:js.html.TouchEvent):Dynamic;
		@:optional
		dynamic function ontouchstart(ev:js.html.TouchEvent):Dynamic;
		@:optional
		dynamic function ontransitioncancel(ev:js.html.TransitionEvent):Dynamic;
		@:optional
		dynamic function ontransitionend(ev:js.html.TransitionEvent):Dynamic;
		@:optional
		dynamic function ontransitionrun(ev:js.html.TransitionEvent):Dynamic;
		@:optional
		dynamic function ontransitionstart(ev:js.html.TransitionEvent):Dynamic;
		/**
			Occurs when the volume is changed, or playback is muted or unmuted.
		**/
		@:optional
		dynamic function onvolumechange(ev:js.html.Event):Dynamic;
		/**
			Occurs when playback stops because the next frame of a video resource is not available.
		**/
		@:optional
		dynamic function onwaiting(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onwheel(ev:js.html.WheelEvent):Dynamic;
		var indexedDB : js.html.idb.Factory;
		var origin : String;
		@:optional
		dynamic function onafterprint(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onbeforeprint(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onbeforeunload(ev:js.html.BeforeUnloadEvent):Dynamic;
		@:optional
		dynamic function onhashchange(ev:js.html.HashChangeEvent):Dynamic;
		@:optional
		dynamic function onlanguagechange(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onmessage(ev:js.html.MessageEvent):Dynamic;
		@:optional
		dynamic function onmessageerror(ev:js.html.MessageEvent):Dynamic;
		@:optional
		dynamic function onoffline(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function ononline(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onpagehide(ev:js.html.PageTransitionEvent):Dynamic;
		@:optional
		dynamic function onpageshow(ev:js.html.PageTransitionEvent):Dynamic;
		@:optional
		dynamic function onpopstate(ev:js.html.PopStateEvent):Dynamic;
		@:optional
		dynamic function onrejectionhandled(ev:js.html.Event):Dynamic;
		@:optional
		dynamic function onstorage(ev:js.html.StorageEvent):Dynamic;
		@:optional
		dynamic function onunhandledrejection(ev:js.html.PromiseRejectionEvent):Dynamic;
		@:optional
		dynamic function onunload(ev:js.html.Event):Dynamic;
		function importScripts(urls:haxe.extern.Rest<String>):Void;
		var ActiveXObject : js.lib.ActiveXObject;
		var WScript : {
			/**
				Outputs text to either a message box (under WScript.exe) or the command console window followed by
				a newline (under CScript.exe).
			**/
			function Echo(s:Dynamic):Void;
			/**
				Exposes the write-only error output stream for the current script.
				Can be accessed only while using CScript.exe.
			**/
			var StdErr : js.lib.TextStreamWriter;
			/**
				Exposes the write-only output stream for the current script.
				Can be accessed only while using CScript.exe.
			**/
			var StdOut : js.lib.TextStreamWriter;
			var Arguments : {
				var length : Float;
				function Item(n:Float):String;
			};
			/**
				The full path of the currently running script.
			**/
			var ScriptFullName : String;
			/**
				Forces the script to stop immediately, with an optional exit code.
			**/
			function Quit(?exitCode:Float):Float;
			/**
				The Windows Script Host build version number.
			**/
			var BuildVersion : Float;
			/**
				Fully qualified path of the host executable.
			**/
			var FullName : String;
			/**
				Gets/sets the script mode - interactive(true) or batch(false).
			**/
			var Interactive : Bool;
			/**
				The name of the host executable (WScript.exe or CScript.exe).
			**/
			var Name : String;
			/**
				Path of the directory containing the host executable.
			**/
			var Path : String;
			/**
				The filename of the currently running script.
			**/
			var ScriptName : String;
			/**
				Exposes the read-only input stream for the current script.
				Can be accessed only while using CScript.exe.
			**/
			var StdIn : js.lib.TextStreamReader;
			/**
				Windows Script Host version
			**/
			var Version : String;
			/**
				Connects a COM object's event sources to functions named with a given prefix, in the form prefix_event.
			**/
			function ConnectObject(objEventSource:Dynamic, strPrefix:String):Void;
			/**
				Creates a COM object.
			**/
			function CreateObject(strProgID:String, ?strPrefix:String):Dynamic;
			/**
				Disconnects a COM object from its event sources.
			**/
			function DisconnectObject(obj:Dynamic):Void;
			/**
				Retrieves an existing object with the specified ProgID from memory, or creates a new one from a file.
			**/
			function GetObject(strPathname:String, ?strProgID:String, ?strPrefix:String):Dynamic;
			/**
				Suspends script execution for a specified length of time, then continues execution.
			**/
			function Sleep(intTime:Float):Void;
		};
		/**
			WSH is an alias for WScript under Windows Script Host
		**/
		var WSH : {
			/**
				Outputs text to either a message box (under WScript.exe) or the command console window followed by
				a newline (under CScript.exe).
			**/
			function Echo(s:Dynamic):Void;
			/**
				Exposes the write-only error output stream for the current script.
				Can be accessed only while using CScript.exe.
			**/
			var StdErr : js.lib.TextStreamWriter;
			/**
				Exposes the write-only output stream for the current script.
				Can be accessed only while using CScript.exe.
			**/
			var StdOut : js.lib.TextStreamWriter;
			var Arguments : {
				var length : Float;
				function Item(n:Float):String;
			};
			/**
				The full path of the currently running script.
			**/
			var ScriptFullName : String;
			/**
				Forces the script to stop immediately, with an optional exit code.
			**/
			function Quit(?exitCode:Float):Float;
			/**
				The Windows Script Host build version number.
			**/
			var BuildVersion : Float;
			/**
				Fully qualified path of the host executable.
			**/
			var FullName : String;
			/**
				Gets/sets the script mode - interactive(true) or batch(false).
			**/
			var Interactive : Bool;
			/**
				The name of the host executable (WScript.exe or CScript.exe).
			**/
			var Name : String;
			/**
				Path of the directory containing the host executable.
			**/
			var Path : String;
			/**
				The filename of the currently running script.
			**/
			var ScriptName : String;
			/**
				Exposes the read-only input stream for the current script.
				Can be accessed only while using CScript.exe.
			**/
			var StdIn : js.lib.TextStreamReader;
			/**
				Windows Script Host version
			**/
			var Version : String;
			/**
				Connects a COM object's event sources to functions named with a given prefix, in the form prefix_event.
			**/
			function ConnectObject(objEventSource:Dynamic, strPrefix:String):Void;
			/**
				Creates a COM object.
			**/
			function CreateObject(strProgID:String, ?strPrefix:String):Dynamic;
			/**
				Disconnects a COM object from its event sources.
			**/
			function DisconnectObject(obj:Dynamic):Void;
			/**
				Retrieves an existing object with the specified ProgID from memory, or creates a new one from a file.
			**/
			function GetObject(strPathname:String, ?strProgID:String, ?strPrefix:String):Dynamic;
			/**
				Suspends script execution for a specified length of time, then continues execution.
			**/
			function Sleep(intTime:Float):Void;
		};
		/**
			Allows enumerating over a COM collection, which may not have indexed item access.
		**/
		var Enumerator : js.lib.EnumeratorConstructor;
		/**
			Enables reading from a COM safe array, which might have an alternate lower bound, or multiple dimensions.
		**/
		var VBArray : js.lib.VBArrayConstructor;
		var Map : js.lib.MapConstructor;
		var WeakMap : js.lib.WeakMapConstructor;
		var Set : js.lib.SetConstructor;
		var WeakSet : js.lib.WeakSetConstructor;
		var Proxy : js.lib.ProxyConstructor;
		var SharedArrayBuffer : js.lib.SharedArrayBufferConstructor;
		var Atomics : js.lib.Atomics;
		var BigInt : js.lib.BigIntConstructor;
		/**
			A typed array of 64-bit signed integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated, an exception is raised.
		**/
		var BigInt64Array : js.lib.BigInt64ArrayConstructor;
		/**
			A typed array of 64-bit unsigned integer values. The contents are initialized to 0. If the
			requested number of bytes could not be allocated, an exception is raised.
		**/
		var BigUint64Array : js.lib.BigUint64ArrayConstructor;
		var process : global.nodejs.Process;
		var __filename : String;
		var __dirname : String;
		var require : global.NodeRequire;
		var module : global.NodeModule;
		var exports : Dynamic;
		/**
			Only available if `--expose-gc` is passed to the process.
		**/
		@:optional
		dynamic function gc():Void;
		var global : Dynamic;
		var Buffer : global.BufferConstructor;
		@:overload(function(callback:(args:ts.Undefined) -> Void):global.nodejs.Immediate { })
		function setImmediate<TArgs>(callback:(args:haxe.extern.Rest<Any>) -> Void, args:haxe.extern.Rest<Any>):global.nodejs.Immediate;
		function clearImmediate(immediateId:global.nodejs.Immediate):Void;
		var undefined : Null<Any>;
	};
}