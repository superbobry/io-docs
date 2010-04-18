Object asJson := method(
    result := Map clone
    self foreachSlot(slotName, slotValue,
        if(getSlot("slotValue") isActivatable not,
            result atPut(slotName, slotValue)
        )
    )
    result asJson
)

File do(
    extract := method(type,
        slices := list()
        type = type .. " " # Forcing `<type> ` probably breaks some comments.
        list(
            list("//" .. type, "\n"), // Comment
            list("#"  .. type, "\n"), #  Comment
            list("/*" .. type, "*/")  /* Comment */
        ) foreach(args,
            slices appendSeq(contents performWithArgList("slicesBetween", args))
        )
        slices mapInPlace(strip)
    )

    docs := lazySlot(extract("doc"))
    meta := lazySlot(extract("metadoc"))
)

Sequence pluralize := method(count,
    self .. if(count != 1, "s", "")
)

ProgressMixIn := Object clone do(
    main  ::= nil   # Main executed method slot name.
    width ::= 80    # Line width. (Merge this with TestRunner somehow?)

    init := method(self fileCount := 0)

    done := method(
        "." print
        self fileCount = self fileCount + 1
        # Break the line, when the number of items exceed the
        # predefined line width.
        if(self fileCount % width == 0, "\n" print)
    )

    run := method(
        ?printHeader  # Outputing header line(s), if there's any ...
        self runtime := Date secondsToRun(
            self getSlot(main) call
        )
        ?printSummary # ... and runtime information.
    )

    runQuiet := method(
        # We put all the printing methods in a backup Map and the restore
        # them, when run() terminates.
        backup := Map clone
        list("printHeader", "printSummary", "done") foreach(slotName,
            backup atPut(slotName, self getSlot(slotName))
            self updateSlot(slotName)
        )
        run

        backup foreach(slotName, slotValue,
            self updateSlot(slotName, getSlot("slotValue"))
        )
    )
)

# Hack, damn that Importer :)
Common := nil