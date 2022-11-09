require "minitest_cuprite"
minitest_cuprite "headless": false

describe :test do
  it "кол-во товаров в Summer Dresses и цена Printed Chiffon" do
    visit "http://localhost:4567/index.php"

    # найти нужные <a> с соответствующим текстом, чтобы перейти в раздел летних платьев
    find(:xpath, "//???").hover    # Dresses
    find(:xpath, "//???").click    # Summer Dresses

    # убедиться, что отобразились три товара
    assert_equal 3, find_all(:css,"???").size

    # проверить цену платья Printed Chiffon
    assert_equal "$16.40", find(:css,".product_list").find(:xpath,".//*[.//*[contains(text(),???)]]//*[???]").text
  end
end
