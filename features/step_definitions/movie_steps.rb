Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create!(movie)
  end
end

Then /(.*) seed movies should exist/ do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  expect(page.body.index(e1)).to be < page.body.index(e2)
end

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(/,\s*/).each do |rating|
    uncheck ? uncheck("ratings_\#{rating}") : check("ratings_\#{rating}")
  end
end

Then /^I should (not )?see the following movies: (.*)$/ do |no, movie_list|
  movie_list.split(/,\s*/).each do |movie|
    if no
      expect(page).not_to have_content(movie)
    else
      expect(page).to have_content(movie)
    end
  end
end

Then /I should see all the movies/ do
  Movie.all.each do |movie|
    expect(page).to have_content(movie.title)
  end
end

Then /^debug$/ do
  require "byebug"; byebug
  1
end

Then /^debug javascript$/ do
  page.driver.debugger
  1
end

When('I uncheck all other checkboxes') do
  ['G', 'PG-13', 'NC-17'].each do |rating|
    if page.has_checked_field?("ratings_#{rating}")
      uncheck("ratings_#{rating}")
      log "Unchecked: ratings_#{rating}"
    end
  end
end

When('I check all checkboxes') do
  all("input[type=checkbox]").each { |checkbox| check(checkbox[:id]) }
end

When('I submit the search form') do
  click_button 'Refresh'
  save_and_open_page  # เช็ค HTML ของหน้าเว็บ
end


Then(/^I should see only movies with ratings:$/) do |table|
  expected_ratings = table.raw.flatten.reject { |r| r == "rating" } # เอาหัวข้อ table ออก
  actual_ratings = page.all('table#movies tbody tr td[2]').map(&:text)  # ดึงค่าจริงจากหน้าเว็บ

  # Debugging ด้วย log แทน puts
  log "Expected Ratings: #{expected_ratings}"
  log "Actual Ratings: #{actual_ratings}"

  expect(actual_ratings.uniq.sort).to match_array(expected_ratings.uniq.sort)
end

Then(/^I should see the movies sorted alphabetically$/) do
  movie_titles = page.all('table#movies tbody tr td[1]').map(&:text) # ดึงรายชื่อหนังจากตาราง
  expect(movie_titles).to eq movie_titles.sort # ตรวจสอบว่าเรียงตามตัวอักษรหรือไม่
end

Then(/^I should see the movies sorted by release date$/) do
  movie_dates = page.all('table#movies tbody tr td[3]').map(&:text) # คอลัมน์ที่ 3 คือ Release Date

  # แปลงวันที่จาก "YYYY-MM-DD HH:MM:SS UTC" เป็น "DD-MMM-YYYY"
  formatted_dates = movie_dates.map { |date| Date.parse(date).strftime('%d-%b-%Y') }

  # เรียงวันที่ที่ถูกต้อง
  sorted_dates = formatted_dates.sort_by { |d| Date.strptime(d, '%d-%b-%Y') }

  log "Actual Release Dates (Formatted): #{formatted_dates}"
  log "Expected Sorted Dates: #{sorted_dates}"

  expect(formatted_dates).to eq sorted_dates # ตรวจสอบว่าถูกเรียงตามวันที่ออกฉายจริง
end






