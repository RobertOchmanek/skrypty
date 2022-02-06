import Phaser from 'phaser'

import Game from './scenes/Game.js'
import GameOver from "./scenes/GameOver"
import Victory from "./scenes/Victory";

import './assets/scss/index.scss'

const config = {
    width: 640,
    height: 480,
    parent: 'mario',
    backgroundColor: '#FFFFAC',
    pixelArt: true,
    physics: {
        default: 'arcade',
        arcade: {
            gravity: {
                y: 1000
            }
        }
    },
    scene: [
        Game,
        GameOver,
        Victory,
    ]
};

new Phaser.Game(config);
