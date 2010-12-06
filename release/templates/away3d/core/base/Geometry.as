﻿﻿package away3d.core.base{	import away3d.core.geom.Plane3D;
	import away3d.arcane;	import away3d.containers.*;	import away3d.core.utils.*;	import away3d.core.vos.*;	import away3d.events.*;	import away3d.loaders.data.*;	import away3d.materials.*;	import away3d.sprites.*;		import flash.events.*;	import flash.geom.*;	import flash.utils.*;        use namespace arcane;    	/**	 * Dispatched when the bounding dimensions of the geometry object change.	 * 	 * @eventType away3d.events.GeometryEvent	 */	[Event(name="dimensionsChanged",type="away3d.events.GeometryEvent")]    	/**	 * Dispatched when a sequence of animations completes.	 * 	 * @eventType away3d.events.AnimationEvent	 */	[Event(name="sequenceDone",type="away3d.events.AnimationEvent")]    	/**	 * Dispatched when a single animation in a sequence completes.	 * 	 * @eventType away3d.events.AnimationEvent	 */	[Event(name="cycle",type="away3d.events.AnimationEvent")]	    /**    * 3d object containing face and segment elements     */    public class Geometry extends EventDispatcher    {		/** @private */		arcane var indices:Vector.<int> = new Vector.<int>();		/** @private */		arcane var startIndices:Vector.<int> = new Vector.<int>();        /** @private */		private var _faceVOs:Vector.<FaceVO> = new Vector.<FaceVO>();        /** @private */		private var _segmentVOs:Vector.<SegmentVO> = new Vector.<SegmentVO>();        /** @private */		private var _spriteVOs:Vector.<SpriteVO> = new Vector.<SpriteVO>();		/** @private */		private var _verts:Vector.<Number> = new Vector.<Number>();		/** @private */		private var _texs:Vector.<Number> = new Vector.<Number>();		/** @private */		arcane var meshMaterialData:MeshMaterialData = new MeshMaterialData();		/** @private */        arcane function get faceVOs():Vector.<FaceVO>		{			if (_geometryDirty)				updateGeometry();                        return _faceVOs;        }        /** @private */        arcane function get segmentVOs():Vector.<SegmentVO>		{			if (_geometryDirty)				updateGeometry();                        return _segmentVOs;        }        /** @private */        arcane function get spriteVOs():Vector.<SpriteVO>		{			if (_geometryDirty)				updateGeometry();                        return _spriteVOs;        }        /** @private */        arcane function get verts():Vector.<Number>		{			if (_geometryDirty)				updateGeometry();            			if (_dimensionsDirty) {				_dimensionsDirty = false;				for each (_vertex in _vertices) {					if (_vertex._positionDirty) {						for each (_i in _vertex._vertIndices) {							_verts[_i] = _vertex.x;							_verts[uint(_i + 1)] = _vertex.y;							_verts[uint(_i + 2)] = _vertex.z;						}					}				}			}			            return _verts;        }        /** @private */        arcane function get texs():Vector.<Number> {			if (_mappingDirty) {				_mappingDirty = false;				for each (_uv in _uvs) {					if (_uv._mappingDirty) {						_i = _uv._texIndices[0];						_texs[_i] = _uv.u;						_texs[uint(_i + 1)] = 1 - _uv.v;						_texs[uint(_i + 2)] = 0;					}				}			}			            return _texs;        }        /** @private */		public function getFaceNormal(face:Face):Vector3D		{
			if (_fNormalsDirty)				updatefNormals();						return face._normal;        }        /** @private */		public function getFacePlane(face:Face):Plane3D		{			if (_faceplanesDirty)				findFacePlanes();						return _faceplanes[face];        }		/** @private */		public function getVertexNormal(vertex:Vertex):Vector3D        {            if (_vertnormalsDirty)                findVertNormals();                        return _vertnormals[vertex];        }		/** @private */        public function neighbour01(face:Face):Face        {            if (_neighboursDirty)                findNeighbours();                        return _neighbour01[face];        }		/** @private */        public function neighbour12(face:Face):Face        {            if (_neighboursDirty)                findNeighbours();                        return _neighbour12[face];        }		/** @private */        public function neighbour20(face:Face):Face        {            if (_neighboursDirty)                findNeighbours();                        return _neighbour20[face];        }		/** @private */        arcane function notifyDimensionsUpdate():void        {
			if (_dimensionsDirty)                return;                        _dimensionsDirty = true;            _vertnormalsDirty = true;            _verttangentsDirty = true;            _fNormalsDirty = true;            _faceplanesDirty = true;                        if (!hasEventListener(GeometryEvent.DIMENSIONS_CHANGED))            	return;                        if (!_dimensionsupdated)                _dimensionsupdated = new GeometryEvent(GeometryEvent.DIMENSIONS_CHANGED, this);                            dispatchEvent(_dimensionsupdated);                    }        /** @private */        arcane function notifyMappingUpdate():void         {         	if (_mappingDirty)                return;                        _mappingDirty = true;                        if (!hasEventListener(GeometryEvent.MAPPING_UPDATED))                return;			if (_mappingupdated == null)                _mappingupdated = new GeometryEvent(GeometryEvent.MAPPING_UPDATED, this);                        dispatchEvent(_mappingupdated);        }        /** @private */        arcane function notifyVisibleChange():void         {         	if (_visibleDirty)                return;                        _visibleDirty = true;                        if (!hasEventListener(GeometryEvent.VISIBLE_CHANGED))                return;			if (_visiblechanged == null)                _visiblechanged = new GeometryEvent(GeometryEvent.VISIBLE_CHANGED, this);                        dispatchEvent(_visiblechanged);        }        /** @private */        arcane function notifyGeometryChanged():void        {	            notifyDimensionsUpdate();            			if (_geometryDirty)                return;                        _geometryDirty = true;                        if (!hasEventListener(GeometryEvent.GEOMETRY_CHANGED))            	return;                        if (!_geometrychanged)                _geometrychanged = new GeometryEvent(GeometryEvent.GEOMETRY_CHANGED, this);                            dispatchEvent(_geometrychanged);                    }		/** @private */		arcane function addMaterial(element:Element, material:Material):void		{			if (!material) {				//special case for mesh material				meshMaterialData.elements.push(element);								notifyGeometryChanged();				return;			}						// detect if materialData exists
			if (!(_meshMaterialData = _materialDictionary[material._materialData])) {				_meshMaterialData = _materialDictionary[material._materialData] = new MeshMaterialData();								//set material property of materialData				_meshMaterialData.material = material;								_meshMaterialData.geometry = this;			}						//check if element is added to elements array			_meshMaterialData.elements.push(element);						notifyGeometryChanged();		}		/** @private */		arcane function removeMaterial(element:Element, material:Material):void		{			if (!material) {				//special case for mesh material				meshMaterialData.elements.splice(meshMaterialData.elements.indexOf(element), 1);								notifyGeometryChanged();				return;			}			
			_meshMaterialData = _materialDictionary[material._materialData];						//check if element is removed from elements array			_meshMaterialData.elements.splice(_meshMaterialData.elements.indexOf(element), 1);						//check if elements array is empty			if (!_meshMaterialData.elements.length) {				delete _materialDictionary[material._materialData];								//remove update listener				_meshMaterialData.geometry = null;			}						notifyGeometryChanged();		}		        private var _faces:Vector.<Face> = new Vector.<Face>();        private var _faceVO:FaceVO;        private var _segments:Vector.<Segment> = new Vector.<Segment>();        private var _segmentVO:SegmentVO;        private var _sprites:Vector.<Sprite3D> = new Vector.<Sprite3D>();        private var _spriteVO:SpriteVO;        private var _elements:Vector.<Element> =  new Vector.<Element>();        private var _vertices:Vector.<Vertex> = new Vector.<Vertex>();        private var _uvs:Vector.<UV> = new Vector.<UV>();        private var _processedUV:Dictionary;        private var _processedVertex:Dictionary;        private var _vertex:Vertex;        private var _uv:UV;        private var _element:Element;        private var _element_vertices:Vector.<Vertex>;        private var _element_uvs:Vector.<UV>;        private var _dimensionsDirty:Boolean;        private var _mappingDirty:Boolean;        private var _visibleDirty:Boolean;        private var _geometryDirty:Boolean;        private var _dimensionsupdated:GeometryEvent;        private var _mappingupdated:GeometryEvent;        private var _visiblechanged:GeometryEvent;        private var _geometrychanged:GeometryEvent;        private var _neighboursDirty:Boolean = true;        private var _neighbour01:Dictionary;        private var _neighbour12:Dictionary;        private var _neighbour20:Dictionary;        private var _vertnormalsDirty:Boolean = true;        private var _verttangentsDirty:Boolean = true;		private var _vertnormals:Dictionary;		private var _fNormalsDirty:Boolean = true;		private var _faceplanesDirty:Boolean = true;		private var _faceplanes:Dictionary;        private var _fNormal:Vector3D;        private var _fAngle:Number;        private var _fVectors:Vector.<Vector3D>;        private var clonedvertices:Dictionary;        private var cloneduvs:Dictionary;		private var _meshMaterialData:MeshMaterialData;		private var _material:Material;		private var _index:int;		private var _i:uint;		private var inverted:Boolean = false;		private var _quarterFacesTotal:int = 0;		private var _materialDictionary:Dictionary = new Dictionary(true);		private var _length:uint;		private var _p0:Vector3D;		private var _p1:Vector3D;		private var _p2:Vector3D;		private var _d1:Vector3D;		private var _d2:Vector3D;		private var _normal:Vector3D;		        private function addElement(element:Element):void        {			addMaterial(element, element.material);						element.parent = this;						_elements.push(element);						for each(_vertex in element.vertices)				_vertex.geometry = this;        }                private function removeElement(element:Element, index:uint):void        {            removeMaterial(element, element.material);                        element.parent = null;						_elements.splice(index, 1);						for each(_vertex in element.vertices)				_vertex.geometry = null;        }                private function updatefNormals():void		{			_fNormalsDirty = false;						for each (_element in elements) {                _element_vertices = _element.vertices;        						_p0 = _element_vertices[0].position;				_p1 = _element_vertices[1].position;				_p2 = _element_vertices[2].position;				            	_d1 = _p1.subtract(_p0);		    	_d2 = _p2.subtract(_p0);		    			    	_normal = _d1.crossProduct(_d2);		    	_normal.normalize();		    	_element._normal = _normal;			}		}                private function findFacePlanes():void        {        	if (_fNormalsDirty)				updatefNormals();						_faceplanes = new Dictionary(true);						var v0:Vertex;						var x : Number, y : Number, z : Number;			for each (var face:Face in faces)            {
				v0 = face.vertices[0];
				x = face._normal.x;  				y = face._normal.y;  				z = face._normal.z;  				var plane:Plane3D = new Plane3D();  				plane.a = -x;  				plane.b = -y;  				plane.c = -z;				plane.d = v0._x*x + v0._y*y + v0._z*z;  				  				if (x == 1 || x == -1) plane._alignment = Plane3D.X_AXIS;  				else if (y == 1 || y == -1) plane._alignment = Plane3D.Y_AXIS;  				else if (z == 1 || z == -1) plane._alignment = Plane3D.Z_AXIS;  				else plane._alignment = Plane3D.ANY;								plane.normalize();		    			    	_faceplanes[face] = plane;            }            			_faceplanesDirty = false;        }                private function findVertNormals():void        {
			if (_fNormalsDirty)				updatefNormals();			            _vertnormals = new Dictionary();                        for each (var v:Vertex in vertices) {
				var vF : Vector.<Element> = v.parents;            	var nX:Number = 0;            	var nY:Number = 0;            	var nZ:Number = 0;            	for each (var f:Face in vF) {
					_fNormal = f._normal;	            	_fVectors = new Vector.<Vector3D>();	            	var _f_vertices:Vector.<Vertex> = f.vertices;	            	var _vertex_diff:Vector3D;	            	for each (var fV:Vertex in _f_vertices) {	            		if (fV != v) {	            			_vertex_diff = fV.position.subtract(v.position);	            			_vertex_diff.normalize();	            			_fVectors.push(_vertex_diff);	            		}	            	}	            		            	_fAngle = Math.acos((_fVectors[0] as Vector3D).dotProduct(_fVectors[1] as Vector3D));            		nX += _fNormal.x*_fAngle;            		nY += _fNormal.y*_fAngle;            		nZ += _fNormal.z*_fAngle;            	}            	var vertNormal:Vector3D = new Vector3D(nX, nY, nZ);            	vertNormal.normalize();            	_vertnormals[v] = vertNormal;            }                        _vertnormalsDirty = false;            }                private function updateGeometry():void        {        	_geometryDirty = false;            _dimensionsDirty = false;                        _vertices.length = 0;            _uvs.length = 0;            indices.length = 0;            startIndices.length = 0;            _faceVOs.length = 0;            _segmentVOs.length = 0;            _spriteVOs.length = 0;            _verts.length = 0;            _processedVertex = new Dictionary(true);			_processedUV = new Dictionary(true);    		_length = 0;                        _verts.length = 0;            _texs.length = 0;    		            for each (_element in elements) {            	if (_element.visible && _element.vertices.length > 0) {                    _element_vertices = _element.vertices;            		_element_uvs = _element.uvs;            		startIndices[startIndices.length] = indices.length;                                		if (_element is Face) {            			_faceVO = (_element as Face).faceVO;            			_faceVOs[_faceVOs.length] = _faceVO;            		} else if (_element is Segment) {            			_segmentVO = (_element as Segment).segmentVO;            			_segmentVOs[_segmentVOs.length] = _segmentVO;            		} else if (_element is Sprite3D) {            			_spriteVO = (_element as Sprite3D).spriteVO;            			_spriteVOs[_spriteVOs.length] = _spriteVO;            		}            		            		_index = 0;                    while (_index < _element_vertices.length) {                    	                    	_vertex = _element_vertices[_index];                    	                    	if (_element_uvs && _element_uvs.length > _index)                    		_uv = _element_uvs[_index];                    	else                    		_uv = null;                    	                        if (!_processedVertex[_vertex]) {                        	indices[indices.length] = _length++;                            _vertices[_vertices.length] = _vertex;                            _vertex._vertIndices = Vector.<uint>([_verts.length]);                            _verts.push(_vertex.x, _vertex.y, _vertex.z);                            _processedVertex[_vertex] = _length;                            if (_uv) {                            	_uvs[_uvs.length] = _uv;                            	_uv._texIndices[0] = _texs.length;	                            _texs.push(_uv.u, 1 - _uv.v, 0);	                            _processedUV[_uv] = _length;                            } else {                            	_texs.push(0, 0, 0);                            }                        } else if (_uv && _processedVertex[_vertex] != _processedUV[_uv]) {                        	indices[indices.length] = _length++;                            _uvs[_uvs.length] = _uv;                            _uv._texIndices[0] = _texs.length;                            _vertex._vertIndices.push(_verts.length);                            _verts.push(_vertex.x, _vertex.y, _vertex.z);                            _processedVertex[_vertex] = _length;                            _texs.push(_uv.u, 1 - _uv.v, 0);                            _processedUV[_uv] = _length;                        } else {                        	indices[indices.length] = _processedVertex[_vertex] - 1;                        }                                                _index++;                    }                }            }                        startIndices[startIndices.length] = indices.length;        }        /** @private */		arcane function onMaterialUpdate(event:MaterialEvent):void		{			dispatchEvent(event);		}        		private function cloneVertex(vertex:Vertex):Vertex        {            var result:Vertex = clonedvertices[vertex];                        if (result == null) {                result = vertex.clone();                result.extra = (vertex.extra is IClonable) ? (vertex.extra as IClonable).clone() : vertex.extra;                clonedvertices[vertex] = result;            }                        return result;        }                private function cloneUV(uv:UV):UV        {            if (uv == null)                return null;            var result:UV = cloneduvs[uv];                        if (result == null) {                result = new UV(uv._u, uv._v);                cloneduvs[uv] = result;            }                        return result;        }		        /**         * Instance of the Init object used to hold and parse default property values         * specified by the initialiser object in the 3d object constructor.         */		protected var ini:Init;                public var useWeightedVertexNormals:Boolean;                /**        * Reference to the root heirarchy of bone controllers for a skin.        */        public var rootBone:Bone;		        /**        * An dictionary containing associations between cloned elements.        */        public var cloneElementDictionary:Dictionary = new Dictionary();                /**        * A graphics element in charge of managing the distribution of vector drawing commands into faces.        */        public var graphics:Graphics3D = new Graphics3D();        		/**		 * Set a new array of vertices for the mesh object.		 */		public function set vertices(v:Vector.<Vertex>):void        {			var i:int;			var _vlength:int = v.length;			var _length:int =_vertices.length;			if(_vlength == 0){				_vertices = new Vector.<Vertex>();				for( i = 0; i<_length;++i){            	_vertices[i] = null;				}				return;			}						for(i = 0; i<_vlength;++i){            	_vertices[i] = v[i];			}        }				/**		 * Returns the total number of times the geometry has been quartered.		 */        public function get quarterFacesTotal():int        {	        return _quarterFacesTotal;        }        		/**		 * Returns an array of the faces contained in the geometry object.		 */        public function get faces():Vector.<Face>        {            return _faces;        }				/**		 * Returns an array of the segments contained in the geometry object.		 */        public function get segments():Vector.<Segment>        {            return _segments;        }				/**		 * Returns an array of the 3d sprites contained in the geometry object.		 */        public function get sprites():Vector.<Sprite3D>        {            return _sprites;        }        		/**		 * Returns an array of all elements contained in the geometry object.		 */        public function get elements():Vector.<Element>        {            return _elements;        }                /**        * Returns an array of all vertices contained in the geometry object        */        public function get vertices():Vector.<Vertex>
		{
			if (_geometryDirty)				updateGeometry();			            return _vertices;        }                /**        * An dictionary containing all the materials included in the geometry.        */        public function get materialDictionary():Dictionary
		{			return _materialDictionary;	        }                /**		 * Creates a new <code>Geometry</code> object.         */                public function Geometry():void    	{    		graphics.geometry = this;    	}    			/**		 * Adds a face element to the geometry object.		 * 		 * @param	face	The face element to be added.		 */        public function addFace(face:Face):void        {			if(inverted)				face.invert();			            addElement(face);						for each(_uv in face.uvs)				_uv.geometry = this;			            _faces.push(face);        }				/**		 * Removes a face element from the geometry object.		 * 		 * @param	face	The face element to be removed.		 */        public function removeFace(face:Face):void        {            var index:int = _faces.indexOf(face);            if (index == -1)                return;			            removeElement(face, index);                        _faces.splice(index, 1);        }				/**		 * Adds a segment element to the geometry object.		 * 		 * @param	segment	The segment element to be added.		 */        public function addSegment(segment:Segment):void        {            addElement(segment);			            _segments.push(segment);        }				/**		 * Removes a segment element from the geometry object.		 * 		 * @param	segment	The segment element to be removed.		 */        public function removeSegment(segment:Segment):void        {            var index:int = _segments.indexOf(segment);            if (index == -1)                return;			            removeElement(segment, index);			            _segments.splice(index, 1);        }				/**		 * Adds a 3d sprite element to the geometry object.		 * 		 * @param	sprite3d	The 3d sprite element to be added.		 */        public function addSprite(sprite3d:Sprite3D):void        {            addElement(sprite3d);						var directionalSprite:DirectionalSprite = sprite3d as DirectionalSprite;			if (directionalSprite)				for each (_material in directionalSprite.materials)					addMaterial(sprite3d, _material);			            _sprites.push(sprite3d);        }				/**		 * Removes a 3d sprite element from the geometry object.		 * 		 * @param	sprite3d	The 3d sprite element to be removed.		 */        public function removeSprite(sprite3d:Sprite3D):void        {            var index:int = _sprites.indexOf(sprite3d);            if (index == -1)                return;			            removeElement(sprite3d, index);									var directionalSprite:DirectionalSprite = sprite3d as DirectionalSprite;			if (directionalSprite)				for each (_material in directionalSprite.materials)					removeMaterial(sprite3d, _material);			            _sprites.splice(index, 1);        }        		/**		 * Inverts the geometry of all face objects.		 * 		 * @see away3d.code.base.Face#invert()		 */        public function invertFaces():void        {			inverted ? inverted = false : inverted = true;            for each (var face:Face in _faces)                face.invert();        }				/**		* Divides all faces objects of a Mesh into 4 equal sized face objects.		* Used to segment a geometry in order to reduce affine persepective distortion.		* 		* @see away3d.primitives.SkyBox		*/        public function quarterFaces():void        {        	_quarterFacesTotal++;        	            var medians:Dictionary = new Dictionary();            for each (var face:Face in _faces.concat())               quarterFace(face, medians);        }		/**		* Divides a face object into 4 equal sized face objects.		* 		* @param	face	The face to split in 4 equal faces.		*/		public function quarterFace(face:Face, medians:Dictionary = null):void        {			if(medians == null)				medians = new Dictionary();						var v0:Vertex = face.vertices[0];			var v1:Vertex = face.vertices[1];			var v2:Vertex = face.vertices[2];						if (medians[v0] == null)				medians[v0] = new Dictionary();			if (medians[v1] == null)				medians[v1] = new Dictionary();			if (medians[v2] == null)				medians[v2] = new Dictionary();						var v01:Vertex = medians[v0][v1];			if (v01 == null) {				v01 = Vertex.median(v0, v1);				medians[v0][v1] = v01;				medians[v1][v0] = v01;			}						var v12:Vertex = medians[v1][v2];			if (v12 == null) {				v12 = Vertex.median(v1, v2);				medians[v1][v2] = v12;				medians[v2][v1] = v12;			}						var v20:Vertex = medians[v2][v0];			if (v20 == null) {				v20 = Vertex.median(v2, v0);				medians[v2][v0] = v20;				medians[v0][v2] = v20;			}						var uv0:UV = face.uvs[0];			var uv1:UV = face.uvs[1];			var uv2:UV = face.uvs[2];			var uv01:UV = UV.median(uv0, uv1);			var uv12:UV = UV.median(uv1, uv2);			var uv20:UV = UV.median(uv2, uv0);			var material:Material = face.material;						//remove old face			removeFace(face);						//add new faces			addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));			addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));			addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));			addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));		}				/**		* Divides all faces objects of a Mesh into 3 face objects.		* 		*/        public function triFaces():void        {            for each (var face:Face in _faces.concat([]))            {               triFace(face);            }        }		/**		* Divides a face object into 3 face objects.		* 		* @param	face	The face to split in 3 faces.		*/		public function triFace(face:Face):void        {			var v0:Vertex = face.vertices[0];			var v1:Vertex = face.vertices[1];			var v2:Vertex = face.vertices[2];						var vc:Vertex = new Vertex((v0.x+v1.x+v2.x)/3, (v0.y+v1.y+v2.y)/3, (v0.z+v1.z+v2.z)/3);						var uv0:UV = face.uvs[0];			var uv1:UV = face.uvs[1];			var uv2:UV = face.uvs[2];						var uvc:UV = new UV((uv0.u+uv1.u+uv2.u)/3, (uv0.v+uv1.v+uv2.v)/3);						var material:Material = face.material;			removeFace(face);						addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));			addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));			addFace(new Face(v0, vc, v2,  material, uv0, uvc, uv2));		}				/**		* Divides all faces objects of a Mesh into 2 face objects.		* 		* @param	side	The side of the faces to split in two. 0 , 1 or 2. (clockwize).		*/        public function splitFaces(side:int = 0):void        {			side = (side<0)? 0 : (side>2)? 2: side;            for each (var face:Face in _faces.concat([]))            {               splitFace(face, side);            }        }		/**		* Divides a face object into 2 face objects.		* 		* @param	face	The face to split in 2 faces.		* @param	side	The side of the face to split in two. 0 , 1 or 2. (clockwize).		*/		public function splitFace(face:Face, side:int = 0):void        {			var v0:Vertex = face.vertices[0];			var v1:Vertex = face.vertices[1];			var v2:Vertex = face.vertices[2];						var uv0:UV = face.uvs[0];			var uv1:UV = face.uvs[1];			var uv2:UV = face.uvs[2];						var vc:Vertex;			var uvc:UV;						var material:Material = face.material;			removeFace(face);						switch(side){				case 0:					vc = new Vertex((v0.x+v1.x)*.5, (v0.y+v1.y)*.5, (v0.z+v1.z)*.5);					uvc = new UV((uv0.u+uv1.u)*.5, (uv0.v+uv1.v)*.5);					addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));					addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));					break;				case 1:					vc = new Vertex((v1.x+v2.x)*.5, (v1.y+v2.y)*.5, (v1.z+v2.z)*.5);					uvc = new UV((uv1.u+uv2.u)*.5, (uv1.v+uv2.v)*.5);					addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));					addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));					break;				default:					vc = new Vertex((v2.x+v0.x)*.5, (v2.y+v0.y)*.5, (v2.z+v0.z)*.5);					uvc = new UV((uv2.u+uv0.u)*.5, (uv2.v+uv0.v)*.5);					addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));					addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));			}		}				private function findNeighbours():void        {            _neighbour01 = new Dictionary();            _neighbour12 = new Dictionary();            _neighbour20 = new Dictionary();                        var v0:Vertex;			var v1:Vertex;			var v2:Vertex;						var a0:Vertex;			var a1:Vertex;			var a2:Vertex;			            for each (var face:Face in _faces)            {                var skip:Boolean = true;            	v0 = face.vertices[0];				v1 = face.vertices[1];				v2 = face.vertices[2];                for each (var another:Face in _faces)                {										a0 = another.vertices[0];					a1 = another.vertices[1];					a2 = another.vertices[2];					                    if (skip)                    {                        if (face == another)                            skip = false;                        continue;                    }                    if ((v0 == a2) && (v1 == a1))                    {                        _neighbour01[face] = another;                        _neighbour12[another] = face;                    }                    if ((v0 == a0) && (v1 == a2))                    {                        _neighbour01[face] = another;                        _neighbour20[another] = face;                    }                    if ((v0 == a1) && (v1 == a0))                    {                        _neighbour01[face] = another;                        _neighbour01[another] = face;                    }                                    if ((v1 == a2) && (v2 == a1))                    {                        _neighbour12[face] = another;                        _neighbour12[another] = face;                    }                    if ((v1 == a0) && (v2 == a2))                    {                        _neighbour12[face] = another;                        _neighbour20[another] = face;                    }                    if ((v1 == a1) && (v2 == a0))                    {                        _neighbour12[face] = another;                        _neighbour01[another] = face;                    }                                    if ((v2 == a2) && (v0 == a1))                    {                        _neighbour20[face] = another;                        _neighbour12[another] = face;                    }                    if ((v2 == a0) && (v0 == a2))                    {                        _neighbour20[face] = another;                        _neighbour20[another] = face;                    }                    if ((v2 == a1) && (v0 == a0))                    {                        _neighbour20[face] = another;                        _neighbour01[another] = face;                    }                }            }            _neighboursDirty = false;        }                /**        * Updates the materials in the geometry object        */        public function updateMaterials(source:Object3D, view:View3D):void        {        	for each (var meshMaterialData:MeshMaterialData in _materialDictionary)        		if (meshMaterialData.material)        			meshMaterialData.material.updateMaterial(source, view);        }        		/**		 * Duplicates the geometry properties to another geometry object.		 * 		 * @return				The new geometry instance with duplicated properties applied.		 */        public function clone():Geometry        {            var geometry:Geometry = new Geometry();			            clonedvertices = new Dictionary();            cloneduvs = new Dictionary();                        for each (var face:Face in _faces)            {            	var cloneFace:Face = new Face(cloneVertex(face.vertices[0]), cloneVertex(face.vertices[1]), cloneVertex(face.vertices[2]), face.material, cloneUV(face.uvs[0]), cloneUV(face.uvs[1]), cloneUV(face.uvs[2]));                geometry.addFace(cloneFace);                cloneElementDictionary[face] = cloneFace;            }                        for each (var segment:Segment in _segments)            {                var cloneSegment:Segment = new Segment(cloneVertex(segment.vertices[0]), cloneVertex(segment.vertices[1]), segment.material);                geometry.addSegment(cloneSegment);                cloneElementDictionary[segment] = cloneSegment;            }                        return geometry;        }				/** 		 * update vertex information. 		 *  		 * @param		v						The vertex object to update 		 * @param		x						The new x value for the vertex 		 * @param		y						The new y value for the vertex 		 * @param		z						The new z value for the vertex		 * @param		refreshNormals	[optional]	Defines whether normals should be recalculated 		 *  		 */		public function updateVertex(v:Vertex, x:Number, y:Number, z:Number, refreshNormals:Boolean = false):void		{			v.setValue(x,y,z);		}				/**		 * Default method for adding a geometryUpdated event listener		 * 		 * @param	listener		The listener function		 */        public function addOnGeometryUpdate(listener:Function):void        {			addEventListener(GeometryEvent.GEOMETRY_UPDATED, listener, false, 0, true);        }				/**		 * Default method for removing a geometryUpdated event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnGeometryUpdate(listener:Function):void        {            removeEventListener(GeometryEvent.GEOMETRY_UPDATED, listener, false);        }        		/**		 * Default method for adding a geometryChanged event listener		 * 		 * @param	listener		The listener function		 */        public function addOnGeometryChange(listener:Function):void        {			addEventListener(GeometryEvent.GEOMETRY_CHANGED, listener, false, 0, true);        }				/**		 * Default method for removing a geometryChanged event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnGeometryChange(listener:Function):void        {            removeEventListener(GeometryEvent.GEOMETRY_CHANGED, listener, false);        }        		/**		 * Default method for adding a dimensionsChanged event listener		 * 		 * @param	listener		The listener function		 */        public function addOnDimensionsUpdate(listener:Function):void        {
			addEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false, 0, true);        }				/**		 * Default method for removing a dimensionsChanged event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnDimensionsUpdate(listener:Function):void        {            removeEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false);        }        		/**		 * Default method for adding a materialUpdated event listener		 * 		 * @param	listener		The listener function		 */        public function addOnMaterialUpdate(listener:Function):void        {            addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);        }				/**		 * Default method for removing a materialUpdated event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnMaterialUpdate(listener:Function):void        {            removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);        }        		/**		 * Default method for adding a mappingChanged event listener		 * 		 * @param	listener		The listener function		 */        public function addOnMappingChange(listener:Function):void        {            addEventListener(GeometryEvent.MAPPING_CHANGED, listener, false, 0, true);        }				/**		 * Default method for removing a mappingChanged event listener		 * 		 * @param	listener		The listener function		 */        public function removeOnMappingChange(listener:Function):void        {            removeEventListener(GeometryEvent.MAPPING_CHANGED, listener, false);        }    }}