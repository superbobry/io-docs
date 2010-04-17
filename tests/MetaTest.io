MetaTest := UnitTest clone do(
    testInit := method(
        meta := Meta clone
        list(
            "object", "module", "copyright",
            "credits", "license", "description"
        ) foreach(slotName,
            assertEquals("", meta getSlot(slotName))
        )

        assertEquals("Uncategorized", meta category)
        assertTrue(meta slots isKindOf(Map))
        assertTrue(meta slots isEmpty)
    )

    testWith := method(
        meta := Meta with("UnitTest description Yet another testing framework.")
        assertEquals("UnitTest", meta object)
        assertEquals("Yet another testing framework.", meta description)

        # Checking that the Meta object get's updated, once new attributes arrive.
        updatedMeta := Meta with("UnitTest credits That Guy")
        assertEquals("That Guy", updatedMeta credits)
        assertEquals(meta uniqueId, updatedMeta uniqueId)

        # Checking that tab separated words are also processed correctly,
        # though that's not likely to happen in the real world.
        meta := Meta with("UnitTest\tdescription\tYet another testing framework.")
        assertEquals("UnitTest", meta object)
        assertEquals("Yet another testing framework.", meta description)
    )

    testSlot := method(
        meta := Meta slot("UnitTest run Run something.")
        assertEquals("UnitTest", meta object)
        assertEquals("Run something.", meta slots at("run"))

        meta := Meta slot("UnitTest run\
Run something.")
        assertEquals("UnitTest", meta object)
        assertEquals("Run something.", meta slots at("run"))

    meta := Meta slot("""UnitTest run


Run something.""")
        assertEquals("UnitTest", meta object)
        assertEquals("Run something.", meta slots at("run"))

        meta := Meta slot("UnitTest test(arg1, arg2) Test some args.")
        assertEquals("UnitTest", meta object)
        assertEquals("Test some args.", meta slots at("test(arg1, arg2)"))

        meta := Meta slot("""UnitTest test(arg1, arg2)

Test some args.""")
        assertEquals("UnitTest", meta object)
        assertEquals("Test some args.", meta slots at("test(arg1, arg2)"))
    )
)

if(isLaunchScript, MetaTest run)