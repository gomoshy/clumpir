#' Calculate Clumpiness per Group
#'
#' Computes a clumpiness score for each group (e.g., user) based on a sequence of time points.
#' The score reflects how concentrated or bursty the events are within a fixed time window.
#'
#' @param data A data.frame containing at least the grouping and time columns.
#' @param id A string indicating the name of the grouping column (e.g., user ID).
#' @param t A string indicating the name of the time column (e.g., timestamp).
#' @param N A positive integer indicating the total observation window (e.g., maximum time).
#'
#' @return A data.frame with one row per group and the following columns:
#' \itemize{
#'   \item \code{id} (the group identifier)
#'   \item \code{clumpiness} (the computed clumpiness score)
#' }
#'
#' @examples
#' # Example: Event times for each user are created separately
#'
#' user1 <- data.frame(
#'   user_id = 1,
#'   t = c(3, 4, 9, 10, 15)
#' )
#'
#' user2 <- data.frame(
#'   user_id = 2,
#'   t = c(5, 7, 9, 10, 11)
#' )
#'
#' # Combine into a single dataset
#' df <- rbind(user1, user2)
#'
#' # Compute clumpiness per user
#' clumpir(df, id = "user_id", t = "t", N = 20)
#'
#' @export
clumpir <- function(data, id, t, N) {
  # --- Input validation ---
  if (!is.data.frame(data)) {
    stop("'data' must be a data.frame.")
  }
  if (!(id %in% names(data))) {
    stop(paste0("Column '", id, "' not found in data."))
  }
  if (!(t %in% names(data))) {
    stop(paste0("Column '", t, "' not found in data."))
  }
  if (!is.numeric(N) || length(N) != 1 || N <= 0 || N != as.integer(N)) {
    stop("'N' must be a positive integer.")
  }

  # --- Main computation ---
  df <- data

  df$diff_t <- ave(df[[t]], df[[id]], FUN = function(x) c(NA, diff(x)))
  df$idx <- ave(df[[t]], df[[id]], FUN = seq_along)
  df$max_idx <- ave(df$idx, df[[id]], FUN = max)

  is_last <- df$idx == df$max_idx
  df_add <- df[is_last, , drop = FALSE]

  df$x <- ifelse(df$idx == 1, df[[t]] / (N + 1), df$diff_t / (N + 1))
  df_add$x <- (N + 1 - df_add[[t]]) / (N + 1)

  df_all <- rbind(df, df_add)

  result <- aggregate(
    df_all$x,
    by = list(df_all[[id]]),
    FUN = function(x) 1 + sum(log(x) * x) / log(length(x))
  )

  colnames(result) <- c(id, "clumpiness")
  return(result)
}
