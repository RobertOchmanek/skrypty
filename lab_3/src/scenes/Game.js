import Player from "../gameObjects/Player";
import Coin from "../gameObjects/Coin";
import Goomba from "../gameObjects/Goomba";
import Flag from "../gameObjects/Flag";
import DeadZones from "../gameObjects/DeadZones";

import generateAnimations from '../config/animations'

class Game extends Phaser.Scene {

    constructor () {
        super('Game');
    }

    preload() {
        this.load.image('tiles', './assets/tiles.png');
        this.load.tilemapTiledJSON('map', './assets/map.json');
        this.load.atlas('atlas', './assets/mario-atlas.png', './assets/mario-atlas.json');

        this.load.on('complete', () => {
            generateAnimations(this);
        });
    }

    create() {
        document.getElementsByClassName('game-over')[0].classList.remove('visible');
        document.getElementsByClassName('victory')[0].classList.remove('visible');

        this.map = this.make.tilemap({ key: 'map' });
        this.tileset = this.map.addTilesetImage('map-tileset', 'tiles');
        this.platform = this.map.createStaticLayer('platform', this.tileset, 0, 0);
        this.map.createStaticLayer('background', this.tileset, 0, 0);
        this.platform.setCollisionByExclusion([-1, 450], true);

        this.player = new Player(this, 25, 400);
        this.coins = new Coin(this).collideWith(this.player.sprite);
        this.goombas = new Goomba(this);
        this.flag = new Flag(this);
        this.deadZones = new DeadZones(this).collideWith(this.player.sprite);

        this.inputs = this.input.keyboard.createCursorKeys();
    }

    update() {
        this.player.update(this.inputs);
        this.coins.update();
        this.goombas.update();
        this.deadZones.update();
    }
}

export default Game;
