export default removeAll => {

    const livesElement = document.getElementsByClassName('lives-amount')[0];
    const currentLives = String(livesElement.innerText);

    if (removeAll) {
        livesElement.innerText = "";
    } else {
        livesElement.innerText = currentLives.slice(0, -1);
    }
};
