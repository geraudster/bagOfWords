#install.packages('testthat')
library(testthat)
library(data.table)
library(plyr)
library(dplyr)
library(magrittr)
library(flexclust)


test_that('Should build a dictionary from iris', {
    irisDict <- buildDictionary(iris, k=3)
    expect_equal(nrow(irisDict@centers), 3)
})

test_that('Should translate iris dataset to words', {
    load('../data/cluster_iris_tests.RData')
    irisWords <- item2Words(iris,
                            cluster_iris_tests,
                            Species ~ cluster,
                            margins = c('cluster'),
                            keep = c('Species'))
    expect_equal(dim(irisWords), c(3,4))
})

test_that('Should translate iris dataset to words without "(all)"', {
    load('../data/cluster_iris_tests.RData')
    irisModified <- iris
    irisModified$id <- 1
    irisModified[irisModified$Species == 'setosa',]$id <- 1:5
    irisModified[irisModified$Species == 'versicolor',]$id <- 6:10
    irisModified[irisModified$Species == 'virginica',]$id <- 11:15
    irisWords <- item2Words(irisModified[,c(6,1:5)],
                            cluster_iris_tests,
                            id + Species ~ cluster,
                            margins = c('id', 'cluster'),
                            keep = c('Species', 'id'),
                            cols = c('Sepal.Length', 'Sepal.Width', 'Petal.Length', 'Petal.Width'))
    expect_equal(dim(irisWords), c(15,5))
})

test_that('Should create a BoW for iris dataset', {
    load('../data/cluster_iris_tests.RData')
    load('../data/irisWords.RData')
    with_mock(
        buildDictionary = function(dataset, cols = sapply(dataset, is.numeric), k = 30) {
            print('Mocked buildDictionary')
            cluster_iris_tests
        },
        item2Words = function(dataset, clusters, formula, margins, keep) {
            print('Mocked item2Words')
            expect_true(!is.null(dataset))
            expect_true(!is.null(clusters))
            expect_true(!is.null(formula))
            expect_true(!is.null(margins))
            expect_true(!is.null(keep))
            irisWords
        },
        boW <- bagOfWords(iris,
                          3,
                          Species ~ cluster,
                          margins = c('cluster'),
                          keep = c('Species')),
        expect_length(boW, 3))
})

test_that('Should translate iris data.table to words', {
    load('../data/cluster_iris_tests.RData')
    irisWords <- item2Words(data.table(iris),
                            cluster_iris_tests,
                            Species ~ cluster,
                            margins = c('cluster'),
                            keep = c('Species'))
    expect_equal(dim(irisWords), c(3,4))
})
# test_that('Should run on iris dataset', {
#   expect_length(bagOfWords(iris), 3)})
