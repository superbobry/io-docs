ETest := UnitTest clone do(
    testInit := method(
        e := E clone
        assertTrue(e hasLocalSlot("tag"))
        assertTrue(e getSlot("inner") isKindOf(List))
        assertTrue(e getSlot("attrs") isKindOf(Map))
    )

    testForward := method(
        # Testing a single-tag case with no attributes and no text.
        e := E div
        assertEquals("div", e tag)
        assertEquals(list(), e inner)
        assertEquals(list(), e attrs keys) # Map compare isn't implemented :(

        # Testing a single-tag case with a text value.
        e := E div("text")
        assertEquals("div", e tag)
        assertEquals(list("text"), e inner)
        assertEquals(list(), e attrs keys)

        # Testing a single-tag case with an attribute.
        e := E div(class="block")
        assertEquals("div", e tag)
        assertEquals(list(), e inner)
        assertEquals(list("class"), e attrs keys)
        assertEquals(list("block"), e attrs values)

        # Testing a single-tag case with multiple attributes and a text values.
        e := E div(class="block", id="wrapper", "text", "more text")
        assertEquals("div", e tag)
        assertEquals(list("text", "more text"), e inner)
        assertEquals(list("class", "id"), e attrs keys sort)
        assertEquals(list("block", "wrapper"), e attrs values sort)

        # Testing nested tags case with no attributes and no text.
        e1 := E a
        e2 := E div(e1)
        assertEquals("div", e2 tag)
        assertEquals(list(e1), e2 inner)
        assertEquals(list(), e2 attrs keys)

        # Testing a complex case with multiple nested tags, attrs etc.
        e1 := E a("text", class="link")
        e2 := E span("more text")
        e3 := E a(e2, class="link")
        e := E div(e1, e2, e3, "even more text", class="wrapper")
        # a) checking e3
        assertEquals("a", e3 tag)
        assertEquals(list(e2), e3 inner)
        assertEquals(list("class"), e3 attrs keys)
        assertEquals(list("link"), e3 attrs values)
        # b) checking e
        assertEquals("div", e tag)
        # Note: the inner list contains element and text nodes in the order
        # they were listed in the constructor.
        assertEquals(list(e1, e2, e3, "even more text"), e inner)
        assertEquals(list("class"), e attrs keys)
        assertEquals(list("wrapper"), e attrs values)
    )

    testAsString := method(
        # Testing attribute rendering:
        # a) element has no attributes
        assertEquals("<a></a>", E a asString)
        # b) element has nil and empty attributes
        assertEquals("<a></a>", E a(class="", id=nil) asString)
        assertEquals( # Regression case.
            "<a rel=\"link\"></a>", E a(class="", id=nil, rel="link") asString
        )
        # c) element has multiple non-nil and non-empty attributes
        assertEquals(
            "<a class=\"x\" id=\"y\"></a>", E a(class="x", id="y") asString
        )

        # Testing tag rendering:
        # a) tag is contained in E SelfClosing list
        assertEquals("<br />", E br asString)
        assertEquals("<hr width=\"2\" />", E hr(width=2) asString)
        # IMPORTANT: inner nodes are ignored for self closing tags!
        assertEquals("<rel />", E rel("text") asString)
        assertEquals("<rel />", E rel(E br, E div("text")) asString)
        # b) tag is not self closing
        assertEquals("<div>text</div>", E div("text") asString)
        assertEquals("<div>text<br /></div>", E div("text", E br) asString)

        # Complex rendering case:
        e := E div("text", class="wrapper",
            E span("more text"),
            E a("even more text", class="link"),
            E a(E br, class="link")
        )
        assertEquals("""<div class="wrapper">text<span>more text</span><a class="link">even more text</a><a class="link"><br /></a></div>""", e asString)
    )
)

if(isLaunchScript, ETest run, ETest)