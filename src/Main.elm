module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Models.Mario as Mario
import Models.Keys as Keys
import Models.Mario exposing (Direction(..))
import Messages exposing (Msg(..))


---- MODEL ----


type alias Model =
    { charactersPath : String
    , mario : Mario.Mario
    , keys : Keys.Keys
    }


type alias Flags =
    { charactersPath : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { charactersPath = flags.charactersPath
      , mario = Mario.create
      , keys = Keys.create
      }
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate dt ->
            ( { model | mario = Mario.move (dt / 1000) model.keys model.mario }, Cmd.none )

        KeyChanged isPressed keyCode ->
            let
                keys =
                    model.keys

                updatedKeys =
                    case keyCode of
                        37 ->
                            { keys | leftPressed = isPressed }

                        39 ->
                            { keys | rightPressed = isPressed }

                        90 ->
                            { keys | jumpPressed = isPressed }

                        _ ->
                            keys

                keyPressed =
                    if isPressed then
                        toString keyCode
                    else
                        "N/A"
            in
                ( { model | keys = { updatedKeys | keyPressed = keyPressed } }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    Html.div []
        [ text model.keys.keyPressed
        , svg
            [ width "100%"
            , height "100%"
            , viewBox "0 0 640 400"
            ]
            [ Mario.draw model.mario model.charactersPath ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs (KeyChanged True)
        , Keyboard.ups (KeyChanged False)
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
