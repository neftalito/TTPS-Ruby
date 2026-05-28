require "test_helper"

class Backstore::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:employee)
  end

  test "shows the report dashboard" do
    get backstore_reports_url

    assert_response :success
    assert_includes response.body, "Reporte de ventas"
    assert_includes response.body, "Top 5 productos mas vendidos"
    assert_includes response.body, backstore_product_path(products(:vinyl_rock))
  end

  test "exports csv preserving the active filters" do
    get backstore_reports_url(format: :csv), params: {
      range: "custom",
      start_date: "2026-05-01",
      end_date: "2026-05-31",
      product_type: "cd"
    }

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_includes response.body, "Tipo de producto,CD"
    assert_includes response.body, "CD Azul"
    refute_includes response.body, "Vinilo Dorado"
  end
end
