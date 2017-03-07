package com.thomasuster;
import org.hamcrest.MatcherAssert;
import org.hamcrest.core.IsEqual;
import com.thomasuster.CubicBezier;
class CubicBezierTest {
    @Test
    public function shouldNotExplode():Void {
        var cubic:CubicBezier = new CubicBezier(0,0,1,1);
        MatcherAssert.assertThat(cubic.ease(0), IsEqual.equalTo(0));
    }
}