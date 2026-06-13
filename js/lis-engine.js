let lastSummary = "No data loaded.";
let timer;

function speakResult(text) {
    window.speechSynthesis.cancel();
    const msg = new SpeechSynthesisUtterance(text);
    msg.rate = 1.1;
    window.speechSynthesis.speak(msg);
    document.getElementById('display').innerText = text;
}

function stopAudio() {
    window.speechSynthesis.cancel();
    document.getElementById('display').innerText = "AUDIO TERMINATED";
}

function repeatLast() { speakResult(lastSummary); }

async function query(type) {
    let code = prompt("Enter Statute Number:");
    if (!code) return;
    // Placeholder for LIS API call
    let response = "STATUTE " + code + " SUMMARY: [DATA RETRIEVED FROM LIS]";
    lastSummary = response;
    speakResult(response);
}

function startPress() {
    timer = setTimeout(() => {
        document.body.style.backgroundColor = "red";
        speakResult("EMERGENCY. DIALING 911.");
        window.location.href = "tel:911";
    }, 3000);
}

function endPress() { clearTimeout(timer); }
