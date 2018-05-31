module Sprites exposing (CharacterSprites, TileSprites, drawCharacter, drawTile, Action(..), Direction(..))

import Array exposing (Array)
import List
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Messages exposing (Msg)


type alias CharacterSprites =
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


type alias TileSprites =
    { imageUrl : String
    , sprites : List TileSprite
    }


type alias TileSprite =
    { name : String
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


drawCharacter : Int -> Int -> String -> Action -> Float -> Direction -> CharacterSprites -> Svg Msg
drawCharacter x y name action actionDuration direction characterSprites =
    let
        viewbox =
            findFrames name action actionDuration direction characterSprites

        spriteWidth =
            16

        spriteHeight =
            16
    in
        drawSprite x y spriteWidth spriteHeight viewbox characterSprites.imageUrl


drawTile : Int -> Int -> String -> TileSprites -> Svg Msg
drawTile gridX gridY name tileSprites =
    let
        viewbox =
            tileViewbox name tileSprites

        spriteWidth =
            16

        spriteHeight =
            16
    in
        drawSprite (gridX * spriteWidth) (gridY * spriteHeight) spriteWidth spriteHeight viewbox tileSprites.imageUrl


tileViewbox : String -> TileSprites -> String
tileViewbox name tileSprites =
    let
        sprite =
            tileSprites.sprites
                |> List.filter (\c -> c.name == name)
                |> List.head
    in
        case sprite of
            Just sprite ->
                findFrame sprite.frames sprite.animationSpeed 0

            Nothing ->
                ""


findFrames : String -> Action -> Float -> Direction -> CharacterSprites -> String
findFrames name action actionDuration direction characterSprites =
    let
        sprite =
            characterSprites.sprites
                |> List.filter (\c -> c.name == name && c.action == action && c.direction == direction)
                |> List.head
    in
        case sprite of
            Just sprite ->
                findFrame sprite.frames sprite.animationSpeed actionDuration

            Nothing ->
                ""


findFrame : Array (List Int) -> Float -> Float -> String
findFrame frames animationSpeed duration =
    let
        numberOfFrames =
            Array.length frames

        currentFrame =
            round (1 / animationSpeed * duration) % numberOfFrames
    in
        Array.get currentFrame frames |> Maybe.withDefault [] |> listOfIntToViewboxString


listOfIntToViewboxString : List Int -> String
listOfIntToViewboxString list =
    list
        |> List.map (\x -> toString x)
        |> String.join " "


px : Int -> String
px n =
    (toString n) ++ "px"


drawSprite : Int -> Int -> Int -> Int -> String -> String -> Svg Msg
drawSprite xPos yPos spriteWidth spriteHeight spriteViewbox path =
    svg [ x (px xPos), y (px yPos), width (px spriteWidth), height (px spriteHeight), viewBox spriteViewbox ]
        [ image [ imageRendering "pixelated", xlinkHref path ] []
        ]
