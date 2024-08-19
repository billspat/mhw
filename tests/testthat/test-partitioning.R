test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("partioning works", {
  decade_partitions = create_partion_table(partition_size_years = 10, start_year = 2040, end_year = 2069)
  expect_equal(c(2040, 2050, 2060), decade_partitions$partition)
  
})