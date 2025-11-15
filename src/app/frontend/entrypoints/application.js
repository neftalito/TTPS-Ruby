import "@hotwired/turbo-rails"
import "@fortawesome/fontawesome-free/css/all.min.css";
import "../stylesheets/application.css";
import "../flash_modal"
import { initFlowbite } from 'flowbite';

// Inicializa Flowbite cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    initFlowbite();
});