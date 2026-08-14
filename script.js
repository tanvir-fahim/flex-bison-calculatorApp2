const expression = document.getElementById("expression");
const consoleEl = document.getElementById("console");

function insert(value) {
    expression.value += value;
    expression.focus();
}

function backspace() {
    expression.value = expression.value.slice(0, -1);
    expression.focus();
}

function clearAll() {
    expression.value = "";
    consoleEl.innerHTML = '<div class="row empty">waiting for input...</div>';
    expression.focus();
}

function row(promptText, stageText, cls) {
    const div = document.createElement("div");
    div.className = "row";
    div.innerHTML =
        '<span class="prompt">' + promptText + '</span>' +
        '<span class="' + cls + '">' + stageText + '</span>';
    return div;
}

async function compile() {
    const value = expression.value.trim();
    if (!value) return;

    consoleEl.innerHTML = "";
    consoleEl.appendChild(row("$", "lexing + parsing " + escapeHtml(value), "stage"));
    consoleEl.appendChild(row("$", "evaluating...", "stage"));

    try {
        const response = await fetch("/calculate", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ expression: value })
        });

        const data = await response.json();

        consoleEl.appendChild(
            data.error
                ? row(">", escapeHtml(data.error), "err")
                : row(">", escapeHtml(data.result), "result")
        );
    } catch (error) {
        consoleEl.appendChild(row(">", "could not reach compiler backend", "err"));
    }
}

function escapeHtml(str) {
    const div = document.createElement("div");
    div.textContent = str;
    return div.innerHTML;
}

expression.addEventListener("keydown", function(event) {
    if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
        event.preventDefault();
        compile();
    }
});

expression.focus();