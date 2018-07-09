module Main exposing (..)

import Html exposing (Html)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Messages exposing (Msg(..))
import Game exposing (State)
import Time exposing (Time)


---- MODEL ----


type alias Flags =
    { charactersPath : String
    , tilesPath : String
    }


init : Flags -> ( State, Cmd Msg )
init flags =
    ( Game.init flags.tilesPath flags.charactersPath
    , Cmd.none
    )



---- UPDATE ----


onTimeUpdatePhysicsInterval : Time -> State -> State
onTimeUpdatePhysicsInterval dt model =
    Game.update dt model


physicsInterval : Float
physicsInterval =
    0.01


onTimeUpdate : Time -> State -> State
onTimeUpdate dt model =
    if dt > physicsInterval then
        Game.update physicsInterval model
            |> onTimeUpdate (dt - physicsInterval)
    else
        Game.update dt model


update : Msg -> State -> ( State, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate dt ->
            ( onTimeUpdate (dt / 1000) model, Cmd.none )

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

                gameRunning =
                    if keyCode == 80 && not isPressed then
                        not model.gameRunning
                    else
                        model.gameRunning
            in
                ( { model | gameRunning = gameRunning, keys = { updatedKeys | keyPressed = keyPressed } }, Cmd.none )



---- VIEW ----


view : State -> Html Msg
view model =
    Html.div [] [ Game.view model ]


subscriptions : State -> Sub Msg
subscriptions model =
    let
        subs =
            [ Keyboard.downs (KeyChanged True)
            , Keyboard.ups (KeyChanged False)
            ]
                ++ if model.gameRunning then
                    [ AnimationFrame.diffs TimeUpdate ]
                   else
                    []
    in
        Sub.batch subs



---- PROGRAM ----


main : Program Flags State Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
