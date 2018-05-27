import './main.css';
import { Main } from './Main.elm';
import charactersPath from './graphics/characters.gif';
import registerServiceWorker from './registerServiceWorker';
import spritesData from './data/sprites.js';

Main.embed(document.getElementById('root'), {charactersPath: charactersPath, spritesData: spritesData});

registerServiceWorker();
