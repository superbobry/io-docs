Common

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
            MetaCache{category} keys sort, selected, urlmaker
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
            description := meta slots at(slot)
            class := if(description beginsWithSeq("Deprecated"),
                "deprecated"
            ,
                if(description beginsWithSeq("Private"),
                    "private", nil)
            )
            details insert(
                E dl(id=slot beforeSeq("("), class=class,
                    E dt(slot),
                    E dd(description)
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
            MetaCache{category} foreach(object, meta,
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
        ("Created " .. fileCount .. " files" pluralize(fileCount) ..
         " in " .. runtime .. "s") println
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