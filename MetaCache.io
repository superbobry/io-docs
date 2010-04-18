# Container object for all of the parsed information, where keys
# are object names (extracted from `metadoc <ObjectName>` comments)
# and values are Meta objects.
#
# MetaCache is indexable two ways:
#   by object names through squareBrackets
#     MetaCache["UnitTest"] ==> Meta(...)
#   by category through curlyBrackets
#     MetaCache{"Testing"}  ==> list(Meta(...), Meta(...))
MetaCache := Map clone do(
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
    curlyBrackets := method(category,
        if(category,
            self select(k, v, v category == category)
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