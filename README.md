# [clumpir](https://github.com/gomoshy/clumpir)

## Title
**Calculate Clumpiness per Group**

## Description
Computes a clumpiness score for each group (e.g., user) based on a sequence of time points.  
The score reflects how concentrated or bursty the events are within a fixed time window.

## Usage

```r
clumpir(data, id, t, N)
```

## Arguments

| Argument | Description |
|----------|-------------|
| `data`   | A `data.frame` containing at least the grouping and time columns. |
| `id`     | A character string indicating the name of the grouping column (e.g., `"user_id"`). |
| `t`      | A character string indicating the name of the time column (e.g., `"t"`). |
| `N`      | A positive integer specifying the total observation window (e.g., `20`). |


## Value

A `data.frame` with one row per group and two columns:

- The group identifier (as specified by `id`)
- `clumpiness`: the computed clumpiness score

## Examples

```r
# Example: Event times for each user are created separately

user1 <- data.frame(
  user_id = 1,
  t = c(3, 4, 9, 10, 15)
)

user2 <- data.frame(
  user_id = 2,
  t = c(5, 7, 9, 10, 11)
)

# Combine into a single dataset
df <- rbind(user1, user2)

# Compute clumpiness per user
clumpir(df, id = "user_id", t = "t", N = 20)
```
