document.addEventListener("turbo:load", () => {
    const modal = document.getElementById("flashModal");
    const content = document.getElementById("flashModalContent");
    const closeBtn = document.getElementById("flashModalClose");

    if (!modal || !content) return;

    // Mostrar si hay mensaje
    if (content.innerText.trim().length > 0) {
        modal.classList.remove("hidden");

        // Auto-cerrar después de 5 segundos (opcional)
        setTimeout(() => closeModal(), 5000);
    }

    // Función para cerrar con animación
    function closeModal() {
        modal.classList.add("closing");
        setTimeout(() => {
            modal.classList.add("hidden");
            modal.classList.remove("closing");
        }, 200);
    }

    // Cerrar al hacer click en el botón
    if (closeBtn) {
        closeBtn.addEventListener("click", closeModal);
    }

    // Cerrar al hacer click fuera del modal
    modal.addEventListener("click", (e) => {
        if (e.target === modal) {
            closeModal();
        }
    });

    // Cerrar con tecla ESC
    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape" && !modal.classList.contains("hidden")) {
            closeModal();
        }
    });
});