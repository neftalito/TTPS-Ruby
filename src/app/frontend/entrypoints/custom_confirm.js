document.addEventListener("turbo:load", () => {
  Turbo.setConfirmMethod((message) => {
    const translations = window.appTranslations?.customConfirm;

    if (!translations?.title || !translations?.cancel || !translations?.accept) {
      return Promise.resolve(window.confirm(message));
    }

    return new Promise((resolve) => {
      showCustomConfirm(message, translations, (confirmed) => resolve(confirmed));
    });
  });
});

function showCustomConfirm(message, translations, callback) {
  const modal = document.createElement("div");
  modal.className =
    "fixed inset-0 bg-proyecto-text/20 backdrop-blur-sm flex items-center justify-center z-50 transition-opacity duration-200";

  modal.innerHTML = `
    <div class="bg-white border border-proyecto-secondary rounded-2xl p-8 max-w-md mx-4 shadow-2xl transform scale-100 transition-transform">
      <h3 class="text-xl font-bold text-proyecto-primary mb-3">
        ${translations.title}
      </h3>

      <p class="text-proyecto-text/80 mb-8 leading-relaxed">
        ${message}
      </p>

      <div class="flex gap-3 justify-end">
        <button id="custom-modal-cancel"
          class="px-5 py-2.5 bg-white border border-proyecto-text/20 hover:bg-proyecto-secondary/20 text-proyecto-text rounded-lg font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-proyecto-secondary">
          ${translations.cancel}
        </button>

        <button id="custom-modal-confirm"
          class="px-5 py-2.5 bg-proyecto-error hover:bg-proyecto-error/90 text-white rounded-lg font-bold shadow-lg shadow-proyecto-error/30 transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-proyecto-error">
          ${translations.accept}
        </button>
      </div>
    </div>
  `;

  document.body.appendChild(modal);

  document.getElementById("custom-modal-cancel").addEventListener("click", () => {
    close();
    callback(false);
  });

  document.getElementById("custom-modal-confirm").addEventListener("click", () => {
    close();
    callback(true);
  });

  modal.addEventListener("click", (e) => {
    if (e.target === modal) {
      close();
      callback(false);
    }
  });

  function close() {
    modal.style.opacity = "0";
    setTimeout(() => modal.remove(), 150);
  }
}
