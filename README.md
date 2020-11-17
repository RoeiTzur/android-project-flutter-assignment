1. The controller pattern is implemented by the 'SnappingSheetController' class.
With snapPositions & currentSnapPosition, the developer can control the sheet position: 
The wanted positions can be define in 'snapPositions' list, and the developer can assign the
next wanted position according to the currentSnapPosition.

2. The mentioned paramater is 'snappingCurve' (inside SnapPosition class). It has various
different animations the developer can use.

3. As mentioned in the doc, InkWell has ripple effect, which's not included in GestureDetector.
On the other hand, GestureDetector provides the developer with more options rather than click
like in InkWell (other tapping functions, dragging, etc.).