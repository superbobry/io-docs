# Meta data container object, where
#   object is the metadata holder name (<ObjectName> to be more exact)
#   <tag>  is populted from `metadoc <ObjectName> <tag> ...`
#   slots  are populted from `doc <ObjectName> <slotName> ...`
Meta := Object clone do(
    init := method(
        list(
            "object", "module", "category", "copyright",
            "credits", "license", "description"
        ) map(slotName, self setSlot(slotName, ""))

        # Some of the files doesn't declare category :(
        self category = "Uncategorized"
        self slots := Map clone
    )

    asString := method("Meta for `#{object}`" interpolate)

    with := method(data,
        # Extractring meta signature: <ObjectName> [category|description|etc] ...
        line := data beforeSeq("\n") split(" ", "\t")
        meta := MetaCache[line removeFirst] # Looking up the Meta object.
        # IMPORTANT: why afterSeq() returns `nil` if a given sequence is not found
        # while beforeSeq() returns ""?
        data = data afterSeq("\n")
        data ifNil(data = "") # FIXME: ugly :(
        # Possible optimization: construct a separate data structure once
        # the category metatag value arrives:
        #
        # if(data first == "category",
        #     CategoryCache atPut(data first, data rest join(" "))
        # )
        meta setSlot(
            line removeFirst, line join(" ") appendSeq(data) strip
        )
        meta
    )

    slot := method(data,
        # Extractring slot signature: <ObjectName> <slotWithArgs> ...
        # IMPORTANT: Regex should be a Core module, really
        #
        # We are only interested in the first line, since slot signature
        # is usually (must be?) located there.
        line := data beforeSeq("\n") split
        meta := MetaCache[line removeFirst] # Looking up the Meta object.
        slot := line removeFirst

        # If the slot chunk is missing a closing paren, we look through
        # the remaining pieces until one is found and then update slot
        # signature string with the appropriate slice.
        if(slot containsSeq("(") and slot containsSeq(")") not,
            line foreach(idx, chunk,
                if(chunk containsSeq(")"),
                    slot appendSeq(" " .. line slice(0, idx + 1) join(" "))
                    description := line slice(idx + 1) join(" ")
                    break
                )
            )
        ,
            description := line join(" ")
        )

        if(data containsSeq("\n"),
            description prependSeq(data afterSeq("\n") asMutable strip)
        )

        # Puting slot signature and docstring into the Meta slot map.
        meta slots atPut(slot, description)
        meta
    )
)