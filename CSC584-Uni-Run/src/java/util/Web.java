package util;

/**
 * Small helpers for writing untrusted values safely into a page.
 */
public final class Web {

    private Web() {
    }

    /**
     * Escapes the characters that carry meaning in HTML so that user supplied
     * text is displayed as text instead of being executed as markup.
     *
     * Every value that originates from the database or from a request
     * parameter is passed through this method before it is printed.
     */
    public static String esc(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder out = new StringBuilder(value.length());
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '&':
                    out.append("&amp;");
                    break;
                case '<':
                    out.append("&lt;");
                    break;
                case '>':
                    out.append("&gt;");
                    break;
                case '"':
                    out.append("&quot;");
                    break;
                case '\'':
                    out.append("&#39;");
                    break;
                default:
                    out.append(c);
            }
        }
        return out.toString();
    }
}
