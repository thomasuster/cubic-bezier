package com.thomasuster;

/**
 * https://github.com/gre/bezier-easing
 * BezierEasing - use bezier curve for transition easing function
 * by Gaëtan Renaudeau 2014 - 2015 – MIT License
 * 
 * https://github.com/thomasuster/cubic-bezier
 * haxe port by Thomas Uster 
 */
    
import haxe.io.Error;
import haxe.ds.Vector;
class CubicBezier {

    public var mX1:Float;
    public var mY1:Float;
    public var mX2:Float;
    public var mY2:Float;
    
    var NEWTON_ITERATIONS:Int = 4;
    var NEWTON_MIN_SLOPE:Float = 0.001;
    var SUBDIVISION_PRECISION:Float = 0.0000001;
    var SUBDIVISION_MAX_ITERATIONS:Int = 10;

    var kSplineTableSize:Int = 11;
    var kSampleStepSize:Float;
    var sampleValues:Vector<Float>;
    
    public function new(mX1,mY1,mX2,mY2) {
        this.mX1 = mX1;
        this.mY1 = mY1;
        this.mX2 = mX2;
        this.mY2 = mY2;
        
        kSampleStepSize = 1.0 / (kSplineTableSize - 1.0);

        if (!(0 <= mX1 && mX1 <= 1 && 0 <= mX2 && mX2 <= 1)) {
            throw 'bezier x values must be in [0, 1] range';
        }

        // Precompute samples table
        sampleValues = new Vector(kSplineTableSize);
        if (mX1 != mY1 || mX2 != mY2) {
            for (i in 0...kSplineTableSize) {
                sampleValues[i] = calcBezier(i * kSampleStepSize, mX1, mX2);
            }
        }
    }

    public function ease(p:Float):Float {
        if (mX1 == mY1 && mX2 == mY2) {
            return p; // linear
        }
        if (p == 0) {
            return 0;
        }
        if (p == 1) {
            return 1;
        }
        return calcBezier(getTForX(p), mY1, mY2);
    }

    // Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
    function calcBezier (aT:Float, aA1:Float, aA2:Float):Float { return ((A(aA1, aA2) * aT + B(aA1, aA2)) * aT + C(aA1)) * aT; }

    // Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
    function getSlope (aT:Float, aA1:Float, aA2:Float):Float { return 3.0 * A(aA1, aA2) * aT * aT + 2.0 * B(aA1, aA2) * aT + C(aA1); }

    function A (aA1:Float, aA2:Float):Float { return 1.0 - 3.0 * aA2 + 3.0 * aA1; }
    function B (aA1:Float, aA2:Float):Float { return 3.0 * aA2 - 6.0 * aA1; }
    function C (aA1:Float):Float      { return 3.0 * aA1; }

    function getTForX (aX) {
        var intervalStart = 0.0;
        var currentSample = 1;
        var lastSample = kSplineTableSize - 1;

        while(currentSample != lastSample && sampleValues[currentSample] <= aX) {
            intervalStart += kSampleStepSize;
            ++currentSample;
        }
        --currentSample;

            // Interpolate to provide an initial guess for t
        var dist = (aX - sampleValues[currentSample]) / (sampleValues[currentSample + 1] - sampleValues[currentSample]);
        var guessForT = intervalStart + dist * kSampleStepSize;

        var initialSlope = getSlope(guessForT, mX1, mX2);
        if (initialSlope >= NEWTON_MIN_SLOPE) {
        return newtonRaphsonIterate(aX, guessForT, mX1, mX2);
        } else if (initialSlope == 0.0) {
        return guessForT;
        } else {
        return binarySubdivide(aX, intervalStart, intervalStart + kSampleStepSize, mX1, mX2);
        }
    }

    function binarySubdivide (aX:Float, aA:Float, aB:Float, mX1:Float, mX2:Float):Float {
        var currentX, currentT, i = 0;
        do {
        currentT = aA + (aB - aA) / 2.0;
        currentX = calcBezier(currentT, mX1, mX2) - aX;
        if (currentX > 0.0) {
        aB = currentT;
        } else {
        aA = currentT;
        }
        } while (Math.abs(currentX) > SUBDIVISION_PRECISION && ++i < SUBDIVISION_MAX_ITERATIONS);
        return currentT;
    }

    function newtonRaphsonIterate (aX:Float, aGuessT:Float, mX1:Float, mX2:Float):Float {
        for (i in 0...NEWTON_ITERATIONS) {
        var currentSlope = getSlope(aGuessT, mX1, mX2);
        if (currentSlope == 0.0) {
        return aGuessT;
        }
        var currentX = calcBezier(aGuessT, mX1, mX2) - aX;
        aGuessT -= currentX / currentSlope;
        }
        return aGuessT;
    }



}
