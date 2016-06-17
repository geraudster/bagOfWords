
# MFCC to Words
library(data.table)
library(plyr)
library(dplyr)
library(magrittr)
library(flexclust)

#' Extract left part of formula
#'
#' @import magrittr
#' @importFrom stats terms
getLeftTerms <- function(formula) {
  terms(formula) %>%
    attr('factors') %>%
    rownames() %>%
    first() %>%
    strsplit(' \\+ ') %>%
    unlist
}

#' Attach items to clusters
#'
#' @description This function fits a model and displays information about this model
#' @param dataset
#' @param clusters
#' @param formula
#' @param margins
#' @param keep
#' @param cols
#' @return a list
#' @export
#' @import data.table
#' @importFrom flexclust predict
#' @importFrom dplyr first
item2Words <- function(dataset, clusters, formula, margins, keep, cols = sapply(dataset, is.numeric)) {
  k <- clusters@k
  start <- length(getLeftTerms(formula)) + 1
  dataset$cluster <- if(is.data.table(dataset)) {
    predict(clusters, dataset[,cols, with = FALSE])
  } else {
    predict(clusters, dataset[,cols])
  }

  dataset.words <- as.data.frame(dcast(dataset, formula, length, margins = margins, value.var = 'cluster'))

  # dataset.wordsFreqs <- if(is.data.table(dataset)) {
  #   # chosenCols <- colnames(dataset.words)[start:(ncol(dataset.words)-1)]
  #   # dataset.wordsFreqs <- dataset.words[, prop.table(.SD), .SDcols=chosenCols, by = 1:nrow(dataset.words)]
  #   sumByRow <- rowSums(dataset.words[,start:ncol(dataset.words)])
  #   dataset.wordsFreqs <- dataset.words[, start:ncol(dataset.words), with=FALSE] / sumByRow
  #
  #   dataset.wordsFreqs <- cbind(dataset.wordsFreqs,
  #                               dataset.words[, keep, with=FALSE])
  #   colnames(dataset.wordsFreqs)[-c(1:k)] <- keep
  #
  #   # TODO: externalize dataset.wordsFreqs$class <- factor(dataset.wordsFreqs$class)
  #   subset(dataset.wordsFreqs, get(first(keep)) != '(all)')
  # } else {
    sumByRow <- rowSums(dataset.words[,start:ncol(dataset.words)])

    dataset.wordsFreqs <- dataset.words[, start:ncol(dataset.words)] / sumByRow

    dataset.wordsFreqs <- cbind(dataset.wordsFreqs[,-(k+1)], dataset.words[, keep])
    colnames(dataset.wordsFreqs)[-c(1:k)] <- keep

    # TODO: externalize dataset.wordsFreqs$class <- factor(dataset.wordsFreqs$class)
    subset(dataset.wordsFreqs, get(first(keep)) != '(all)')
  # }
}

#' Create dictionary
#'
#' @description This function fits a model and displays information about this model
#' @param dataset
#' @param cols
#' @param k
#' @return a list
#' @export
#' @importFrom flexclust cclust
#' @import data.table
#'
buildDictionary <- function(dataset, cols = sapply(dataset, is.numeric), k = 30) {
  if(is.data.table(dataset)) {
    cclust(dataset[, cols, with=FALSE], k, method = 'hardcl')
  } else {
    cclust(dataset[, cols], k, method = 'hardcl')
  }
}

#' Attach items to clusters
#'
#' @description This function fits a model and displays information about this model
#' @param dataset
#' @param formula
#' @param margins
#' @param keep
#' @return a list
#' @export
#'
bagOfWords <- function(dataset, k = 30, formula, margins, keep) {
  result <- list()
  result[['clusterTime']] <- system.time(
    result[['clusters']] <- buildDictionary(dataset, k = k)
  )
  result[['bow']] <- item2Words(dataset, result[['clusters']], formula, margins, keep)
  result
}
