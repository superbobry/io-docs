# Docstring extractor for Io language (http://iolanguage.com), made as a replacement
# for the doc2html & co, which are (in author's opinion) very nice examples of hardcore
# spagetti-code, done the Io-way.
#
# TODO:
#   * split everything into separate files?
#   * abstract base DocFormatter and HTMLDocFormatter objects
#   * add filename and line numbers for each method, f.ex.:
#     `reduce(accumulator, element, start)          [A3_List.io:70]`
#   * add cleanup method to DocFormatter
#   * add option for generating relative paths instead of absolute ones
#   * make js-search work with the new internals

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

# Container object for all of the parsed information, where keys
# are object names (extracted from `metadoc <ObjectName>` comments)
# and values are Meta objects.
MetaCache := Map clone do(
    # Category <-> list(Meta, Meta ...) mapping, all the lookups
    # through MetaCache objects() are cached there.
    cache := Map clone

    # MetaCache is a singleton, which means cloning has no effect.
    clone := lazySlot(self)

    # MetaCache isn't designed to be modified after it's initially
    # populated by DocExtractor, hence, categories should be better
    # made a lazySlot, instead of a plain method(), but that would
    # make the testing really complicated.
    categories := method(
        self values map(category) unique sort remove(nil)
    )

    # Returns cache subset for a given category or a reference to
    # MetaCache if no category is given.
    objects := method(category,
        if(category,
            if(cache hasKey(category),
                cache
            ,
                cache atPut(category,
                    self select(k, v, v category == category)
                )
            ) at(category)
        ,
            self
        )
    )

    squareBrackets := method(object,
        # Looking up the Meta object in the cache, if it doesn't exist,
        # creating a new one.
        meta := at(object)
        meta ifNil(
            meta := Meta clone
            meta object := object
            atPut(object, meta)
        )
        meta
    )
)

# Meta data container object, where
#   name   is the metadata holder name (<ObjectName> to be more exact)
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

    with := method(data,
        # Extractring meta signature: <ObjectName> [category|description|etc] ...
        data = data split(" ", "\t")
        meta := MetaCache[data removeFirst] # Looking up the Meta object.
        meta setSlot(
            data first, data rest join(" ")
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
        list("printHeader", "printSummary", "done") foreach(slotName,
            self setSlot(slotName)
        )
        run
    )
)

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

DocFormatter := Object clone prependProto(ProgressMixIn) do(
    # The path MUST contain a trailing slash, due to the bug in Directory object.
    path ::= "reference/" # Root path for all the documentation files.

    with := method(path, self clone setPath(path))

    # Note: at the moment DocExtractor uses absolute paths for the inter
    # references between entities.
    prefix := lazySlot(Directory currentWorkingDirectory .. "/" .. path)

    renderColumn := method(items, selected, urlmaker,
        # Here's an example of the markup we need:
        # <div class="ref-column">
        #   <div class="ref-item"><a href="">Apple</a></div>
        #   <div class="ref-item"><a href="">Audio</a></div>
        # </div>
        column := E div(class="ref-column")
        items foreach(item,
             column add(
                E div(class="ref-item" .. if(selected == item, " selected", ""),
                    E a(href=getSlot("urlmaker") call(item), item)
                )
             )
        )
        column
    )

    renderCategories := method(selected,
        urlmaker := block(item, prefix .. item .. "/index.html")
        self perform("renderColumn",
            MetaCache categories, selected, urlmaker
        )
    )

    renderObjects := method(category, selected,
        urlmaker := block(item,
            "#{self prefix}#{category}/#{item}.html" interpolate
        )
        self perform("renderColumn",
            MetaCache objects(category) keys sort, selected, urlmaker
        )
    )

    renderSlots := method(meta,
        urlmaker := block(item, "#" .. item)
        self perform("renderColumn",
            meta slots keys map(beforeSeq("(")) sort, nil, urlmaker
        )
    )

    renderDetails := method(meta,
        details := E div(class="ref-details",
            E h2(meta object .. " Proto"),
        #   E div(class="ref-copyright", meta copyright),
        #   E div(class="ref-license", meta license),
            E div(class="ref-description", meta ?description),
            E hr,
            E div(class="ref-slots")
        )
        meta slots keys sort foreach(slot,
            details insert(
                E dl(id=slot beforeSeq("("), # Check for deprecation?
                    E dt(slot),
                    E dd(meta slots at(slot))
                )
            )
        )
        details
    )

    format := method(
        # Root directory.
        root := Directory with(path) createIfAbsent

        # Rendering reference index file.
        root fileNamed("index.html") open write(
            render(list(renderCategories))
        ) close
        done

        # Rendering categories:
        MetaCache categories foreach(category,
            # a) creating a directory with the category name
            dir := root directoryNamed(category) createIfAbsent

            # b) creating index file listing all category objects
            dir fileNamed("index.html") open write(
                render(list(
                    renderCategories(category),
                    renderObjects(category)
                ))
            ) close
            done

            # c) creating an html file for each object in the category
            MetaCache objects(category) foreach(object, meta,
                dir fileNamed(object .. ".html") open write(
                    render(list(
                        renderCategories(category),
                        renderObjects(category, object),
                        renderSlots(meta),
                        renderDetails(meta)
                     ))
                ) close
                done
            )
        )
    )

    printHeader  := method(
        ("Generating documentation files in `" .. path .."`:") println
    )
    printSummary := method(
        ("\n" .. "-" repeated(width)) println
        ("Created " .. fileCount .. " files in " .. runtime .. "s") println
    )

    render := method(blocks,
        if(hasSlot("template") not,
            template := File with("template.iohtml") contents
            context := Object clone
            context forward := message("") setIsActivatable(true)
            context prefix  := prefix
            context blocks  := nil
        )

        context blocks = blocks
        # Rendering template with the given blocks ...
        template interpolate(context) asMutable replaceMap(
            # ... and doing some minor cleanup.
            # Note: oh my, once again WHY Regex is not Core?
            Map with("\n<", "<", ">\n", ">") # Add \r?
        )
    )
) setMain("format")

if(isLaunchScript,
    DocExtractor with("../io/libs/iovm") run
    "\n" print # Silly :(
    DocFormatter with("reference/") run
)