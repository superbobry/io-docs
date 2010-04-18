# Note: FileCollector doesn't handle tests with equal names currently,
# so this test will probably override default FileTest.

Common

FileTest := UnitTest clone do(
    setUp := method(
        self file := File with("test.me") open write("""
1.        #doc I'm a docstring
2.        #docan invalid docstring
3.        // doc yet another invalid docstring
4.        //doc I'm a docstring too
5.        /*doc I'm a multiline
        docstring
        */""") flush
    )

    testExtract := method(
        extracted := file extract("doc")
        assertEquals(3, extracted size)
        # The docstring format forces the `doc` or `metadoc` keywords to be
        # followed by a whitespace, hence the (2) docstring is invalid, but
        # no whitespace is allowed between the comment character and the
        # keyword. That's why the (3) docstring is invalid. Generalizing the
        # above, only the docstring of the form:
        #     <COMMENT>doc|metadoc ....
        # are extracted.
        assertEquals(
            list("I'm a docstring",
                 "I'm a docstring too",
                 "I'm a multiline\n        docstring"), extracted sort)

        assertEquals(list(), file extract("metadoc"))
    )

    tearDown := method(self file remove)
)

if(isLaunchScript, FileTest run)