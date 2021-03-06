#' @title Summarizing gllvm model fits
#' @description A summary of the fitted 'gllvm' object, including function call, distribution family and model parameters.
#'
#' @param object   an object of class 'gllvm'
#' @param ...	not used.
#'
#' @author Jenni Niku <jenni.m.e.niku@@jyu.fi>
#'
#' @examples
#'## Load a dataset from the mvabund package
#' data(antTraits)
#' y <- as.matrix(antTraits$abund)
#'# Fit gllvm model
#' fit <- gllvm(y = y, family = poisson())
#' summary(fit)
#'
#'@export

summary.gllvm <- function(object, ...) {
  n <- NROW(object$y)
  p <- NCOL(object$y)
  nX <- dim(object$X)[2]
  nTR <- dim(object$TR)[2]
  num.lv <- object$num.lv
  family <- object$family

  M <- cbind(object$params$beta0, object$params$theta)
  sumry <- list()
  sumry$'log-likelihood' <- object$logL
  crit <- inf.criteria(object)
  sumry$df <- crit$k
  sumry$AIC <- crit$AIC
  sumry$AICc <- crit$AICc
  sumry$BIC <- crit$BIC

  crit <-
    newnams <- c("Intercept")

  if (num.lv > 0)
    newnams <- c(newnams, paste("theta.LV", 1:num.lv, sep = ""))
  colnames(M) <- newnams
  rownames(M) <- colnames(object$y)
  sumry$Call <- object$call
  sumry$family <- object$family
  sumry$Coefficients <- M

  if (!is.null(object$TR)) {
    if (!is.null(object$X)) {
      sumry$'Covariate coefficients' <- object$params$B
    }
  } else {
    if (!is.null(object$X)) {
      sumry$'Environmental coefficients' <- object$params$Xcoef
    }
  }
  if (!is.null(object$params$row.params)) {
    sumry$'Row intercepts' <- object$params$row.params
  }

  if (object$row.eff == "random") {
    object$params$sigma2 = object$params$sigma ^ 2
    names(object$params$sigma2) = "sigma^2"
    sumry$'Variance of random row intercepts' <- object$params$sigma2
  }

  if (object$family == "negative.binomial") {
    sumry$'Dispersion parameters' <- object$params$phi
  }
  if (object$family == "tweedie") {
    sumry$'Dispersion parameters' <- object$params$phi
  }
  if (object$family == "ZIP") {
    sumry$'Zero inflation p' <- object$params$phi
  }
  class(sumry) <- "summary.gllvm"
  return(sumry)
}
