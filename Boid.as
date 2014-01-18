﻿package {	import flash.geom.Point;	import flash.display.Sprite;	public class Boid extends Sprite {		public var currentVector:Point = new Point(Math.random(),Math.random());		public var mass:Number = 1;		public var master:BoidController;		public var speedEasing:Number = 10;		public var sightRange:int = 55;		//minimum distance allowed		public var blindSpotDegrees:Number = 30;		public var personalSpace:int = 10;		public var cruisingSpeed:Number = 3;		public var maxSpeed:Number = 2 * cruisingSpeed;		public var minSpeed:Number = .5 * cruisingSpeed;		public var currentSpeed:Number = 4;		public var hue:Number;		public var rotationGoal;		public override function Boid(master:BoidController, hue:Number):void {			this.hue = hue;			this.master = master;			graphics.clear();			graphics.beginFill(0x333333, 1);			//graphics.drawCircle(0, 0, personalSpace);			graphics.beginFill(0x0000FF, .12);			graphics.drawCircle(0, 0, sightRange);		}		public function update():void {			var totalMass:int = 0;			var totalVectors:Point = new Point(0,0);			var centerOfGravity:Point = new Point(0,0);			var tooClose:Boolean = false;			var flock:Boolean = false;			var hueDiff:Number = 0;			//for every boid in the array			for (var i:uint = 0; i < master.boidArray.length; i++) {				//grab it				var otherBoid:Boid = master.boidArray[i];				var currentDistance:Number = cartesianDistance(new Point(this.x,this.y),new Point(otherBoid.x,otherBoid.y));				hueDiff = diffDegrees(otherBoid.hue);				//if it is close enough to see				if ( currentDistance < sightRange && currentDistance != 0 ) {					if (hueDiff < 50) {						var differenceDegrees:Number = (vectorToDegrees(new Point(otherBoid.x - this.x,otherBoid.y - this.y)) - vectorToDegrees(currentVector));						differenceDegrees = Math.abs(differenceDegrees);						//trace(differenceDegrees);						//if it isn't in my blind spot						if ((differenceDegrees < 180-(blindSpotDegrees/2) || differenceDegrees > 180+(blindSpotDegrees/2))&& otherBoid.mass >= this.mass) {							flock = true;							totalMass +=  otherBoid.mass;							centerOfGravity.x += ((otherBoid.x - this.x) * otherBoid.mass );							centerOfGravity.y += ((otherBoid.y - this.y) * otherBoid.mass );							totalVectors.x += (otherBoid.currentVector.x * otherBoid.mass );							totalVectors.y += (otherBoid.currentVector.y * otherBoid.mass );							//check too_close							if ((currentDistance < personalSpace+otherBoid.personalSpace) && currentDistance != 0 ) {//|| nextDistance < personalSpace+otherBoid.personalSpace								tooClose = true;								//if next position is closer than current								if (differenceDegrees < 90 || differenceDegrees > 270) {									//slow down									currentSpeed +=  (minSpeed - currentSpeed) / speedEasing;									//currentSpeed += (otherBoid.currentSpeed*.5-currentSpeed)/speedEasing;									//if my next position is farther than current								}								else {									//speed up									//currentSpeed +=  (maxSpeed - currentSpeed) / speedEasing;									currentSpeed += (otherBoid.currentSpeed*2 - currentSpeed)/speedEasing;								}							}						}						//if they are really different, push them away					}else if (hueDiff > 120){						var recoilVector:Point = new Point(otherBoid.x - this.x, otherBoid.y - this.y);						recoilVector = normalizeVector(recoilVector, 1);						otherBoid.currentSpeed += .1;						otherBoid.currentVector.x += recoilVector.x;						otherBoid.currentVector.y += recoilVector.y;					}				}			}			//if I saw other boids			if (flock) {				//average gravity/vectors				centerOfGravity = normalizeVector(centerOfGravity,cruisingSpeed / 3);				totalVectors = normalizeVector(totalVectors,cruisingSpeed);				//make next vector				if (tooClose == true) {					centerOfGravity.x *=  -1;					centerOfGravity.y *=  -1;				}				currentVector.x += (centerOfGravity.x + totalVectors.x);				currentVector.y += (centerOfGravity.y + totalVectors.y);			}			currentVector = normalizeVector(currentVector,currentSpeed);			if (tooClose == false) {				currentSpeed +=  (cruisingSpeed - currentSpeed) / speedEasing;			}			this.x +=  currentVector.x;			this.y +=  currentVector.y;			this.rotation =  (-Math.atan2(currentVector.x,currentVector.y) * 57.2957795);			//correct for going off screen			if (this.x < 0 - sightRange) {				this.x = master.WH.x + sightRange;			}			if (this.y < 0 - this.sightRange) {				this.y = master.WH.y + sightRange;			}			if (this.x > master.WH.x + sightRange) {				this.x = 0 - sightRange;			}			if (this.y > master.WH.y + sightRange) {				this.y = 0 - this.sightRange;			}		}		public function cartesianDistance(p1:Point, p2:Point):Number {			return Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2));		}		//makes a vector of same direction, but predetermined length		public function normalizeVector(vector:Point, goalLength:Number):Point {			var currentLength:Number = cartesianDistance(vector,new Point(0,0));			var normalizeRatio:Number = currentLength / goalLength;			vector.x /=  normalizeRatio;			vector.y /=  normalizeRatio;			return vector;		}		public function diffDegrees(otherHue:Number):Number {			var diff:Number = Math.abs(otherHue - this.hue);			if (diff > 180) {				diff = 360 - diff;			}			return diff;		}		public function vectorToDegrees(vector:Point):Number {			return (Math.atan2(vector.x, vector.y) * 57.2957795 + 180);		}	}}