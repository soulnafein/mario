module Level exposing (draw)

import Sprites exposing (TileSprites, drawTile)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg
import Messages exposing (Msg)


type alias Tile =
    { x : Int
    , y : Int
    , name : String
    }


type alias TileRange =
    { name : String
    , rectangle : ( Int, Int, Int, Int )
    }


tiles : List Tile
tiles =
    let
        ranges =
            [ { name = "ground"
              , rectangle = ( 0, 11, 15, 12 )
              }
            , { name = "sky"
              , rectangle = ( 0, 0, 15, 10 )
              }
            ]
                ++ (hill 0 8)
                ++ (cloud 9 3)
    in
        generateTiles ranges


cloud : Int -> Int -> List TileRange
cloud x y =
    [ { name = "cloud-1"
      , rectangle = ( x, y, x, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 1, y, x + 1, y )
      }
    , { name = "cloud-3"
      , rectangle = ( x + 2, y, x + 2, y )
      }
    , { name = "cloud-4"
      , rectangle = ( x, y + 1, x, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "cloud-6"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      }
    ]


hill : Int -> Int -> List TileRange
hill x y =
    [ { name = "hill-1"
      , rectangle = ( x, y + 2, x, y + 2 )
      }
    , { name = "hill-1"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 1, y + 2, x + 1, y + 2 )
      }
    , { name = "hill-5"
      , rectangle = ( x + 2, y + 2, x + 2, y + 2 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      }
    , { name = "hill-2"
      , rectangle = ( x + 2, y, x + 2, y )
      }
    , { name = "hill-3"
      , rectangle = ( x + 3, y + 1, x + 3, y + 1 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 3, y + 2, x + 3, y + 2 )
      }
    , { name = "hill-3"
      , rectangle = ( x + 4, y + 2, x + 4, y + 2 )
      }
    ]


generateTiles : List TileRange -> List Tile
generateTiles ranges =
    ranges
        |> List.concatMap generateTilesFromRange


generateTilesFromRange : TileRange -> List Tile
generateTilesFromRange range =
    let
        ( x1, y1, x2, y2 ) =
            range.rectangle
    in
        List.range y1 y2
            |> List.concatMap (generateTileRow x1 x2 range.name)


generateTileRow : Int -> Int -> String -> Int -> List Tile
generateTileRow x1 x2 name y =
    List.range x1 x2
        |> List.map (\x -> { x = x, y = y, name = name })


draw : TileSprites -> Svg Msg
draw tileSprites =
    g [] (List.map (\tile -> drawTile tile.x tile.y tile.name tileSprites) tiles)


px : Int -> String
px n =
    (toString n) ++ "px"


drawSprite : Int -> Int -> Int -> Int -> String -> String -> Svg Msg
drawSprite xPos yPos spriteWidth spriteHeight spriteViewbox path =
    svg [ x (px xPos), y (px yPos), width (px spriteWidth), height (px spriteHeight), viewBox spriteViewbox ]
        [ image [ imageRendering "pixelated", xlinkHref path ] []
        ]
