def expect_rows(count)
  expect(page).to have_selector('tbody tr[role="row"]', :count => count)
end

def first_row
  first('tbody tr[role="row"]')
end
