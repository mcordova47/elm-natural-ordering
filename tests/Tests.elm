module Tests exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import NaturalOrdering
import Random exposing (maxInt)
import Regex exposing (Regex)
import Test exposing (..)


suite : Test
suite =
    describe "comparison tests"
        [ fuzz Fuzz.string "equal strings compare as `EQ`" <|
            \str ->
                Expect.equal
                    (NaturalOrdering.compare str str)
                    EQ
        , fuzz2 nat nat "string representations of numbers compare same as numbers themselves" <|
            \n1 n2 ->
                Expect.equal
                    (NaturalOrdering.compare (String.fromInt n1) (String.fromInt n2))
                    (compare n1 n2)
        , fuzz3 Fuzz.string Fuzz.string unequalNats "strings beginning with numbers compare same as numbers" <|
            \str1 str2 ( n1, n2 ) ->
                Expect.equal
                    (NaturalOrdering.compare (String.fromInt n1 ++ " " ++ str1) (String.fromInt n2 ++ " " ++ str2))
                    (compare n1 n2)
        , fuzz2 nonNumericString nat "numbers compare less than non-numeric strings" <|
            \str n ->
                Expect.equal
                    (NaturalOrdering.compare (String.fromInt n) str)
                    LT
        , fuzz2 Fuzz.string Fuzz.string "reversing arguments negates order" <|
            \str1 str2 ->
                Expect.equal
                    (NaturalOrdering.compare str1 str2)
                    (negateOrd (NaturalOrdering.compare str2 str1))

        -- this tests `NaN` issue with converting "+" or "-" to int
        , test "\"+\" is less than \"-\"" <|
            \() ->
                Expect.equal
                    (NaturalOrdering.compare "+" "-")
                    LT
        ]


nat : Fuzzer Int
nat =
    Fuzz.intRange 0 maxInt


unequalNats : Fuzzer ( Int, Int )
unequalNats =
    Fuzz.tuple ( nat, nat )
        |> Fuzz.map
            (\( n1, n2 ) ->
                if n1 == n2 then
                    ( n1, n1 + 1 )

                else
                    ( n1, n2 )
            )


nonNumericString : Fuzzer String
nonNumericString =
    Fuzz.string
        |> Fuzz.map
            (\str ->
                if Regex.contains nonNumericRegex str then
                    str

                else
                    "a" ++ str
            )


nonNumericRegex : Regex
nonNumericRegex =
    Regex.fromString "^[^0-9]"
        |> Maybe.withDefault Regex.never


negateOrd : Order -> Order
negateOrd ord =
    case ord of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ
