# elm-natural-ordering

This package provides comparison functions to sort strings containing numbers and diacritics in an expected way.

Take the following list for example:

```elm
names : List String
names =
    [ "File (1).txt"
    , "File (2).txt"
    , "File (10).txt"
    , "a file"
    , "file (3).txt"
    , "File (15).txt"
    , "A File"
    , "file (100).txt"
    , "File (20).txt"
    , "Á file"
    ]
```

Sorting them, even ignoring case, yields a confusing result:

```elm
List.sortBy String.toLower names
{-
[ "a file"
, "A File"
, "File (1).txt"
, "File (10).txt"
, "file (100).txt"
, "File (15).txt"
, "File (2).txt"
, "File (20).txt"
, "file (3).txt"
, "Á file"
]
-}
```

People see this list as being out of order, since the files are numbered and the numbers are not ordered.  Also letters with diacritics are sorted after any letters without diacritics.

`NaturalOrdering.compare` solves this:

```elm
List.sortWith NaturalOrdering.compare names
{-
[ "a file"
, "A File"
, "Á file"
, "File (1).txt"
, "File (2).txt"
, "file (3).txt"
, "File (10).txt"
, "File (15).txt"
, "File (20).txt"
, "file (100).txt"
]
-}
```

`NaturalOrdering` exports a `compare` function instead of a `sort` function because it's more composable.  You could use it with any data structure that exposes a `sortWith : (a -> a -> Ordering) -> f a -> f a` function, like a [non-emptylist](http://package.elm-lang.org/packages/mgold/elm-nonempty-list/3.1.0/List-Nonempty#sortWith)!
