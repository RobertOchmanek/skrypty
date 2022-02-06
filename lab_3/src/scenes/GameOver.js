import resetStats from "../ui/resetStats";

class GameOver extends Phaser.Scene {

    constructor () {
        super('GameOver');
        this.ended = false;
    }

    create() {
        this.cameras.main.setBackgroundColor('#000');
        document.getElementsByClassName('game-over')[0].classList.add('visible');
    }

    update() {
        if (!this.ended) {
            this.ended = true;

            setTimeout(() => {
                this.ended = false;
                resetStats();
                this.scene.start('Game');
            }, 2000);
        }
    }
}

export default GameOver;
