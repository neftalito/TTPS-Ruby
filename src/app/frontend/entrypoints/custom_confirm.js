document.addEventListener("turbo:load", () => {
  // Deshabilitar totalmente el confirm nativo de Turbo
  Turbo.setConfirmMethod((message, element) => {
    return new Promise((resolve) => {
      showCustomConfirm(message, (confirmed) => resolve(confirmed));
    });
  });
});

function showCustomConfirm(message, callback) {
  const modal = document.createElement("div");
  modal.className =
    "fixed inset-0 bg-black/70 backdrop-blur-sm flex items-center justify-center z-50";
  modal.innerHTML = `
    <div class="bg-slate-800 border-2 border-red-500/30 rounded-2xl p-8 max-w-md mx-4 shadow-2xl">
      <h3 class="text-xl font-bold text-red-400 mb-3">Confirmación requerida</h3>
      <p class="text-gray-300 mb-6">${message}</p>
      <div class="flex gap-3 justify-end mt-6">
        <button id="custom-modal-cancel"
          class="px-6 py-2.5 bg-slate-700 hover:bg-slate-600 text-gray-200 rounded-lg">
          Cancelar
        </button>
        <button id="custom-modal-confirm"
          class="px-6 py-2.5 bg-red-500 hover:bg-red-400 text-white rounded-lg font-bold">
          Aceptar
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
