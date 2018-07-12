module Sprites exposing (CharacterSprites, TileSprites, drawTile, drawEntity)

import Array exposing (Array)
import List
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Messages exposing (Msg)
import Time exposing (Time)
import Entity exposing (EntityType, Action, Direction, Entity)
import Viewport exposing (Viewport)


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


drawCharacter : Int -> Int -> Int -> EntityType -> Action -> Float -> Direction -> CharacterSprites -> Svg Msg
drawCharacter x y offset entityType action actionDuration direction characterSprites =
    let
        spriteName =
            case entityType of
                Entity.Mario ->
                    "mario"

                Entity.Goomba ->
                    "goomba"

        viewbox =
            findFrames spriteName action actionDuration direction characterSprites

        spriteWidth =
            16

        spriteHeight =
            16
    in
        drawSprite (x - offset) y spriteWidth spriteHeight viewbox characterSprites.imageUrl


drawTile : Int -> Int -> Int -> String -> TileSprites -> Time -> Svg Msg
drawTile gridX gridY offset name tileSprites elapsedTime =
    let
        viewbox =
            tileViewbox name tileSprites elapsedTime

        spriteSize =
            16

        x =
            (gridX * spriteSize) - offset

        y =
            gridY * spriteSize
    in
        drawSprite x y spriteSize spriteSize viewbox tileSprites.imageUrl


tileViewbox : String -> TileSprites -> Time -> String
tileViewbox name tileSprites elapsedTime =
    let
        sprite =
            tileSprites.sprites
                |> List.filter (\c -> c.name == name)
                |> List.head
    in
        case sprite of
            Just sprite ->
                findFrame sprite.frames sprite.animationSpeed elapsedTime

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


drawEntity : Viewport -> CharacterSprites -> Entity -> Svg Msg
drawEntity viewport characterSprites entity =
    let
        xPos =
            round entity.x

        yPos =
            round entity.y

        offset =
            round viewport.x
    in
        drawCharacter xPos yPos offset entity.type_ entity.action entity.actionDuration entity.direction characterSprites
