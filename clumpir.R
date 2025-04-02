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
