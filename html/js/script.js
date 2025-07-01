function defaultIcon(type) {
  switch (type) {
      case "success":      return "fa-solid fa-circle-check";
      case "error":        return "fa-solid fa-circle-xmark";
      case "warning":      return "fa-solid fa-triangle-exclamation";
      case "info":         return "fa-solid fa-circle-info";
      case "invoice":      return "fa-solid fa-receipt";
      case "police":       return "fa-solid fa-shield-halved";
      case "ems":          return "fa-solid fa-truck-medical";
      case "mec":          return "fa-solid fa-wrench";
      case "staff":        return "fa-solid fa-user-tie";
      case "blackmarket":  return "fa-solid fa-user-secret";
      default:             return "fa-solid fa-circle-info";
  }
}

function getNotificationColor(type) {
  switch (type) {
      case "success":     return "#2ecc71";  // Grøn
      case "error":       return "#e74c3c";  // Rød
      case "warning":     return "#d16500";  // Orange
      case "info":        return "#3498db";  // Blå
      case "invoice":     return "#828282";  // Grå
      case "police":      return "#005dff";  // Blå
      case "ems":         return "#ff3a3a";  // Rød
      case "mec":         return "#d16500";  // Orange
      case "staff":       return "#ff0000";  // Rød
      case "blackmarket": return "#464646";  // Sort
      default:            return "#3498db";  // Default: Blå
  }
}

function parseMarkdown(text) {
text = text.replace(/∑/g, "<i class='fa-solid fa-star'></i>")
           .replace(/÷/g, "<i class='fa-solid fa-star'></i>")
           .replace(/¦/g, "<i class='fa-solid fa-check'></i>");

text = text.replace(/~r~/g, "<span class='color-red'>")
           .replace(/~b~/g, "<span class='color-blue'>")
           .replace(/~g~/g, "<span class='color-green'>")
           .replace(/~y~/g, "<span class='color-yellow'>")
           .replace(/~p~/g, "<span class='color-purple'>")
           .replace(/~c~/g, "<span class='color-grey'>")
           .replace(/~m~/g, "<span class='color-darkgrey'>")
           .replace(/~u~/g, "<span class='color-black'>")
           .replace(/~o~/g, "<span class='color-orange'>")
           .replace(/~n~/g, "<br>")
           .replace(/~s~/g, "</span>")
           .replace(/~h~/g, "<strong>");

text = text.replace(/\^1/g, "<span class='color-red'>")
           .replace(/\^2/g, "<span class='color-green'>")
           .replace(/\^3/g, "<span class='color-yellow'>")
           .replace(/\^4/g, "<span class='color-blue'>")
           .replace(/\^5/g, "<span class='color-cyan'>")
           .replace(/\^6/g, "<span class='color-pink'>")
           .replace(/\^7/g, "<span class='color-white'>")
           .replace(/\^9/g, "<span class='color-gray'>")
           .replace(/\^0/g, "<span class='color-black'>")
           .replace(/\^c/g, "<span class='color-blandishbeige'>");

text = text.replace(/\^8/g, "<span class='color-rainbow'>");

text = text.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
           .replace(/_(.*?)_/g, "<em>$1</em>")
           .replace(/~~(.*?)~~/g, "<del>$1</del>")
           .replace(/`(.*?)`/g, "<code>$1</code>");

return text;
}

window.addEventListener("message", (event) => {
  if (event.data.action === "notify") {
    const pos = event.data.position || "top-right";
    const container = document.getElementById(pos);
    if (!container) return;

    const note = document.createElement("div");
    note.className = `notification ${event.data.type}`;

    const iconClass = event.data.icon || defaultIcon(event.data.type);
    const iconColor = getNotificationColor(event.data.type);

    note.innerHTML = `
      <div class="icon" style="background-color:rgb(12, 12, 14);">
        <i class="${iconClass}" style="color: ${iconColor};"></i>
      </div>
      <div class="text">
        <strong>${event.data.title || "Notification"}</strong>
        <p>${parseMarkdown(event.data.description || "")}</p>
      </div>
    `;

    let dir;
    if (pos.startsWith("top") && !pos.includes("center")) dir = "top";
    else if (pos.startsWith("bottom")) dir = "bottom";
    else if (pos.includes("left")) dir = "left";
    else dir = "right";

    note.classList.add(`slide-in-${dir}`);
    container.appendChild(note);

    const dur = event.data.duration ?? 5000;
    setTimeout(() => {
        note.classList.remove(`slide-in-${dir}`);
        note.classList.add(`slide-out-${dir}`);
        setTimeout(() => note.remove(), 1000);
    }, dur);
  }
});
