#' @title Plot Diagnostics for an gllvm Object
#' @description Four plots (selectable by which) are currently available: a plot of residuals against
#' linear predictors of fitted values, a Normal Q-Q plot of residuals, residuals against row index and residuals against column index.
#'
#' @param x an object of class 'gllvm'.
#' @param which if a subset of the plots is required, specify a subset of the numbers 1:5, see caption below.
#' @param caption captions to appear above the plots.
#' @param var.colors colors for responses, vector with length of number of response variables or 1. Defaults to NULL, when different responses have different colors.
#' @param add.smooth	logical indicating if a smoother should be added.
#' @param envelopes logical, indicating if simulated point-wise confidence interval envelope will be added to Q-Q plot, defaults to \code{TRUE}
#' @param reps number of replications when simulating confidence envelopes for normal Q-Q plot
#' @param envelope.col colors for envelopes, vector with length of two
#' @param ...	additional graphical arguments.
#'
#' @details
#' plot.gllvm is used for model diagnostics. Dunn-Smyth residuals (randomized quantile residuals) (Dunn and Smyth, 1996) are used in plots. Colors indicate different species.
#'
#' @author Jenni Niku <jenni.m.e.niku@@jyu.fi>
#'
#' @references
#'
#' Dunn, P. K., and Smyth, G. K. (1996). Randomized quantile residuals. Journal of Computational and Graphical Statistics, 5, 236-244.
#'
#' Hui, F. K. C., Taskinen, S., Pledger, S., Foster, S. D., and Warton, D. I. (2015).  Model-based approaches to unconstrained ordination. Methods in Ecology and Evolution, 6:399-411.
#'
#'@seealso \code{\link{gllvm}}, \code{\link{residuals.gllvm}}
#' @examples
#'## Load a dataset from the mvabund package
#'data(antTraits)
#'y <- as.matrix(antTraits$abund)
#'# Fit gllvm model with Poisson family
#'fit <- gllvm(y, family = poisson())
#'# Plot residuals
#'plot(fit, mfrow = c(3,2))
#'
#' \donttest{
#'# Fit gllvm model with negative binomial family
#'fitnb <- gllvm(y = y, family = "negative.binomial")
#'# Plot residuals
#'plot(fitnb, mfrow = c(3,2))
#'# Plot only two first plots
#'plot(fitnb, which = 1:2, mfrow = c(1,2))
#'}
#'@export


plot.gllvm <- function(x, which = 1:5, caption=c("Residuals vs linear predictors", "Normal Q-Q","Residuals vs row index", "Residuals vs column index","Scale-Location"), var.colors = NULL, add.smooth = TRUE, envelopes = TRUE, reps = 150, envelope.col = c("blue","lightblue"), ...) {
  n <- NROW(x$y)
  p <- NCOL(x$y)

  mains <- rep("", 4)
  mains[which] <- caption[which]

  res <- residuals(x)
  ds.res <- res$residuals
  eta.mat <- res$linpred
  xxx <- boxplot(c(eta.mat), outline = FALSE,plot = FALSE)$stats

  csum = order(colSums(as.matrix(x$y)))
  if (!is.null(var.colors)) {
    col <- rep(1, p)
    col[1:p] <- (var.colors)
  } else
    if (p < 8)
      col <- (1:p)[csum]
  else
    col <- (grDevices::rainbow(p + 1)[2:(p + 1)])[csum]
  
  gr.pars <- list(...)
par(...)

    if(1 %in% which) {
      if(is.null(gr.pars$xlim)) {
        plot(eta.mat, ds.res, xlab = "linear predictors", ylab = "Dunn-Smyth-residuals",
             type = "n", col = rep(col, each = n), main = mains[1], xlim = c(min(xxx), max(xxx))); abline(0, 0, col = "grey", lty = 3)
      } else {
        plot(eta.mat, ds.res, xlab = "linear predictors", ylab = "Dunn-Smyth-residuals", type =
               "n", col = rep(col, each = n), main = mains[1], ...); abline(0, 0, col = "grey", lty = 3)
        }

      if(add.smooth) gamEnvelope(eta.mat, ds.res, col = rep(col, each = n), envelopes = envelopes, envelope.col = envelope.col, ...)
#      panel(eta.mat, ds.res, col = rep(col, each = n), cex = 1, cex.lab = 1, cex.axis = 1, lwd = 1)
    }
    if(2 %in% which) {
      qq.x<-qqnorm(c(ds.res), main = mains[2], ylab = "Dunn-Smyth residuals", col = rep(col, each = n), cex = 0.5);
      qqline(c(res$residuals), col = envelope.col[1])
      if(envelopes){
        K <- reps
        yy <- quantile(ds.res, c(0.25, 0.75), names = FALSE, type = 7, na.rm = TRUE)
        xx <- qnorm(c(0.25, 0.75))
        slope <- diff(yy) / diff(xx)
        int <- yy[1L] - slope * xx[1L]
        Xm <- Ym <- NULL
        for (i in 1:K) {
          ri <- (rnorm(n * p, int, sd = slope))
          Ym <- cbind(Ym, sort(ri))
        }
        Xm <- sort(qq.x$x)
        cis <- apply(Ym, 1, quantile, probs = c(0.025, 0.975))

        n.obs <- n*p
        polygon(Xm[c(1:n.obs,n.obs:1)], c(cis[1, ],cis[2, n.obs:1]), col = envelope.col[2], border = NA)
        points(qq.x, col = rep(col, each = n), cex = 0.5)
        qqline(c(res$residuals), col = envelope.col[1])
      }
      }
    if(3 %in% which) {
      plot(rep(1:n, p), ds.res, xlab = "site.index", ylab = "Dunn-Smyth-residuals", col =
             rep(col, each = n), main = mains[3], ...);
      abline(0, 0, col = "grey", lty = 3)
      if(add.smooth) panel.smooth(rep(1:n, p), ds.res, col = rep(col, each = n), col.smooth = envelope.col[1],...)
      #panel(rep(1:n, p), ds.res, col = rep(col, each = n), cex = 1, cex.lab = 1, cex.axis = 1, lwd = 1)
    }
    if(4 %in% which) {
      plot(rep(1:p, each = n), ds.res, xlab = "spp.index", ylab = "Dunn-Smyth-residuals", col =
             rep(col[csum], each = n), main = mains[4], ...);  abline(0, 0, col = "grey", lty = 3)
      if(add.smooth) panel.smooth(rep(1:p, each = n), ds.res, col = rep(col[csum], each = n), col.smooth = envelope.col[1], ...)
      #panel(rep(1:p, each = n), ds.res, col = rep(col[csum], each = n), cex = 1, cex.lab = 1, cex.axis = 1, lwd = 1)
    }
    if(5 %in% which) {
      sqres <- sqrt(abs(ds.res))
      yl <- as.expression(substitute(sqrt(abs(YL)), list(YL = as.name("Dunn-Smyth-residuals"))))
      if(is.null(gr.pars$xlim)) {
        plot(eta.mat, sqres, xlab = "linear predictors", ylab = yl, col = rep(col, each = n),
             main = mains[5], xlim = c(min(xxx), max(xxx)), ...);
      } else {
        plot(eta.mat, sqres, xlab = "linear predictors", ylab = yl, col = rep(col, each = n), main = mains[5], ...);
      }
      if(add.smooth) panel.smooth(eta.mat, sqres, col = rep(col, each = n), col.smooth = envelope.col[1], ...)
      #panel(eta.mat, sqres, col = rep(col, each = n), cex = 1, cex.lab = 1, cex.axis = 1, lwd = 1)
  }

}
