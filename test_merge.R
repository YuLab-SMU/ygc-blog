sclet_modify_list <- function(x, val) {
    stopifnot(is.list(x), is.list(val))
    xnames <- names(x)
    vnames <- names(val)
    vnames <- vnames[nzchar(vnames)]
    for (v in vnames) {
        xv <- x[[v]]
        vv <- val[[v]]
        # Only recurse if both are plain lists
        if (is.list(xv) && is.list(vv) && 
            (is.null(class(xv)) || identical(class(xv), "list")) &&
            (is.null(class(vv)) || identical(class(vv), "list"))) {
            x[[v]] <- sclet_modify_list(xv, vv)
        } else {
            x[[v]] <- vv
        }
    }
    x
}

l1 <- list(a = 1, b = structure(list(c=1), class="myclass"))
l2 <- list(a = 2, b = structure(list(d=2), class="myclass"))
print(sclet_modify_list(l1, l2))
