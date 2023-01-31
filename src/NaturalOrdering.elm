module NaturalOrdering exposing
    ( compare, compareOn
    , sort, sortBy
    )

{-| Compare strings with numbers and diacritics "naturally"

@docs compare, compareOn, sort, sortBy

-}

import Maybe
import Regex exposing (Regex)
import String.Normalize exposing (removeDiacritics)


{-| Compare two strings naturally.

    List.sortWith NaturalOrdering.compare ["a10", "a2"]
    --> ["a2", "a10"]

-}
compare : String -> String -> Order
compare =
    compareOn identity


{-| Compare two `a`s naturally, based on some function, `a -> String`. Use
this where you would ordinarily use `sortBy`.

    List.sortWith (compareOn .name) [{ name = "a10" }, { name = "a2" }]
    --> [{ name = "a2" }, { name = "a10" }]

-}
compareOn : (a -> String) -> a -> a -> Order
compareOn f x y =
    compareChunkLists (toChunks (f x)) (toChunks (f y))


{-| Naturally sort values from lowest to highest

    sort [ "b10", "B2", "A", "a" ]
    --> [ "A", "a", "B2", "b10" ]

-}
sort : List String -> List String
sort =
    sortBy identity


{-| Naturally sort values by a derived property.

    alice = { name = "Alice" }
    bob = { name = "Bob" }
    bill = { name = "bill" }

    sortBy .name [bob, bill, alice]
    --> [alice, bill, bob]

-}
sortBy : (a -> String) -> List a -> List a
sortBy f =
    List.sortWith (compareOn f)


type Chunk
    = StringChunk String
    | IntChunk Int


compareChunks : Chunk -> Chunk -> Order
compareChunks chunk1 chunk2 =
    case ( chunk1, chunk2 ) of
        ( StringChunk str1, StringChunk str2 ) ->
            Basics.compare (toComparableString str1) (toComparableString str2)

        ( StringChunk _, IntChunk _ ) ->
            GT

        ( IntChunk _, StringChunk _ ) ->
            LT

        ( IntChunk int1, IntChunk int2 ) ->
            Basics.compare int1 int2


compareChunkLists : List Chunk -> List Chunk -> Order
compareChunkLists chunkList1 chunkList2 =
    case ( chunkList1, chunkList2 ) of
        ( [], [] ) ->
            EQ

        ( [], _ :: _ ) ->
            LT

        ( _ :: _, [] ) ->
            GT

        ( chunk1 :: chunks1, chunk2 :: chunks2 ) ->
            case compareChunks chunk1 chunk2 of
                EQ ->
                    compareChunkLists chunks1 chunks2

                ord ->
                    ord


chunkRegex : Regex
chunkRegex =
    Regex.fromString "[0-9]+|[^0-9]+"
        |> Maybe.withDefault Regex.never


toComparableString : String -> String
toComparableString =
    String.toLower << removeDiacritics


toChunks : String -> List Chunk
toChunks str =
    str
        |> Regex.find chunkRegex
        |> List.map (toChunk << .match)


toChunk : String -> Chunk
toChunk str =
    String.toInt str
        |> Maybe.andThen intToChunk
        |> Maybe.withDefault (StringChunk str)


intToChunk : Int -> Maybe Chunk
intToChunk int =
    if isNaN (toFloat int) then
        Nothing

    else
        Just (IntChunk int)
