module Main exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (Html)
import AnimationFrame
import Keyboard exposing (KeyCode)
import Time exposing (Time)
import Models.Entity exposing (Entity)
import Models.Mario as Mario
import Messages exposing (Msg(..))
import Models.Entity exposing (Direction(..))


---- MODEL ----


type alias Model =
    { charactersPath : String
    , elapsedTime : Float
    , mario : Entity
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
            let
                updatedModel =
                    { model | elapsedTime = model.elapsedTime + (dt / 1000) }
            in
                ( { updatedModel | mario = Mario.move dt model.keyPressed model.mario }, Cmd.none )

        KeyDown keyCode ->
            ( { model | keyPressed = toString keyCode }, Cmd.none )

        KeyUp keyCode ->
            ( { model | keyPressed = "Nothing pressed" }, Cmd.none )



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
        , Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
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
