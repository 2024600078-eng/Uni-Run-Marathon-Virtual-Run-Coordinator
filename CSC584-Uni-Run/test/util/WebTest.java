package util;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

/**
 * Tests for the HTML escaping applied to every value shown on a page.
 */
public class WebTest {

    @Test
    public void nullBecomesAnEmptyString() {
        assertEquals("", Web.esc(null));
    }

    @Test
    public void ordinaryTextIsUnchanged() {
        assertEquals("Ahmad Bin Abdul Rahman", Web.esc("Ahmad Bin Abdul Rahman"));
    }

    @Test
    public void angleBracketsAreEscaped() {
        assertEquals("&lt;b&gt;", Web.esc("<b>"));
    }

    @Test
    public void ampersandIsEscaped() {
        assertEquals("Marathon &amp; Virtual Run", Web.esc("Marathon & Virtual Run"));
    }

    @Test
    public void quotesAreEscaped() {
        assertEquals("&quot;quoted&quot;", Web.esc("\"quoted\""));
        assertEquals("&#39;single&#39;", Web.esc("'single'"));
    }

    @Test
    public void aScriptTagCannotSurviveEscaping() {
        String escaped = Web.esc("<script>alert('x')</script>");

        assertFalse("No raw < may remain", escaped.contains("<"));
        assertFalse("No raw > may remain", escaped.contains(">"));
        assertEquals("&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt;", escaped);
    }

    @Test
    public void anImageOnErrorPayloadIsNeutralised() {
        String escaped = Web.esc("\" onerror=\"alert(1)");

        assertFalse("No raw quote may remain", escaped.contains("\""));
        assertEquals("&quot; onerror=&quot;alert(1)", escaped);
    }

    @Test
    public void escapingIsAppliedToEveryOccurrence() {
        assertEquals("&lt;&lt;&lt;", Web.esc("<<<"));
    }

    @Test
    public void theAmpersandIsEscapedOnlyOnce() {
        // If & were escaped after < the result would be double escaped.
        assertEquals("&amp;lt;", Web.esc("&lt;"));
    }

    @Test
    public void emptyStringStaysEmpty() {
        assertEquals("", Web.esc(""));
    }
}
