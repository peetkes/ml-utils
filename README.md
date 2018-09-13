# ml-utils

various MarkLogic Utility XQuery modules

### Exif Library

This library can be used to extract all exif properties from jpeg images.
To use this library you need to import the module and pass in an image as a binary object.
It will return a map witt properties, Two properties contain a map with properties

* ExifProps
* GPSProps

```xquery
xquery version "1.0-ml";
import module namespace exif-consts = "http://marklogic.com/exif/consts" at "/lib/exif-consts.xqy";
import module namespace exif = "http://marklogic.com/exif-parser" at "/lib/exif-lib.xqy";

declare option xdmp:mapping "false";

let $image := xdmp:external-binary("some location on disk")
return exif:extract-exif-properties(xdmp:external-binary($image))
```
This will result in something like below

```xml
<map:map xmlns:map="http://marklogic.com/xdmp/map" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<map:entry key="Software">
		<map:value xsi:type="xs:string">11.1.2</map:value>
	</map:entry>
	<map:entry key="Orientation">
		<map:value xsi:type="xs:integer">6</map:value>
	</map:entry>
	<map:entry key="XResolution">
		<map:value xsi:type="xs:string">72</map:value>
	</map:entry>
	<map:entry key="YResolution">
		<map:value xsi:type="xs:string">72</map:value>
	</map:entry>
	<map:entry key="Model">
		<map:value xsi:type="xs:string">iPhone 7</map:value>
	</map:entry>
	<map:entry key="ResolutionUnit">
		<map:value xsi:type="xs:integer">2</map:value>
	</map:entry>
	<map:entry key="ModifyDate">
		<map:value xsi:type="xs:string">2017:11:27 18:00:31</map:value>
	</map:entry>
	<map:entry key="ExifProps">
		<map:value>
			<map:map>
				<map:entry key="LensModel">
					<map:value xsi:type="xs:string">iPhone 7 back camera 3.99mm f/1.8</map:value>
				</map:entry>
				....
			</map:map>
		</map:value>
	</map:entry>
	<map:entry key="Make">
		<map:value xsi:type="xs:string">Apple</map:value>
	</map:entry>
	<map:entry key="GPSProps">
		<map:value>
			<map:map>
				<map:entry key="GPSDestBearingRef">
					<map:value xsi:type="xs:string">T</map:value>
				</map:entry>
				....
			</map:map>
		</map:value>
	</map:entry>
</map:map>
```