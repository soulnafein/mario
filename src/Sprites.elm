module Sprites exposing (SpritesData, findAnimation)

import Array exposing (Array)
import List


type alias SpritesData =
    { imageUrl : String
    , sprites : List CharacterSprite
    }


type alias CharacterSprite =
    { action : String
    , name : String
    , direction : String
    , animation : Array (List Int)
    , animationSpeed : Float
    }


findAnimation : String -> String -> String -> Float -> SpritesData -> String
findAnimation name action direction duration spritesData =
    let
        sprite =
            spritesData.sprites
                |> List.filter (\c -> c.name == name && c.action == action && c.direction == direction)
                |> List.head
    in
        findAnimationFrame sprite duration


findAnimationFrame : Maybe CharacterSprite -> Float -> String
findAnimationFrame sprite duration =
    case sprite of
        Just sprite ->
            let
                frames =
                    sprite.animation
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
