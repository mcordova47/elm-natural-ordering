module NaturalOrdering exposing (compare, compareOn)

import Regex exposing (Regex, HowMany(..), regex, find)
import String.Normalize exposing (removeDiacritics)


compare : String -> String -> Order
compare =
    compareOn identity


compareOn : (a -> String) -> a -> a -> Order
compareOn f x y =
    compareChunkLists (toChunks (f x)) (toChunks (f y))


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
    regex "[0-9]+|[^0-9]+"


toComparableString : String -> String
toComparableString =
    String.toLower << removeDiacritics


toChunks : String -> List Chunk
toChunks str =
    str
        |> find All chunkRegex
        |> List.map (toChunk << .match)


toChunk : String -> Chunk
toChunk str =
    String.toInt str
        |> Result.map IntChunk
        |> Result.withDefault (StringChunk str)
