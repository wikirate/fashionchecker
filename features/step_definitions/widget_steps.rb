Given("I go to the widget") do
  visit "/"
end

When("I search for name {string}") do |string|
  search_for_name_or_address string
end

When("I search for address {string}") do |string|
  search_for_name_or_address string
end

When("I search for country {string}") do |string|
  search_for_country string
end

def search_for_name_or_address value
  fill_in "keyword-input", with: value
  find('#keyword-input').native.send_keys(:return)
end

Then("I should see {string} in the factory list") do |text|
  within "#search-result-accordion" do
    expect(page).to have_content(text)
  end
end

And("I should not see {string} in the factory list") do |text|
  within "#search-result-accordion" do
    expect(page).not_to have_content(text)
  end
end

Then("I should see that it supplied {string} in {string}") do |company, year|
  expect(page).to have_content company
  expect(page).to have_content year
end

When("I open {string}") do |string|
  click_link string
end

def search_for_country(value)
  find("#country-select + .select2-container").click
  list = find(:xpath, '//span[@class="select2-results"]', visible: :all)
  list.find(:css, "ul > li > ul >li.select2-results__option", text: value, visible: :all).click
end
