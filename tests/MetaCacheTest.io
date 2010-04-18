MetaCacheTest := UnitTest clone do(
    setUp := method(
        # Meta mock object.
        self Meta := Object clone do(
            setSlot("category")

            with := method(category,
                meta := self clone
                meta category := category
                meta
            )
        )
    )

    testInit := method(
        # Checking that cloning has no effect on MetaCache.
        assertEquals(MetaCache clone uniqueId, MetaCache uniqueId)
        assertEquals(MetaCache clone uniqueId, MetaCache clone uniqueId)
    )

    testCategories := method(
        MetaCache atPut("UnitTest", Meta with("Testing"))
        MetaCache atPut("List", Meta with("Core"))
        assertEquals(list("Core", "Testing"), MetaCache categories)

        # Checking that categories list is sorted.
        assertEquals(MetaCache categories, MetaCache categories sort)

        # Checking that categories list contains no duplicates.
        MetaCache atPut("Map", Meta with("Core"))
        MetaCache atPut("Sequence", Meta with("Core"))
        assertEquals(list("Core", "Testing"), MetaCache categories)
    )

    testCurlyBrackets := method(
        MetaCache atPut("UnitTest", Meta with("Testing"))
        MetaCache atPut("List", Meta with("Core"))
        MetaCache atPut("Map", Meta with("Core"))

        # Testing the case where the category is unspecified,
        # expecting all of the objects to be returned.
        objects := MetaCache{}
        assertEquals(MetaCache size, objects size)
        assertEquals(MetaCache keys, objects keys)
        assertEquals(MetaCache values, objects values)

        # Testing the normal case.
        objects := MetaCache{"Core"}
        assertEquals(2, objects size)
        assertEquals(list("List", "Map"), objects keys sort)
    )

    testSquareBrackets := method(
        assertEquals(0, MetaCache size) # Making sure there's no Meta's in cache.

        # Testing the case where the Meta for a given object doesn't exist.
        meta := MetaCache["List"]
        assertTrue(
            meta isKindOf(Lobby Meta) # Note: this is not the mock Meta!
        )
        assertEquals("List", meta object)

        # Checking that the object is now stored in cache.
        assertEquals(1, MetaCache size)
        assertEquals(meta, MetaCache at("List"))
        assertEquals(meta, MetaCache["List"])
    )

    tearDown := method(MetaCache empty)
)

if(isLaunchScript, MetaCacheTest run)