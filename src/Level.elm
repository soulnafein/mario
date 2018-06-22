module Level exposing (init, draw, Level, update)

import Sprites exposing (TileSprites, drawTile)
import Svg exposing (..)
import Svg
import Messages exposing (Msg)
import Data.Sprites
import Mario exposing (Mario, isWalkingPastTheMiddleOfTheLevel)
import Dict exposing (Dict)
import Exts.Dict exposing (groupBy)


type alias Tile =
    { x : Int
    , y : Int
    , name : String
    }


type alias TileRange =
    { name : String
    , rectangle : ( Int, Int, Int, Int )
    }


type alias Level =
    { visibleTiles : List Tile
    , horizontalOffset : Float
    , tileSprites : TileSprites
    }


tilesData : Dict Int (List Tile)
tilesData =
    let
        ranges =
            [ { name = "ground"
              , rectangle = ( 0, 12, 68, 13 )
              }
            , { name = "ground"
              , rectangle = ( 71, 12, 85, 13 )
              }
            , { name = "ground"
              , rectangle = ( 89, 12, 152, 13 )
              }
            , { name = "ground"
              , rectangle = ( 155, 12, 211, 13 )
              }
            ]
                ++ (hill 0 9)
                ++ (smallHill 16 10)
                ++ (hill 48 9)
                ++ (smallHill 64 10)
                ++ (hill 96 9)
                ++ (smallHill 112 10)
                ++ [ { name = "hill-1"
                     , rectangle = ( 144, 11, 144, 11 )
                     }
                   , { name = "hill-1"
                     , rectangle = ( 145, 10, 145, 10 )
                     }
                   , { name = "hill-4"
                     , rectangle = ( 145, 11, 145, 11 )
                     }
                   , { name = "hill-5"
                     , rectangle = ( 146, 11, 146, 11 )
                     }
                   , { name = "hill-4"
                     , rectangle = ( 146, 10, 146, 10 )
                     }
                   , { name = "hill-2"
                     , rectangle = ( 146, 9, 146, 9 )
                     }
                   , { name = "hill-3"
                     , rectangle = ( 147, 10, 147, 10 )
                     }
                   , { name = "hill-4"
                     , rectangle = ( 147, 11, 147, 11 )
                     }
                   ]
                ++ (smallHill 160 10)
                ++ (hill 192 9)
                ++ (smallHill 208 10)
                ++ (nBush 3 11 11)
                ++ (nBush 1 23 11)
                ++ (nBush 2 41 11)
                ++ (nBush 3 59 11)
                ++ (nBush 1 71 11)
                ++ (nBush 2 89 11)
                ++ (nBush 3 107 11)
                ++ (nBush 1 119 11)
                ++ [ { name = "bush-2"
                     , rectangle = ( 138, 11, 139, 11 )
                     }
                   ]
                ++ [ { name = "bush-3", rectangle = ( 159, 11, 159, 11 ) } ]
                ++ (nBush 1 167 11)
                ++ [ { name = "bush-3", rectangle = ( 207, 11, 207, 11 ) } ]
                ++ (nCloud 1 8 2)
                ++ (nCloud 1 19 1)
                ++ (nCloud 3 27 2)
                ++ (nCloud 2 36 1)
                ++ (nCloud 1 56 2)
                ++ (nCloud 1 67 1)
                ++ (nCloud 3 75 2)
                ++ (nCloud 2 84 1)
                ++ (nCloud 1 104 2)
                ++ (nCloud 1 115 1)
                ++ (nCloud 3 123 2)
                ++ (nCloud 2 132 1)
                ++ (nCloud 1 152 2)
                ++ (nCloud 1 163 1)
                ++ (nCloud 3 171 2)
                ++ (nCloud 2 180 1)
                ++ (nCloud 1 200 2)
                ++ (nPipe 1 28 10)
                ++ (nPipe 2 38 9)
                ++ (nPipe 3 46 8)
                ++ (nPipe 3 57 8)
                ++ (nPipe 1 163 10)
                ++ (nPipe 1 179 10)
                ++ (lootBox 16 8)
                ++ (lootBox 22 4)
                ++ (lootBox 21 8)
                ++ (lootBox 23 8)
                ++ (lootBox 78 8)
                ++ (lootBox 94 4)
                ++ (lootBox 106 8)
                ++ (lootBox 109 8)
                ++ (lootBox 109 4)
                ++ (lootBox 112 8)
                ++ (lootBox 129 4)
                ++ (lootBox 130 4)
                ++ (lootBox 170 8)
                ++ (brick 20 8)
                ++ (brick 22 8)
                ++ (brick 24 8)
                ++ (brick 77 8)
                ++ (brick 79 8)
                ++ (brick 80 4)
                ++ (brick 81 4)
                ++ (brick 82 4)
                ++ (brick 83 4)
                ++ (brick 84 4)
                ++ (brick 85 4)
                ++ (brick 86 4)
                ++ (brick 87 4)
                ++ (brick 91 4)
                ++ (brick 92 4)
                ++ (brick 93 4)
                ++ (brick 94 8)
                ++ (brick 100 8)
                ++ (brick 118 8)
                ++ (brick 121 4)
                ++ (brick 122 4)
                ++ (brick 123 4)
                ++ (brick 128 4)
                ++ (brick 129 8)
                ++ (brick 130 8)
                ++ (brick 131 4)
                ++ (brick 168 8)
                ++ (brick 169 8)
                ++ (brick 171 8)
                ++ [ { name = "hard-brick"
                     , rectangle = ( 134, 11, 137, 11 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 135, 10, 137, 10 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 136, 9, 137, 9 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 137, 8, 137, 8 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 11, 143, 11 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 10, 142, 10 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 9, 141, 9 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 140, 8, 140, 8 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 148, 11, 152, 11 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 149, 10, 152, 10 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 150, 9, 152, 9 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 151, 8, 152, 8 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 11, 158, 11 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 10, 157, 10 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 9, 156, 9 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 155, 8, 155, 8 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 181, 11, 189, 11 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 182, 10, 189, 10 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 183, 9, 189, 9 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 184, 8, 189, 8 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 185, 7, 189, 7 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 186, 6, 189, 6 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 187, 5, 189, 5 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 188, 4, 189, 4 )
                     }
                   , { name = "hard-brick"
                     , rectangle = ( 198, 11, 198, 11 )
                     }
                   ]
                ++ castle 202 7
    in
        generateTiles ranges


init : String -> Level
init tilesPath =
    { visibleTiles = tilesAtOffset 0 tilesData
    , horizontalOffset = 0
    , tileSprites = Data.Sprites.tiles tilesPath
    }


update : Float -> Mario -> Level -> Level
update dt mario level =
    let
        horizontalOffsetIncrease =
            mario.horizontalVelocity * dt

        horizontalOffset =
            if isWalkingPastTheMiddleOfTheLevel mario then
                level.horizontalOffset + horizontalOffsetIncrease
            else
                level.horizontalOffset
    in
        { level
            | horizontalOffset = horizontalOffset
            , visibleTiles = tilesAtOffset horizontalOffset tilesData
        }


tilesAtOffset : Float -> Dict Int (List Tile) -> List Tile
tilesAtOffset offset tiles =
    let
        gridXMin =
            round (offset / 16) - 1

        gridXMax =
            gridXMin + 16 + 2

        result =
            List.range gridXMin gridXMax
                |> List.map (\gridX -> Dict.get gridX tiles |> Maybe.withDefault [])
                |> List.concat
    in
        result


lootBox : Int -> Int -> List TileRange
lootBox x y =
    [ { name = "loot-box"
      , rectangle = ( x, y, x, y )
      }
    ]


tile : Int -> Int -> String -> List TileRange
tile x y name =
    [ { name = name
      , rectangle = ( x, y, x, y )
      }
    ]


castle : Int -> Int -> List TileRange
castle x y =
    []
        ++ (brick x (y + 3))
        ++ (brick x (y + 4))
        ++ (brick (x + 1) (y + 3))
        ++ (brick (x + 1) (y + 4))
        ++ (brick (x + 3) (y + 3))
        ++ (brick (x + 3) (y + 4))
        ++ (brick (x + 4) (y + 3))
        ++ (brick (x + 4) (y + 4))
        ++ (brick (x + 2) (y + 1))
        ++ (tile (x + 1) y "castle-1")
        ++ (tile (x + 2) y "castle-1")
        ++ (tile (x + 3) y "castle-1")
        ++ (tile (x + 2) (y + 4) "castle-6")
        ++ (tile (x + 2) (y + 3) "castle-5")
        ++ (tile (x + 1) (y + 2) "castle-4")
        ++ (tile (x + 2) (y + 2) "castle-4")
        ++ (tile (x + 3) (y + 2) "castle-4")
        ++ (tile x (y + 2) "castle-1")
        ++ (tile (x + 4) (y + 2) "castle-1")
        ++ (tile (x + 1) (y + 1) "castle-2")
        ++ (tile (x + 3) (y + 1) "castle-3")


brick : Int -> Int -> List TileRange
brick x y =
    [ { name = "brick-1"
      , rectangle = ( x, y, x, y )
      }
    ]


nPipe : Int -> Int -> Int -> List TileRange
nPipe n x y =
    [ { name = "pipe-1"
      , rectangle = ( x, y, x, y )
      }
    , { name = "pipe-2"
      , rectangle = ( x + 1, y, x + 1, y )
      }
    ]
        ++ (List.range 1 n
                |> List.concatMap
                    (\relativeY ->
                        [ { name = "pipe-3"
                          , rectangle = ( x, y + relativeY, x, y + relativeY )
                          }
                        , { name = "pipe-4"
                          , rectangle = ( x + 1, y + relativeY, x + 1, y + relativeY )
                          }
                        ]
                    )
           )


nBush : Int -> Int -> Int -> List TileRange
nBush n x y =
    [ { name = "bush-1"
      , rectangle = ( x, y, x, y )
      }
    ]
        ++ ((List.range 1 n)
                |> List.map (\relativeX -> { name = "bush-2", rectangle = ( relativeX + x, y, relativeX + x, y ) })
           )
        ++ [ { name = "bush-3"
             , rectangle = ( x + n + 1, y, x + n + 1, y )
             }
           ]


nCloud : Int -> Int -> Int -> List TileRange
nCloud n x y =
    [ { name = "cloud-1"
      , rectangle = ( x, y, x, y )
      }
    ]
        ++ ((List.range 1 n)
                |> List.map (\relativeX -> { name = "cloud-2", rectangle = ( relativeX + x, y, relativeX + x, y ) })
           )
        ++ [ { name = "cloud-3"
             , rectangle = ( x + n + 1, y, x + n + 1, y )
             }
           ]
        ++ [ { name = "cloud-4"
             , rectangle = ( x, y + 1, x, y + 1 )
             }
           ]
        ++ ((List.range 1 n)
                |> List.map (\relativeX -> { name = "cloud-5", rectangle = ( relativeX + x, y + 1, relativeX + x, y + 1 ) })
           )
        ++ [ { name = "cloud-6"
             , rectangle = ( x + n + 1, y + 1, x + n + 1, y + 1 )
             }
           ]


cloud : Int -> Int -> List TileRange
cloud x y =
    nCloud 1 x y


doubleCloud : Int -> Int -> List TileRange
doubleCloud x y =
    [ { name = "cloud-1"
      , rectangle = ( x, y, x, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 1, y, x + 1, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 2, y, x + 2, y )
      }
    , { name = "cloud-3"
      , rectangle = ( x + 3, y, x + 3, y )
      }
    , { name = "cloud-4"
      , rectangle = ( x, y + 1, x, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      }
    , { name = "cloud-6"
      , rectangle = ( x + 3, y + 1, x + 3, y + 1 )
      }
    ]


tripleCloud : Int -> Int -> List TileRange
tripleCloud x y =
    [ { name = "cloud-1"
      , rectangle = ( x, y, x, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 1, y, x + 1, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 2, y, x + 2, y )
      }
    , { name = "cloud-2"
      , rectangle = ( x + 3, y, x + 3, y )
      }
    , { name = "cloud-3"
      , rectangle = ( x + 4, y, x + 4, y )
      }
    , { name = "cloud-4"
      , rectangle = ( x, y + 1, x, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 2, y + 1, x + 2, y + 1 )
      }
    , { name = "cloud-5"
      , rectangle = ( x + 3, y + 1, x + 3, y + 1 )
      }
    , { name = "cloud-6"
      , rectangle = ( x + 4, y + 1, x + 4, y + 1 )
      }
    ]


smallHill : Int -> Int -> List TileRange
smallHill x y =
    [ { name = "hill-1"
      , rectangle = ( x, y + 1, x, y + 1 )
      }
    , { name = "hill-4"
      , rectangle = ( x + 1, y + 1, x + 1, y + 1 )
      }
    , { name = "hill-2"
      , rectangle = ( x + 1, y, x + 1, y )
      }
    , { name = "hill-3"
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


generateTiles : List TileRange -> Dict Int (List Tile)
generateTiles ranges =
    ranges
        |> List.concatMap generateTilesFromRange
        |> groupBy .x


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


draw : Level -> Svg Msg
draw level =
    let
        tiles =
            level.visibleTiles

        tileSprites =
            level.tileSprites

        offset =
            round level.horizontalOffset
    in
        g [] (List.map (\tile -> drawTile tile.x tile.y offset tile.name tileSprites) tiles)
