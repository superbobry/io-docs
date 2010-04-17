Meta := Object clone do(
    setSlot("category")

    with := method(category,
        meta := self clone
        meta category := category
        meta
    )
)

MetaCacheTest := UnitTest clone do(
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

        # Checking that nil-values are filtered out.
        MetaCache atPut("MD5", Meta)
        MetaCache atPut("SHA1", Meta)
        assertEquals(list("Core", "Testing"), MetaCache categories)
    )

    testObjects := method(
        MetaCache atPut("UnitTest", Meta with("Testing"))
        MetaCache atPut("List", Meta with("Core"))
        MetaCache atPut("Map", Meta with("Core"))

        # Testing the case where the category is unspecified,
        # expecting all of the objects to be returned.
        objects := MetaCache objects
        assertEquals(MetaCache size, objects size)
        assertEquals(MetaCache keys, objects keys)
        assertEquals(MetaCache values, objects values)

        # Testing the case where the objects for a given category
        # aren't cached.
        objects := MetaCache objects("Core")
        assertEquals(2, objects size)
        assertEquals(list("List", "Map"), objects keys sort)
        assertTrue(MetaCache cache hasKey("Core")) # Checking that the query is cached now.

        # Testing the case where the objects for a given category
        # is cached.
        objects := MetaCache objects("Core")
        assertEquals(2, objects size)
        assertEquals(list("List", "Map"), objects keys sort)
    )

    testSquareBrackets := method(
        assertEquals(0, MetaCache size) # Making sure there's no Meta's in cache.

        # Testing the case where the Meta for a given object doesn't exist.
        meta := MetaCache["List"]
        assertTrue(meta isKindOf(Meta))
        assertEquals("List", meta object)

        # Checking that the object is now stored in cache.
        assertEquals(1, MetaCache size)
        assertEquals(meta, MetaCache at("List"))
        assertEquals(meta, MetaCache["List"])
    )

    tearDown := method(MetaCache empty)
)

if(isLaunchScript, MetaCacheTest run)