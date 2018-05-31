import './main.css';
import { Main } from './Main.elm';
import charactersPath from './graphics/characters.gif';
import tilesPath from './graphics/tiles.png';
import registerServiceWorker from './registerServiceWorker';

Main.embed(document.getElementById('root'), {charactersPath: charactersPath, tilesPath: tilesPath });

registerServiceWorker();
