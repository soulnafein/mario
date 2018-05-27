module Models.Sprites exposing (SpritesData)


type alias SpritesData =
    { imageUrl : String
    , sprites : List CharacterSprite
    }


type alias CharacterSprite =
    { action : String
    , name : String
    , direction : String
    , animation : List (List Int)
    }
