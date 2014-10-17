'From Cuis 4.0 of 21 April 2012 [latest update: #1260] on 17 October 2014 at 10:48:11 am'!


!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:20'!
Avogadro^ self * 6.0221413e23	! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:10'!
MeV	| measure |	measure := HumMeasure quantity: ( self * 1.60217653/1e13  ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:57'!
acre	| measure |	measure := HumMeasure quantity: (self * 4046.873) units: #squareMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:57'!
amu	" atomic mass unit "	| m |	m := self atomicMassUnit.	^m! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:57'!
astronomicalUnit	"average distance between Earth and Sun"	| measure |	measure := HumMeasure quantity: (self * 149597870700 ) units: #meter.	"TODO: Correct above factor ((1 au) as: #miles) should be about 93e6 miles"	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:57'!
atomicMassUnit	" atomic mass unit "	| m |	m := HumMeasure new.	m quantity: (self * 1.66053873e-27) units: #kilogram.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
au	"astronomical units"	| measure |	measure := self astronomicalUnit.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:18'!
avogadro^ self * 6.0221413e+23	! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
bar	"pressure -- one bar is approximately one atmosphere"	| measure |	measure := HumMeasure quantity: ( self * 1e5 ) units: #pascal.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
britishThermalUnit	"Energy - British Thermal Unit (ISO)"	| measure |	measure := HumMeasure quantity: ( self * 1.0545) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
btu	"Energy - British Thermal Unit (ISO)"	| measure |	measure := self britishThermalUnit.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/12/2013 14:10'!
centimeter	| measure |	measure := HumMeasure quantity: ( self / 100.0 ) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
cosmicConstant	" on the order of 1e-29 grams / cubic centimeter "	| m q kg g cubicCentimeter cubicMeter|	kg := 1.	g := 1.	cubicCentimeter := 1.	cubicMeter := 1.	q := 1.0e-29 * ( 1 * kg / 1000 * g ) * ( 1e6 * cubicCentimeter / 1* cubicMeter ).	self assert: (q closeTo: 1.0e-26).	m := HumMeasure quantity: (self * 1.0e-26) units: #kilogram per: 'cubic meter'.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
cosmicScale	"on the order of 10e25 meters"	| m |	m := HumMeasure quantity: (self * 1.0e25) units: #meter.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
cubicCentimeter	| measure |	measure := HumMeasure quantity: (self * 1.0e-6) units: 'cubic meter'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
cubicFoot	| measure |	measure := HumMeasure quantity: ( self * 0.028316846592 ) units: #cubicMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
cubicInch	| measure |	measure := HumMeasure quantity: ( self * 16.387064e-6 ) units: #cubicMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
cubicMeter	| measure |	measure := HumMeasure quantity: (self) units: #cubicMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
degree	"return as a HumMeasure - angular degree "	| measure |	measure := HumMeasure quantity: (self) units: #degree.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:58'!
degreeCentigrade	"return as a HumMeasure"	| measure |	measure := HumMeasure quantity: (self) units: #degreeCentigrade.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
degreeKelvin	"return as a HumMeasure"	| measure |	measure := HumMeasure quantity: (self) units: #degreeKelvin.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
degrees	"return as a HumMeasure - angular degree "	| measure |	measure := HumMeasure quantity: (self) units: #degree.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
dyne	"force"	| measure |	measure := HumMeasure quantity: ( self * 1e-5 ) units: #newton.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:09'!
eV	| measure |	measure := HumMeasure quantity: ( self * 1.60217653/1e19  ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
erg	| measure |	measure := HumMeasure quantity: ( self * 1e-7 ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
feet	| measure |	measure := self foot.	^ measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
foot	| measure |	measure := HumMeasure quantity: (self * 0.304799735) units: #meter.	^ measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
footH2O	"foot of water - pressure"	| measure |	measure := HumMeasure quantity: ( self * 2.98898e3 ) units: #pascal.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
gram	| measure |	measure := (self / 1000.0 ) kilogram.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
gravity	| measure |	measure := HumMeasure quantity: (self * 9.80665) units: 'meter' per: 'square second'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
hectare	"area equivalent to 100 meter by 100 meter = 10 thousand square meters"	| measure |	measure := HumMeasure quantity: (self * 10e3) units: #squareMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:59'!
horsePower	| measure |	measure := HumMeasure quantity: ( self * 735.49875 ) units: #watt.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
hp	"horse-power"	| measure |	measure := self horsePower.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
inch	| measure |	measure := HumMeasure quantity: (self * 0.0254) units: 'meter'.	^ measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
inches	| measure |	measure := self inch.	^ measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
joule	"Energy or Work equal to 1 Newton-meter"	| measure |	measure := HumMeasure quantity: ( self ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:19'!
keV	| measure |	measure := HumMeasure quantity: ( self * 1.60217653/1e10  ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
kg	| m |	m := self kilogram.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/30/2014 10:57'!
kiloWatt	" 1 Joule per second := 1e7 erg per second"	| measure |	measure := HumMeasure quantity: ( self * 1e3 ) units: #Watt.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
kilogram	| m |	m := HumMeasure new.	m quantity: (self) units: #kilogram.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
kilometer	| m |	m := HumMeasure new.	m quantity: (self) * 1000 units: #meter.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
kilometerPerSecond	"kilometers per second"	| measure |	measure := HumMeasure quantity: (self * 1000) units: 'meter' per: 'second'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
kilometers	| m |	m := self kilometer.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
knots	"Nautical miles (ISO)"	| measure |	measure := HumMeasure quantity: (self * 1852.0) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:00'!
kps	"kilometers per second"	| measure |	measure := self kilometerPerSecond.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
lbf	"pound force"	"See also: pound mass ==> Number>>pound"	| measure |	measure := HumMeasure quantity: ( self * 4.448222 ) units: #newton.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
lightSecond	| measure |	measure := HumMeasure quantity: (self * 2.99792458e8) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
lightSpeed	| measure |	measure := HumMeasure quantity: (self * 2.99792458e8) units: #meter per: #second.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
lightYear	| measure |	measure := HumMeasure quantity: (self * 9.4607304725808e15) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
litre	| measure |	measure := HumMeasure quantity: (self * 0.001) units: #cubicMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:18'!
meV	| measure |	measure := HumMeasure quantity: ( self * 1.60217653/1e13  ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/30/2014 12:30'!
megaWatt	" 1 Joule per second := 1e7 erg per second"	| measure |	measure := (self * 1000) watt.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
meter	| measure |	measure := HumMeasure quantity: (self) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
meterPerSecond	"meter per second"	| measure |	measure := HumMeasure quantity: (self) units: 'meter' per: 'second'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
meters	| measure |	measure := self meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
mile	| measure |	measure := HumMeasure quantity: (self * 1609.34) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
miles	| measure |	measure := self mile.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
milesPerHour	"miles per hour - converted to meters per second"	| measure factor |	factor := (1 mile quantity)/3600.0.	measure := HumMeasure quantity: ( self * factor ) units: 'meter' per: 'second'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
milligram	| measure |	measure := (self / 1000.0 ) gram.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/12/2013 14:10'!
millimeter	| measure |	measure := HumMeasure quantity: ( self / 1000.0 ) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/31/2014 21:19'!
millionElectronVolt	| measure |	measure := HumMeasure quantity: ( self * 1.60217653/1e13  ) units: #joule.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:01'!
mmHg	"millimeters of mercury - pressure"	| measure |	measure := HumMeasure quantity: ( self * 133.3224 ) units: #pascal.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
mph	"miles per hour - converted to meters per second"	| measure factor |	measure := self milesPerHour.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
mps	"meters per second"	| measure |	measure := self meterPerSecond.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
newton	"unit of force in Newtons -- 1 kg·m/s^2"	| measure |	measure := HumMeasure quantity: ( self ) units: #newton.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 11:53'!
parsec"Wikipedia: One parsec equals about 3.26 light-years or 30.9 trillion kilometres (19.2 trillion miles). All known stars (except the Sun) are more than one parsec away, with Proxima Centauri showing the largest parallax of 0.7687 arcsec, making the distance 1.3009 parsec (4.243 light years.)[1] Most of the visible stars in the nighttime sky lie within 500 parsecs of the Sun."	| measure |	measure := (self lightYear) * 3.26.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
pascal	"pressure - Pascal"	| measure |	measure := HumMeasure quantity: ( self ) units: #pascal.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
percent	"percent"	| measure |	measure := HumMeasure quantity: (self) units: '%'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
pixel	"pixels"	| measure |	"Need to abbreviate because that is how SVG and HTML expects to see it."	measure := HumMeasure quantity: (self) units: 'px'.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
pound	" pound mass 	Note: lbf is pound force"	| m |	m := HumMeasure new.	m quantity: (self * 0.45359237) units: #kilogram.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:02'!
poundMass	" pound mass - lbm"	| m |	m := HumMeasure new.	m quantity: (self * 0.45359237) units: #kilogram.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:03'!
poundPerSquareInch	"pound per square inch - pressure"	| measure |	measure := HumMeasure quantity: ( self * 6.894757e3 ) units: #pascal.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:03'!
psi	"pound per square inch - pressure"	| measure |	measure := self poundPerSquareInch.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:03'!
px	"pixels"	| measure |	measure := self pixel.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:03'!
squareMeter	| measure |	measure := HumMeasure quantity: (self) units: #squareMeter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:03'!
tonne	"metric ton"	| m |	m := HumMeasure new.	m quantity: (self * 1000) units: #kilogram.	^m.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 5/30/2014 10:58'!
watt	" 1 Joule per second := 1e7 erg per second"	| measure |	measure := HumMeasure quantity: ( self ) units: #Watt.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:03'!
yard	| measure |	measure := HumMeasure quantity: (self * 0.9144) units: #meter.	^measure.! !

!Number methodsFor: '*Hum' stamp: 'RichardAlexanderGreen 12/8/2013 12:04'!
yards	| measure |	measure := self yard.	^measure.! !
