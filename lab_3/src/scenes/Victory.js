import resetStats from "../ui/resetStats";

class Victory extends Phaser.Scene {

    constructor () {
        super('Victory');
        this.ended = false;
    }

    create() {
        this.cameras.main.setBackgroundColor('#000');
        document.getElementsByClassName('victory')[0].classList.add('visible');
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

export default Victory;
