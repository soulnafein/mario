module Data.Sprites exposing (characters, tiles)

import Sprites exposing (CharacterSprites, TileSprites, Direction(..), Action(..))
import Array


tiles : String -> TileSprites
tiles imageUrl =
    { imageUrl = imageUrl
    , sprites =
        [ { name = "ground"
          , frames = Array.fromList [ [ 0, 0, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "sky"
          , frames = Array.fromList [ [ 48, 368, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "hill-1"
          , frames = Array.fromList [ [ 128, 128, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "hill-2"
          , frames = Array.fromList [ [ 144, 128, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "hill-3"
          , frames = Array.fromList [ [ 160, 128, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "hill-4"
          , frames = Array.fromList [ [ 128, 144, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "hill-5"
          , frames = Array.fromList [ [ 144, 144, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "hill-6"
          , frames = Array.fromList [ [ 160, 144, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "cloud-1"
          , frames = Array.fromList [ [ 0, 320, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "cloud-2"
          , frames = Array.fromList [ [ 16, 320, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "cloud-3"
          , frames = Array.fromList [ [ 32, 320, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "cloud-4"
          , frames = Array.fromList [ [ 0, 336, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "cloud-5"
          , frames = Array.fromList [ [ 16, 336, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "cloud-6"
          , frames = Array.fromList [ [ 32, 336, 16, 16 ] ]
          , animationSpeed = 1
          }
        ]
    }


characters : String -> CharacterSprites
characters imageUrl =
    { imageUrl = imageUrl
    , sprites =
        [ { name = "mario"
          , action = Standing
          , direction = Left
          , frames = Array.fromList [ [ 222, 44, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "mario"
          , action = Jumping
          , direction = Left
          , frames = Array.fromList [ [ 142, 44, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "mario"
          , action = Falling
          , direction = Left
          , frames = Array.fromList [ [ 142, 44, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "mario"
          , action = Walking
          , direction = Left
          , frames = Array.fromList [ [ 206, 44, 16, 16 ], [ 193, 44, 16, 16 ], [ 177, 44, 16, 16 ] ]
          , animationSpeed = 0.25
          }
        , { name = "mario"
          , action = Standing
          , direction = Right
          , frames = Array.fromList [ [ 275, 44, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "mario"
          , action = Jumping
          , direction = Right
          , frames = Array.fromList [ [ 355, 44, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "mario"
          , action = Falling
          , direction = Right
          , frames = Array.fromList [ [ 355, 44, 16, 16 ] ]
          , animationSpeed = 1
          }
        , { name = "mario"
          , action = Walking
          , direction = Right
          , frames = Array.fromList [ [ 291, 44, 16, 16 ], [ 304, 44, 16, 16 ], [ 320, 44, 16, 16 ] ]
          , animationSpeed = 0.25
          }
        ]
    }
