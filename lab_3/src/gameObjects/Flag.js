class Flag {

    constructor(scene) {

        const flagObject = scene.map.getObjectLayer('flag').objects[0];
        const flagCoordinates = scene.tileset.texCoordinates[962]; //NOTE: get coordinates of flag in tileset
        const flagRoot = scene.platform.getTileAt(76, 18); //NOTE: get specific tile from map, tile must exist

        this.scene = scene;

        this.sprite = scene.add.tileSprite(flagObject.x, flagObject.y, 16, 16, 'tiles')
            .setOrigin(0, 1)
            .setTilePosition(flagCoordinates.x, flagCoordinates.y);

        flagRoot.setCollisionCallback(() => {
            flagRoot.collisionCallback = null;

            this.scene.player.victory()
            this.scene.input.keyboard.shutdown();

            const particles = scene.add.particles('atlas', 'mario-atlas_13');
            const emitter = particles.createEmitter({
                x: flagObject.x,
                y: flagObject.y - flagObject.height,
                scale:  { start: 1, end: 0 },
                speed:  { min: 50, max: 100 },
                angle:  { min: 0, max: -180 },
                rotate: { min: 0, max: 360 },
                alpha: .5
            });

            scene.tweens.add({
                targets: this.sprite,
                ease: 'Linear',
                y: '+=60',
                duration: 800,
                onComplete: () => emitter.stop()
            });

            setTimeout(() => {
                this.scene.scene.start('Victory');
            }, 2000);
        });
    }
}

export default Flag;
