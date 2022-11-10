# frozen_string_literal: true

require 'minitest_cuprite'
minitest_cuprite "headless": true

def with_class(klass)
  "[contains(concat(' ', normalize-space(@class), ' '), #{klass})]"
end

describe :test do
  let(:dresses_xpath) { "//*#{with_class('menu-content')}/li/a[@title='Dresses']" }
  let(:printed_chiffon_dress_price) do
    find(:css, '.product_list')
      .find(:xpath, "//*[contains(text(), 'Printed Chiffon Dress')]/../..\
                     //div#{with_class('content_price')}/*[@itemprop='price']")
      .text
  end

  before do
    visit 'http://localhost:4567/index.php'
    find(:xpath, dresses_xpath).hover # Dresses
    find(:xpath, "#{dresses_xpath}/../ul//a[@title='Summer Dresses']").click # Summer Dresses
  end

  it 'displays summer dressees list' do
    assert_equal 3, find_all(:css, '.product_list li.ajax_block_product').size
  end

  it 'displays correct price' do
    assert_equal '$16.40', printed_chiffon_dress_price
  end
end
