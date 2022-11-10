# frozen_string_literal: true

require 'minitest_cuprite'
minitest_cuprite "headless": true

def with_class(klass)
  "[contains(concat(' ', normalize-space(@class), ' '), #{klass})]"
end

describe :test do
  let(:printed_chiffon_dress_price) do
    find(:css, '.product_list')
      .find(:xpath, "//*[contains(text(), 'Printed Chiffon Dress')]/ancestor::li\
                     //*#{with_class('content_price')}/*[@itemprop='price']")
      .text
  end

  before do
    visit 'http://localhost:4567/index.php'
    find(:xpath, "//*#{with_class('menu-content')}//a[@title='Dresses']").hover # Dresses
    find(:xpath, "//*#{with_class('menu-content')}//*[@title='Summer Dresses']").click
  end

  it 'displays summer dressees list' do
    assert_equal 3, find_all(:css, '.product_list li.ajax_block_product').size
  end

  it 'displays correct price' do
    assert_equal '$16.40', printed_chiffon_dress_price
  end
end
