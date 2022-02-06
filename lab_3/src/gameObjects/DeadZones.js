import decreaseLives from "../ui/decreaseLives";

class DeadZones {

    constructor(scene) {
        this.scene = scene;

        this.deadZones = this.scene.physics.add.group({
            immovable: true,
            allowGravity: false
        });

        const deadZonesObjects = this.scene.map.getObjectLayer('deadZones').objects;

        for (const deadZone of deadZonesObjects) {
            this.deadZones.create(deadZone.x, deadZone.y, '')
                .setOrigin(0)
                .setDepth(-1);
        }
    }

    collideWith(gameObject) {
        this.scene.physics.add.overlap(this.deadZones, gameObject, this.killPlayer, null, this);
        return this;
    }

    update() {
        for (const deadZone of this.deadZones.children.entries) {
            deadZone.play('rotate', true);
        }
    }

    killPlayer() {
        if (!this.scene.player.sprite.isDed) {
            decreaseLives(true);

            this.scene.player.die();
            this.scene.input.keyboard.shutdown();
            this.scene.physics.world.removeCollider(this.scene.player.collider);

            setTimeout(() => {
                this.scene.scene.start('GameOver');
            }, 1500);
        }
    }
}

export default DeadZones;
