module Sprites exposing (SpritesData, findFrames, Action(..), Direction(..))

import Array exposing (Array)
import List


type alias SpritesData =
    { imageUrl : String
    , sprites : List CharacterSprite
    }


type alias CharacterSprite =
    { action : Action
    , name : String
    , direction : Direction
    , frames : Array (List Int)
    , animationSpeed : Float
    }


type Action
    = Jumping
    | Standing
    | Falling
    | Walking


type Direction
    = Left
    | Right


findFrames : String -> Action -> Float -> Direction -> SpritesData -> String
findFrames name action actionDuration direction spritesData =
    let
        sprite =
            spritesData.sprites
                |> List.filter (\c -> c.name == name && c.action == action && c.direction == direction)
                |> List.head
    in
        findFrame sprite actionDuration


findFrame : Maybe CharacterSprite -> Float -> String
findFrame sprite duration =
    case sprite of
        Just sprite ->
            let
                frames =
                    sprite.frames
                        |> Array.map listOfIntToViewboxString

                numberOfFrames =
                    Array.length frames

                currentFrame =
                    round (1 / sprite.animationSpeed * duration) % numberOfFrames
            in
                Array.get currentFrame frames |> Maybe.withDefault ""

        Nothing ->
            ""


listOfIntToViewboxString : List Int -> String
listOfIntToViewboxString list =
    list
        |> List.map (\x -> toString x)
        |> String.join " "
