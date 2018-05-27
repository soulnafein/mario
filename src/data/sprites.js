import imageUrl from '../graphics/characters.gif'


export default
{
  "imageUrl": imageUrl,
  "sprites": [
    {"name" : "mario", "action": "standing", "direction": "left", "animation": [ [222, 44, 16, 16 ] ], "animationSpeed" : 1 }
    , {"name" : "mario", "action": "jumping", "direction": "left", "animation": [ [142, 44, 16, 16 ] ], "animationSpeed" : 1 }
    , {"name" : "mario", "action": "falling", "direction": "left", "animation": [ [142, 44, 16, 16 ] ], "animationSpeed" : 1 }
    , {"name" : "mario", "action": "walking", "direction": "left", "animation": [ [206, 44, 16, 16 ],[193, 44, 16, 16 ],[177, 44, 16, 16 ]], "animationSpeed" : 0.250 }
    , {"name" : "mario", "action": "standing", "direction": "right", "animation": [ [275, 44, 16, 16 ] ], "animationSpeed" : 1}
    , {"name" : "mario", "action": "jumping", "direction": "right", "animation": [ [355, 44, 16, 16 ] ], "animationSpeed" : 1}
    , {"name" : "mario", "action": "falling", "direction": "right", "animation": [ [355, 44, 16, 16 ] ], "animationSpeed" : 1}
    , {"name" : "mario", "action": "walking", "direction": "right", "animation": [ [291, 44, 16, 16 ],[304, 44, 16, 16 ],[320, 44, 16, 16 ]], "animationSpeed" : 0.250
    }
  ]
};
