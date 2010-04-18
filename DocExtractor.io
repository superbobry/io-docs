Common

DocExtractor := Object clone prependProto(ProgressMixIn) do(
    path  ::= "." # Root path for the extractor to start with.

    with := method(path, self clone setPath(path))

    extract := method(
        # Note: what are *.m files for?
        Directory with(path) recursiveFilesOfTypes(
            list(".io", ".c", ".m")
        ) foreach(file,
            # Skipping IoVMInit file!
            if(file name beginsWithSeq("IoVMInit"), continue)
            # Creating / updating Meta objects ...
            file meta foreach(data, Meta with(data))
            # ... and processing slot docstring objects.
            file docs foreach(data, Meta slot(data))

            done # Just a `success` hook.
        )
    )

    printHeader  := method(
        ("Extracting docs starting from `" .. path asMutable rstrip("/") .. "`:") println
    )
    printSummary := method(
        objectCount := MetaCache keys size
        slotCount   := MetaCache values reduce(count, object,
            count + object slots size, 0
        )

        # Printing summary.
        ("\n" .. "-" repeated(width)) println
        ("Processed " .. \
         fileCount .. " file" pluralize(fileCount) .. ", " ..
         objectCount .. " object" pluralize(objectCount) .. ", " ..
         slotCount .. " slot" pluralize(slotCount) ..
         " in " .. runtime .. "s") println
    )
) setMain("extract")