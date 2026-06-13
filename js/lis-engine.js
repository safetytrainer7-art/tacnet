
// Initialize Recognition
const recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
recognition.continuous = true;
recognition.onresult = (event) => {
    const transcript = event.results[event.results.length - 1][0].transcript;
    document.getElementById('display').innerText = "COMMAND: " + transcript;
    // Logic to parse for Title 18.2, etc.
};
recognition.start();

function trigger911() {
    document.body.style.backgroundColor = "red";
    // Add GPS logic here
}
