# `E` is a very-very-very basic templating engine, E being a short for Element, really :)
# The idea doesn't belong to the author and was taken from <URL_HERE>.
#
# Example:
#     E div(class="wrapper",
#         E span("I'm wrapped, yay!"),
#         E br
#     )
#
#     ==> <div class="wrapper"><span>I'm wrapped, yay!</span><br /></div>
#
# TODO:
#   * pretty printing
#   * tag validation (is it needed?)
#   * more structure manipulation methods (probably when there will be
#     more usecases availible)

E := Object clone do(
    SelfClosing := List with(
        "br", "hr", "input", "img", "meta", "rel", "spacer",
        "link", "frame", "base"
    )

    init := method(
        self tag   ::= nil
        self inner := list()
        self attrs := Map clone
    )

    add := method(
        # Add new element to the inner element list.
        call delegateToMethod(self inner, "append")
        self
    )

    insert := method(
        # Insert new element into the last element in the inner element list.
        call delegateToMethod(self inner last, "add")
        self
    )

    asString := method(
        attrs := if(attrs size > 0,
            # Note: attrs with empty or nil values won't get printed.
            # Note: sorting is needed, since item order in Map keys is
            # undefined.
            attrs = attrs select(attr, value,
                value and value ?size > 0
            ) keys sort map(attr,
                " #{attr}=\"#{self attrs at(attr)}\"" interpolate
            ) join
        ,
            "")

        # It would be nice to have customizable pretty printing:
        # <tag>
        #   <tag>
        #     Text
        #   </tag>
        # </tag>
        if(tag in(SelfClosing),
            "<#{self tag}#{attrs} />"
        ,
            "<#{self tag}#{attrs}>#{self inner join}</#{self tag}>"
        ) interpolate
    )

    forward := method(
        tag := self clone setTag(call message name)
        call message arguments foreach(expression,
            # If the subexpression is a tag (E <tag>(...)), append it to the
            # tag's inner list ...
            if(expression name == "E",
                tag inner append(self doMessage(expression, call sender))
            ,
                # ... else, we check the total number of arguemnts, if it's
                # equal to two, we assume the expression is of form <attr>=<value>,
                # split it accordingly and put into the tag's attr map ...
                if(expression argCount == 2,
                    tag attrs performWithArgList("atPut",
                        expression argsEvaluatedIn(call sender)
                    )
                ,
                    # ... else, the expression is treated as a text node, i.e.
                    # appended to the tag's inner list, just like a normal
                    # tag object.
                    tag inner append(expression doInContext(call sender))
                )
            )
        )
        tag
    )
)