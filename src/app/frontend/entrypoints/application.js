import "@hotwired/turbo-rails";
import "@fortawesome/fontawesome-free/css/all.min.css";
import "../stylesheets/application.css";
import "../flash_modal";
import { initFlowbite } from "flowbite";
import "chartkick/chart.js";
import "chartjs-adapter-date-fns";
import "./custom_confirm";

import { Application } from "@hotwired/stimulus";
import ReportFiltersController from "../controllers/report_filters_controller";
import NestedFormController from "../controllers/nested_form_controller";
import UniqueSelectionController from "../controllers/unique_selection_controller";

const application = Application.start();
application.register("report-filters", ReportFiltersController);
application.register("nested-form", NestedFormController);
application.register("unique-selection", UniqueSelectionController);

// Inicializa Flowbite cuando el DOM esté listo
document.addEventListener("DOMContentLoaded", () => {
  initFlowbite();
});
