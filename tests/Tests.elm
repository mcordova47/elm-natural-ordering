module Example exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import NaturalOrdering
import Random exposing (maxInt)
import Regex exposing (Regex, regex)
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
                    (NaturalOrdering.compare (toString n1) (toString n2))
                    (compare n1 n2)
        , fuzz3 Fuzz.string Fuzz.string unequalNats "strings beginning with numbers compare same as numbers" <|
            \str1 str2 ( n1, n2 ) ->
                Expect.equal
                    (NaturalOrdering.compare (toString n1 ++ " " ++ str1) (toString n2 ++ " " ++ str2))
                    (compare n1 n2)
        , fuzz2 nonNumericString nat "numbers compare less than non-numeric strings" <|
            \str n ->
                Expect.equal
                    (NaturalOrdering.compare (toString n) str)
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
    Fuzz.conditional
        { retries = 5
        , fallback = \( n, _ ) -> ( n, n + 1 )
        , condition = uncurry (/=)
        }
        (Fuzz.tuple ( nat, nat ))


nonNumericString : Fuzzer String
nonNumericString =
    Fuzz.conditional
        { retries = 10
        , fallback = \str -> "a" ++ str
        , condition = Regex.contains nonNumericRegex
        }
        Fuzz.string


nonNumericRegex : Regex
nonNumericRegex =
    regex "^[^0-9]"


negateOrd : Order -> Order
negateOrd ord =
    case ord of
        LT ->
            GT

        GT ->
            LT

        EQ ->
            EQ
