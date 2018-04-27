module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Models.Mario as Mario
import Models.Mario exposing (Direction(..))
import Messages exposing (Msg(..))


---- MODEL ----


type alias Model =
    { charactersPath : String
    , elapsedTime : Float
    , mario : Mario.Mario
    , keyPressed : String
    }


type alias Flags =
    { charactersPath : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { charactersPath = flags.charactersPath
      , elapsedTime = 0
      , mario = Mario.create
      , keyPressed = "Nothing pressed"
      }
    , Cmd.none
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate dt ->
            ( { model | mario = Mario.move (dt / 1000) model.keyPressed model.mario }, Cmd.none )

        KeyChanged isPressed keyCode ->
            let
                mario =
                    model.mario

                updatedMario =
                    case keyCode of
                        37 ->
                            Mario.updateLeftPressed isPressed mario

                        39 ->
                            Mario.updateRightPressed isPressed mario

                        90 ->
                            Mario.updateJumpPressed isPressed mario

                        _ ->
                            mario

                keyPressed =
                    if isPressed then
                        toString keyCode
                    else
                        "N/A"
            in
                ( { model | mario = updatedMario, keyPressed = keyPressed }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        frame =
            (round model.elapsedTime) % 10
    in
        Html.div []
            [ text model.keyPressed
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
