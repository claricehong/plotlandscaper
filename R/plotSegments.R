#' Draw a line segment within a plotlandscaper layout
#' 
#' @usage plotSegments(
#'     x0,
#'     y0,
#'     x1,
#'     y1,
#'     default.units = "inches",
#'     linecolor = "black",
#'     lwd = 1,
#'     lty = 1,
#'     lineend = "butt",
#'     linejoin = "mitre",
#'     arrow = NULL,
#'     params = NULL,
#'     ...
#' )
#'
#' @param x0 A numeric vector or unit object indicating the
#' starting x-values of the line segments.
#' @param y0 A numeric vector, unit object, or a character vector
#' of values containing a "b" combined with a numeric value specifying
#' starting y-values of the line segments.
#' The character vector will place starting y-values relative to the
#' bottom of the most recently plotted plot according to the
#' units of the plotlandscaper page.
#' @param x1 A numeric vector or unit object indicating the stopping
#' x-values of the line segments.
#' @param y1 A numeric vector, unit object, or a character vector of v
#' alues containing a "b" combined with a numeric value specifying
#' stopping y-values of the line segments.
#' The character vector will place stopping y-values relative to the
#' bottom of the most recently plotted plot according to the
#' units of the plotlandscaper page.
#' @param default.units A string indicating the default units to use
#' if \code{x0}, \code{y0}, \code{x1}, or \code{y1} are only given as
#' numeric vectors. Default value is \code{default.units = "inches"}.
#' @param linecolor A character value specifying segment line color.
#' Default value is \code{linecolor = "black"}.
#' @param lwd A numeric specifying segment line width.
#' Default value is \code{lwd = 1}.
#' @param lty A numeric specifying segment line type.
#' Default value is \code{lty = 1}.
#' @param lineend A character value specifying line end style.
#' Default value is \code{lineend = "butt"}. Options are:
#' \itemize{
#' \item{\code{"round"}: Segment ends are rounded.}
#' \item{\code{"butt"}: Segment ends end exactly where ended.}
#' \item{\code{"square"}: Segment ends are squared.}
#' }
#' @param linejoin A character value specifying line join style.
#' Default value is \code{linejoin = "mitre"}. Options are:
#' \itemize{
#' \item{\code{"round"}: }{Line joins are rounded.}
#' \item{\code{"mitre"}: }{Line joins are sharp corners.}
#' \item{\code{"bevel"}: }{Line joins are flattened corners.}
#' }
#' @param arrow A list describing arrow heads to place at either end of
#' the line segments, as produced by the \link[grid]{arrow} function.
#' @param params An optional \link[plotlandscaper]{pgParams} object containing
#' relevant function parameters.
#' @param ... Additional grid graphical parameters. See \link[grid]{gpar}.
#'
#' @return Returns a \code{segments} object containing relevant
#' placement and \link[grid]{grob} information.
#'
#' @examples
#' library(grid)
#' ## Create a page
#' pageCreate(width = 7.5, height = 6, default.units = "inches")
#'
#' ## Plot one line segment
#' plotSegments(
#'     x0 = 3.75, y0 = 0.25, x1 = 3.75, y1 = 5.75,
#'     default.units = "inches",
#'     lwd = 3, lty = 2
#' )
#'
#' ## Plot multiple line segments at different locations in different colors
#' plotSegments(
#'     x0 = 0.5, y0 = c(1, 3, 5), x1 = 3.25, y1 = c(1, 3, 5),
#'     default.units = "inches",
#'     lwd = 2, linecolor = c("#7ecdbb", "#37a7db", "grey")
#' )
#'
#' ## Plot a line segment with an arrowhead
#' plotSegments(
#'     x0 = 4.5, y0 = 0.5, x1 = 7, y1 = 3,
#'     default.units = "inches",
#'     arrow = arrow(type = "closed"), fill = "black"
#' )
#'
#' ## Plot lines with round lineends
#' plotSegments(
#'     x0 = c(4, 7), y0 = 3.5, x1 = 5.5, y1 = 4.5,
#'     default.units = "inches",
#'     lwd = 5, lineend = "round"
#' )
#'
#' ## Hide page guides
#' pageGuideHide()
#' @seealso \link[grid]{grid.segments}, \link[grid]{arrow}
#'
#' @export
plotSegments <- function(x0, y0, x1, y1, default.units = "inches",
                            linecolor = "black", lwd = 1, lty = 1,
                            lineend = "butt", linejoin = "mitre",
                            arrow = NULL, params = NULL, ...) {


    # =========================================================================
    # PARSE PARAMETERS
    # =========================================================================

    segmentsInternal <- parseParams(
        params = params,
        defaultArgs = formals(eval(match.call()[[1]])),
        declaredArgs = lapply(match.call()[-1], eval.parent, n = 2),
        class = "segmentsInternal"
    )

    ## Set gp
    segmentsInternal$gp <- gpar(
        col = segmentsInternal$linecolor,
        lwd = segmentsInternal$lwd,
        lty = segmentsInternal$lty,
        lineend = segmentsInternal$lineend,
        linejoin = segmentsInternal$linejoin
    )
    segmentsInternal$gp <- setGP(
        gpList = segmentsInternal$gp,
        params = segmentsInternal, ...
    )

    # =========================================================================
    # INITIALIZE OBJECT
    # =========================================================================

    segments <- structure(list(
        x0 = segmentsInternal$x0,
        y0 = segmentsInternal$y0,
        x1 = segmentsInternal$x1,
        y1 = segmentsInternal$y1,
        arrow = segmentsInternal$arrow,
        grobs = NULL,
        gp = segmentsInternal$gp
    ),
    class = "segmentsInternal"
    )

    # =========================================================================
    # CATCH ERRORS
    # =========================================================================

    check_page(error = "Cannot plot segment without a plotlandscaper page.")
    if (is.null(segments$x0)) stop("argument \"x0\" is missing, ",
                                    "with no default.", call. = FALSE)
    if (is.null(segments$y0)) stop("argument \"y0\" is missing, ",
                                    "with no default.", call. = FALSE)
    if (is.null(segments$x1)) stop("argument \"x1\" is missing, ",
                                    "with no default.", call. = FALSE)
    if (is.null(segments$y1)) stop("argument \"y1\" is missing, ",
                                    "with no default.", call. = FALSE)

    # =========================================================================
    # DEFINE PARAMETERS
    # =========================================================================

    ## Get page_height and its units from pgEnv
    page_height <- get("page_height", envir = pgEnv)
    page_units <- get("page_units", envir = pgEnv)
    
    
    segments$x0 <- misc_defaultUnits(
        value = segments$x0,
        name = "x0",
        default.units = segmentsInternal$default.units
    )
    
    segments$y0 <- misc_defaultUnits(
        value = segments$y0,
        name = "y0",
        default.units = segmentsInternal$default.units
    )
    
    segments$x1 <- misc_defaultUnits(
        value = segments$x1,
        name = "x1",
        default.units = segmentsInternal$default.units
    )

    segments$y1 <- misc_defaultUnits(
        value = segments$y1,
        name = "y1",
        default.units = segmentsInternal$default.units
    )

    ## Convert coordinates to page_units
    new_x0 <- convertX(segments$x0, unitTo = page_units, valueOnly = TRUE)
    new_y0 <- convertY(segments$y0, unitTo = page_units, valueOnly = TRUE)
    new_x1 <- convertX(segments$x1, unitTo = page_units, valueOnly = TRUE)
    new_y1 <- convertY(segments$y1, unitTo = page_units, valueOnly = TRUE)

    # =========================================================================
    # MAKE GROB
    # =========================================================================
    name <- paste0(
        "segments",
        length(grep(
            pattern = "segments",
            x = grid.ls(
                print = FALSE,
                recursive = FALSE
            )
        )) + 1
    )
    segments <- grid.segments(
        x0 = unit(new_x0, page_units),
        y0 = unit(page_height - new_y0, page_units),
        x1 = unit(new_x1, page_units),
        y1 = unit(page_height - new_y1, page_units),
        arrow = segments$arrow,
        gp = segments$gp,
        name = name
    )

    # =========================================================================
    # ADD GROB TO OBJECT
    # =========================================================================

    segments$grobs <- segments

    # =========================================================================
    # RETURN OBJECT
    # =========================================================================

    message("segments[", segments$name, "]")
    invisible(segments)
}
