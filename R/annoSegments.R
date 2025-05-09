#' Annotates a line segment within a plot
#' 
#' @usage annoSegments(
#'     x0,
#'     y0,
#'     x1,
#'     y1,
#'     plot,
#'     default.units = "native",
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
#' @param x0 A numeric vector or unit object indicating the starting
#' x-values of the line segments.
#' @param y0 A numeric vector or unit object indicating the starting
#' y-values of the line segments.
#' @param x1 A numeric vector or unit object indicating the stopping
#' x-values of the line segments.
#' @param y1 A numeric vector or unit object indicating the stopping
#' y-values of the line segments.
#' @param plot Input plotlandscaper plot to internally plot line segments
#' relative to.
#' @param default.units A string indicating the default units to use
#' if \code{x0}, \code{y0}, \code{x1}, or \code{y1} are only given
#' as numeric vectors. Default value is \code{default.units = "native"}.
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
#' @param arrow A list describing arrow heads to place at either
#' end of the line segments, as produced by the \link[grid]{arrow} function.
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
#' pageCreate(width = 7.5, height = 2.5, default.units = "inches")
#'
#' ## Plot a Manhattan plot
#' library(plotgardenerData)
#' library("TxDb.Hsapiens.UCSC.hg19.knownGene")
#' data("hg19_insulin_GWAS")
#' manhattanPlot <- plotManhattan(
#'     data = hg19_insulin_GWAS, assembly = "hg19",
#'     fill = c("grey", "#37a7db"),
#'     sigLine = TRUE,
#'     col = "grey", lty = 2, range = c(0, 14),
#'     x = 0.5, y = 0, width = 6.5, height = 2,
#'     just = c("left", "top"),
#'     default.units = "inches"
#' )
#'
#' ## Annotate genome label
#' annoGenomeLabel(
#'     plot = manhattanPlot, x = 0.5, y = 2, fontsize = 8,
#'     just = c("left", "top"),
#'     default.units = "inches"
#' )
#' plotText(
#'     label = "Chromosome", fontsize = 8,
#'     x = 3.75, y = 2.20, just = "center", default.units = "inches"
#' )
#'
#' ## Annotate y-axis
#' annoYaxis(
#'     plot = manhattanPlot, at = c(0, 2, 4, 6, 8, 10, 12, 14),
#'     axisLine = TRUE, fontsize = 8
#' )
#'
#' ## Annotate a line segment for an additional significance line of
#' ## the Manhattan plot
#' annoSegments(
#'     x0 = unit(0, "npc"), y0 = 10,
#'     x1 = unit(1, "npc"), y1 = 10,
#'     plot = manhattanPlot, default.units = "native",
#'     linecolor = "red", lty = 2
#' )
#'
#' ## Plot y-axis label
#' plotText(
#'     label = "-log10(p-value)", x = 0.15, y = 1, rot = 90,
#'     fontsize = 8, fontface = "bold", just = "center",
#'     default.units = "inches"
#' )
#'
#' ## Hide page guides
#' pageGuideHide()
#' @seealso \link[grid]{grid.segments}, \link[grid]{arrow}
#' @export
annoSegments <- function(x0, y0, x1, y1, plot, default.units = "native",
                            linecolor = "black", lwd = 1, lty = 1,
                            lineend = "butt", linejoin = "mitre",
                            coords = FALSE, 
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

    check_page(error = "Cannot annotate segment without a `plotlandscaper` page.")
    if (is.null(segmentsInternal$plot)) {
        stop("argument \"plot\" is missing, with no default.",
            call. = FALSE
        )
    }
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
    
    convert_page <- function(object) {
        
        ## Get page_height and its units from pgEnv
        page_height <- get("page_height", envir = pgEnv)
        page_units <- get("page_units", envir = pgEnv)
        
        ## Convert x and y coordinates and height and width to same page_units
        old_x0 <- object$x0
        # old_y <- object$y
        old_height <- object$height
        old_width <- object$width
        new_x0 <- convertX(old_x0, unitTo = page_units)
        # new_y <- convertY(unit(page_height,
        #                        units = page_units
        # ) - convertY(old_y,
        #              unitTo = page_units
        # ),
        # unitTo = page_units
        # )
        new_height <- convertHeight(old_height, unitTo = page_units)
        new_width <- convertWidth(old_width, unitTo = page_units)
        
        object$x0 <- new_x0
        object$x1 = new_x1
        # object$y <- new_y
        object$height <- new_height
        object$width <- new_width
        
        
        return(object)
    }
    
    if (segmentsInternal$coords == TRUE){
        segments = convert_page(segments)
    }

    ## Get page_height and its units from pgEnv through pageCreate
    page_height <- get("page_height", envir = pgEnv)
    page_units <- get("page_units", envir = pgEnv)
    
    segments$x0 <- misc_defaultUnits(value = segments$x0,
                                        name = "x0",
                                        default.units = 
                                            segmentsInternal$default.units)
    segments$y0 <- misc_defaultUnits(value = segments$y0,
                                        name = "y0",
                                        default.units = 
                                            segmentsInternal$default.units,
                                        funName = "annoSegments",
                                        yBelow = FALSE)
    segments$x1 <- misc_defaultUnits(value = segments$x1,
                                        name = "x1",
                                        default.units = 
                                            segmentsInternal$default.units)
    segments$y1 <- misc_defaultUnits(value = segments$y1,
                                        name = "y1",
                                        default.units = 
                                            segmentsInternal$default.units,
                                        funName = "annoSegments",
                                        yBelow = FALSE)
    
    ## Get appropriate plot viewport
    plotVP <- getAnnoViewport(plot = segmentsInternal$plot)

    ## Convert plot viewport to bottom left to get position on entire page
    plotVP_bottomLeft <- vp_bottomLeft(viewport = plotVP)

    ## Push plot viewport to convert x/y from plot native units to page units
    seekViewport(plotVP$name)
    new_x0 <- convertX(segments$x0, unitTo = page_units, valueOnly = TRUE)
    new_x1 <- convertX(segments$x1, unitTo = page_units, valueOnly = TRUE)
    new_y0 <- convertY(segments$y0, unitTo = page_units, valueOnly = TRUE)
    new_y1 <- convertY(segments$y1, unitTo = page_units, valueOnly = TRUE)

    seekViewport(name = "page")

    ## Add additional page units to new_x0, new_x1, new_y0, and new_y1
    new_x0 <- as.numeric(plotVP_bottomLeft[[1]]) + new_x0
    new_x1 <- as.numeric(plotVP_bottomLeft[[1]]) + new_x1
    new_y0 <- as.numeric(plotVP_bottomLeft[[2]]) + new_y0
    new_y1 <- as.numeric(plotVP_bottomLeft[[2]]) + new_y1

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
        y0 = unit(new_y0, page_units),
        x1 = unit(new_x1, page_units),
        y1 = unit(new_y1, page_units),
        arrow = segments$arrow, gp = segments$gp,
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
