module Example exposing (main)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import NaturalOrdering


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = init
        , view = view
        , update = update
        }


type alias Model =
    { sortMethod : SortMethod
    }


init : Model
init =
    Model Plain


type Msg
    = SetSortMethod SortMethod


type SortMethod
    = Plain
    | CaseInsensitive
    | Natural


update : Msg -> Model -> Model
update (SetSortMethod method) model =
    { model | sortMethod = method }


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div
            [ Attributes.style
                [ ( "display", "flex" )
                , ( "flex-direction", "column" )
                ]
            ]
            [ Html.label []
                [ Html.input
                    [ Attributes.type_ "radio"
                    , Attributes.checked (model.sortMethod == Plain)
                    , Events.onClick (SetSortMethod Plain)
                    ]
                    []
                , Html.code [] [ Html.text "List.sort" ]
                ]
            , Html.label []
                [ Html.input
                    [ Attributes.type_ "radio"
                    , Attributes.checked (model.sortMethod == CaseInsensitive)
                    , Events.onClick (SetSortMethod CaseInsensitive)
                    ]
                    []
                , Html.code [] [ Html.text "List.sortBy String.toLower" ]
                ]
            , Html.label []
                [ Html.input
                    [ Attributes.type_ "radio"
                    , Attributes.checked (model.sortMethod == Natural)
                    , Events.onClick (SetSortMethod Natural)
                    ]
                    []
                , Html.code [] [ Html.text "List.sortWith NaturalOrdering.compare" ]
                ]
            ]
        , Html.ol []
            (List.map
                (Html.li [] << List.singleton << Html.text)
                (sort model.sortMethod names)
            )
        ]


sort : SortMethod -> List String -> List String
sort sortMethod =
    case sortMethod of
        Natural ->
            List.sortWith NaturalOrdering.compare

        CaseInsensitive ->
            List.sortBy String.toLower

        Plain ->
            List.sort


names : List String
names =
    [ "File (1)"
    , "File (2)"
    , "File (10)"
    , "a file"
    , "file (3)"
    , "File (15)"
    , "A File"
    , "file (100)"
    , "File (20)"
    , "The Whole 9 Yards"
    , "The Whole 10 Yards"
    ]
