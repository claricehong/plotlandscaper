#' Plot a triangular Hi-C interaction matrix in a rectangular format
#' 
#' @usage plotHicRectangle(
#'     data,
#'     resolution = "auto",
#'     zrange = NULL,
#'     norm = "KR",
#'     matrix = "observed",
#'     chrom,
#'     chromstart = NULL,
#'     chromend = NULL,
#'     assembly = "hg38",
#'     palette = colorRampPalette(brewer.pal(n = 9, "YlGnBu")),
#'     colorTrans = "linear",
#'     flip = FALSE,
#'     bg = NA,
#'     x = NULL,
#'     y = NULL,
#'     width = NULL,
#'     height = NULL,
#'     just = c("left", "top"),
#'     default.units = "inches",
#'     draw = TRUE,
#'     params = NULL,
#'     quiet = FALSE
#' )
#'
#' @param data Path to .hic or .(m)cool file as a string or a 3-column 
#' dataframe of interaction counts in sparse upper triangular format.
#' @param resolution A numeric specifying the width in basepairs
#' of each pixel. For files, "auto" will attempt to choose a
#' resolution based on the size of the region. For
#' dataframes, "auto" will attempt to detect the resolution the
#' dataframe contains.
#' @param zrange A numeric vector of length 2 specifying the range of
#' interaction scores to plot, where extreme values will be set to the
#' max or min.
#' @param norm Character value specifying hic data normalization method,
#' if giving .hic or .(m)cool file. This value must be found in the .hic 
#' or .(m)cool file.
#' Default value is \code{norm = "KR"}.
#' @param matrix Character value indicating the type of matrix to output for 
#' .hic files.
#' Default value is \code{matrix = "observed"}. Options are:
#' \itemize{
#' \item{\code{"observed"}: }{Observed counts.}
#' \item{\code{"oe"}: }{Observed/expected counts.}
#' \item{\code{"log2oe"}: }{Log2 transformed observed/expected counts.}
#' }
#' @param chrom Chromosome of region to be plotted, as a string.
#' @param chromstart Integer start position on chromosome to be plotted.
#' @param chromend Integer end position on chromosome to be plotted.
#' @param assembly Default genome assembly as a string or a
#' \link[plotlandscaper]{assembly} object.
#' Default value is \code{assembly = "hg38"}.
#' @param palette A function describing the color palette to use for
#' representing scale of interaction scores. Default value is
#' \code{palette =  colorRampPalette(brewer.pal(n = 9, "YlGnBu"))}.
#' @param colorTrans A string specifying how to scale Hi-C colors.
#' Options are "linear", "log", "log2", or "log10".
#' Default value is \code{colorTrans = "linear"}.
#' @param flip A logical indicating whether to flip the orientation of
#' the Hi-C matrix over the x-axis. Default value is \code{flip = FALSE}.
#' @param bg Character value indicating background color.
#' Default value is \code{bg = NA}.
#' @param x A numeric or unit object specifying rectangle
#' Hi-C plot x-location.
#' @param y A numeric, unit object, or character containing a "b" combined
#' with a numeric value specifying rectangle Hi-C plot y-location.
#' The character value will
#' place the rectangle Hi-C plot y relative to the bottom of the most
#' recently plotted plot according to the units of the plotlandscaper page.
#' @param width A numeric or unit object specifying the width of the
#' Hi-C plot rectangle.
#' @param height A numeric or unit object specifying the height of the
#' Hi-C plot rectangle.
#' @param just Justification of rectangle Hi-C plot relative to
#' its (x, y) location. If there are two values, the first value
#' specifies horizontal justification and the second value specifies
#' vertical justification.
#' Possible string values are: \code{"left"}, \code{"right"},
#' \code{"centre"}, \code{"center"}, \code{"bottom"}, and \code{"top"}.
#' Default value is \code{just = c("left", "top")}.
#' @param default.units A string indicating the default units to use
#' if \code{x}, \code{y}, \code{width}, or \code{height} are only given
#' as numerics. Default value is \code{default.units = "inches"}.
#' @param draw A logical value indicating whether graphics output should
#' be produced. Default value is \code{draw = TRUE}.
#' @param params An optional \link[plotlandscaper]{pgParams} object containing
#' relevant function parameters.
#' @param quiet A logical indicating whether or not to print messages.
#'
#' @return Returns a \code{hicRectangle} object containing
#' relevant genomic region, Hi-C data, placement,
#' and \link[grid]{grob} information.
#'
#' @examples
#' ## Load Hi-C data
#' library(plotgardenerData)
#' data("IMR90_HiC_10kb")
#'
#' ## Create a page
#' pageCreate(width = 6, height = 3.5, default.units = "inches")
#'
#' ## Plot and place rectangle Hi-C plot
#' hicPlot <- plotHicRectangle(
#'     data = IMR90_HiC_10kb, resolution = 10000,
#'     zrange = c(0, 70),
#'     chrom = "chr21",
#'     chromstart = 28950000, chromend = 29800000,
#'     assembly = "hg19",
#'     x = 0.5, y = 0.5, width = 5, height = 2.5,
#'     just = c("left", "top"),
#'     default.units = "inches"
#' )
#'
#' ## Annotate x-axis genome label
#' annoGenomeLabel(
#'     plot = hicPlot, scale = "Kb", x = 0.5, y = 3.03,
#'     just = c("left", "top")
#' )
#'
#' ## Annotate heatmap legend
#' annoHeatmapLegend(
#'     plot = hicPlot, x = 5.6, y = 0.5,
#'     width = 0.13, height = 1.5,
#'     just = c("left", "top")
#' )
#'
#' ## Hide page guides
#' pageGuideHide()
#' @details
#' This function is similar is \link[plotlandscaper]{plotHicTriangle} but
#' will fill in additional pixels around the
#' the triangular portion of the plot to make a rectangle. The x-axis
#' represents the genomic coordinates and the y-axis corresponds to distance in
#' Hi-C bins.
#'
#' A rectangle Hi-C plot can be placed on a plotlandscaper coordinate
#' page by providing plot placement parameters:
#' \preformatted{
#' plotHicRectangle(data, chrom,
#'                     chromstart = NULL, chromend = NULL,
#'                     x, y, width, height, just = c("left", "top"),
#'                     default.units = "inches")
#' }
#' This function can also be used to quickly plot an unannotated
#' rectangle Hi-C plot by ignoring plot placement parameters:
#' \preformatted{
#' plotHicRectangle(data, chrom,
#'                     chromstart = NULL, chromend = NULL)
#' }
#'
#' @seealso \link[plotlandscaper]{readHic}, \link[plotlandscaper]{readCool},
#' \link[plotlandscaper]{plotHicTriangle}
#'
#' @export
plotHicRectangle <- function(data, resolution = "auto", zrange = NULL,
                                norm = "KR", matrix = "observed", chrom,
                                chromstart = NULL, chromend = NULL,
                                assembly = "hg38",
                                palette = colorRampPalette(brewer.pal(
                                    n = 9, "YlGnBu"
                                )),
                                colorTrans = "linear", flip = FALSE, 
                                bg = NA,
                                x = NULL, y = NULL,
                                width = NULL, height = NULL,
                                just = c("left", "top"),
                                default.units = "inches", draw = TRUE,
                                params = NULL, quiet = FALSE) {

    # =========================================================================
    # FUNCTIONS
    # =========================================================================

    ## Define a function that catches errors for plotTriangleHic
    errorcheck_plotHicRectangle <- function(hic, hicPlot, norm) {

        ###### hic/cool/mcool/norm 
        hicErrors(hic = hic, 
                    norm = norm)

        ## Genomic region errors
        regionErrors(chromstart = hicPlot$chromstart,
                    chromend = hicPlot$chromend)

        ##### zrange errors
        rangeErrors(range = hicPlot$zrange)
    }

    ## Define a function that adjusts chromstart/chromend to include
    ## additional data for rectangle
    rect_region <- function(inputHeight, inputWidth, chromstart, chromend) {
        if (!is.null(chromstart) & !is.null(chromend)) {
            dimRatio <- inputHeight / inputWidth
            rectChromstart <- chromstart - ((chromend - chromstart) * dimRatio)
            rectChromend <- chromend + ((chromend - chromstart) * dimRatio)
        } else {
            rectChromstart <- NULL
            rectChromend <- NULL
        }
        
        return(list(rectChromstart, rectChromend))
    }

    ## Define a function that subsets data for rectangle Hi-C plot
    subset_data <- function(hic, hicPlot) {
        if (nrow(hic) > 0) {
            hic <- hic[which(hic[, "x"] >= floor(hicPlot$chromstart /
                hicPlot$resolution) *
                hicPlot$resolution &
                hic[, "x"] < hicPlot$chromend &
                hic[, "y"] >= floor(hicPlot$chromstart / hicPlot$resolution) *
                    hicPlot$resolution &
                hic[, "y"] < hicPlot$chromend), ]
        }

        return(hic)
    }

    rect_vpScale <- function(hicPlot, hicPlotInternal) {
        if (!is.null(hicPlot$chromstart) & !is.null(hicPlot$chromend)) {

            # updated chromstart
            in_xscale <- c(hicPlot$chromstart, hicPlot$chromend)
            # input chromstart
            out_xscale <- c(
                hicPlotInternal$chromstart,
                hicPlotInternal$chromend
            )
        } else {
            in_xscale <- c(0, 1)
            out_xscale <- c(0, 1)
        }

        return(list(in_xscale, out_xscale))
    }

    # =========================================================================
    # PARSE PARAMETERS
    # =========================================================================
    
    rhicInternal <- parseParams(params = params, 
                                    defaultArgs = formals(eval(
                                        match.call()[[1]])),
                                    declaredArgs = lapply(
                                        match.call()[-1], eval.parent, n = 2),
                                    class = "rhicInternal")
    ## Justification
    rhicInternal$just <- justConversion(just = rhicInternal$just)

    # =========================================================================
    # INITIALIZE OBJECT
    # =========================================================================

    hicPlot <- structure(list(
        chrom = rhicInternal$chrom,
        chromstart = rhicInternal$chromstart,
        chromend = rhicInternal$chromend,
        altchrom = rhicInternal$chrom,
        altchromstart = rhicInternal$chromstart,
        altchromend = rhicInternal$chromend,
        assembly = rhicInternal$assembly,
        resolution = rhicInternal$resolution,
        x = rhicInternal$x, y = rhicInternal$y,
        width = rhicInternal$width,
        height = rhicInternal$height,
        just = rhicInternal$just,
        color_palette = NULL,
        colorTrans = rhicInternal$colorTrans,
        zrange = rhicInternal$zrange,
        flip = rhicInternal$flip,
        outsideVP = NULL, grobs = NULL
    ),
    class = "hicRectangle"
    )
    attr(x = hicPlot, which = "plotted") <- rhicInternal$draw

    # =========================================================================
    # CHECK PLACEMENT/ARGUMENT ERRORS
    # =========================================================================

    if (is.null(rhicInternal$data)) stop("argument \"data\" is missing, ",
                                            "with no default.", call. = FALSE)
    if (is.null(rhicInternal$chrom)) stop("argument \"chrom\" is missing, ",
                                            "with no default.", call. = FALSE)
    check_placement(object = hicPlot)

    # =========================================================================
    # PARSE ASSEMBLY
    # =========================================================================

    hicPlot$assembly <- parseAssembly(assembly = hicPlot$assembly)

    # =========================================================================
    # PARSE UNITS
    # =========================================================================

    hicPlot <- defaultUnits(
        object = hicPlot,
        default.units = rhicInternal$default.units
    )

    # =========================================================================
    # CATCH ERRORS
    # =========================================================================

    errorcheck_plotHicRectangle(
        hic = rhicInternal$data,
        hicPlot = hicPlot,
        norm = rhicInternal$norm
    )

    # =========================================================================
    # GENOMIC SCALE
    # =========================================================================
    
    scaleChecks <- genomicScale(object = hicPlot,
                                objectInternal = rhicInternal,
                                plotType = "rectangle Hi-C plot")
    hicPlot <- scaleChecks[[1]]
    rhicInternal <- scaleChecks[[2]]

    # =========================================================================
    # ADJUST RESOLUTION
    # =========================================================================

    if (rhicInternal$resolution == "auto") {
        hicPlot <- adjust_resolution(
            hic = rhicInternal$data,
            hicPlot = hicPlot
        )
    } else {
        hicPlot <- hic_limit(
            hic = rhicInternal$data,
            hicPlot = hicPlot
        )
    }

    # =========================================================================
    # ADJUST CHROMSTART TO GRAB MORE DATA
    # =========================================================================

    if (is.null(hicPlot$x) & is.null(hicPlot$y)) {
        inputHeight <- 0.5
        inputWidth <- 1
    } else {
        inputHeight <- convertHeight(hicPlot$height,
            unitTo = get("page_units", envir = pgEnv),
            valueOnly = TRUE
        )
        inputWidth <- convertWidth(hicPlot$width,
            unitTo = get("page_units", envir = pgEnv),
            valueOnly = TRUE
        )
    }


    adjRegion <- rect_region(
        inputHeight = inputHeight, inputWidth = inputWidth,
        chromstart = hicPlot$chromstart,
        chromend = hicPlot$chromend
    )

    hicPlot$chromstart <- adjRegion[[1]]
    hicPlot$altchromstart <- adjRegion[[1]]
    hicPlot$chromend <- adjRegion[[2]]
    hicPlot$altchromend <- adjRegion[[2]]
    
    # =========================================================================
    # READ IN DATA
    # =========================================================================

    hic <- read_data(
        hic = rhicInternal$data, hicPlot = hicPlot,
        norm = rhicInternal$norm, assembly = hicPlot$assembly,
        type = rhicInternal$matrix,
        quiet = rhicInternal$quiet
    )

    # =========================================================================
    # SUBSET DATA
    # =========================================================================

    hic <- subset_data(hic = hic, hicPlot = hicPlot)
    
    # =========================================================================
    # GET LOWER TRIANGULAR FOR FLIP
    # =========================================================================
    
    if (rhicInternal$flip == TRUE){
        hic <- hic[, c("y", "x", "counts")]
        colnames(hic) <- c("x", "y", "counts")
    }
    
    # =========================================================================
    # SET ZRANGE AND SCALE DATA
    # =========================================================================

    hicPlot <- set_zrange(hic = hic, hicPlot = hicPlot)
    hic$counts[hic$counts <= hicPlot$zrange[1]] <- hicPlot$zrange[1]
    hic$counts[hic$counts >= hicPlot$zrange[2]] <- hicPlot$zrange[2]

    # =========================================================================
    # CONVERT NUMBERS TO COLORS
    # =========================================================================

    ## if we don't have an appropriate zrange
    ## (even after setting it based on a null zrange), can't scale to colors
    if (!is.null(hicPlot$zrange) & length(unique(hicPlot$zrange)) == 2) {
        if (grepl("log", rhicInternal$colorTrans) == TRUE) {
            logBase <- utils::type.convert(gsub("log", "", 
                                                rhicInternal$colorTrans), 
                                    as.is = TRUE)
            if (is.na(logBase)) {
                logBase <- exp(1)
            }

            ## Won't scale to log if negative values
            if (any(hic$counts < 0)) {
                stop("Negative values in Hi-C data. Cannot scale ",
                "colors on a log scale. Please set `colorTrans = 'linear'`.",
                    call. = FALSE
                )
            }


            hic$counts <- log(hic$counts, base = logBase)
            hic$color <- mapColors(vector = hic$counts,
                palette = rhicInternal$palette,
                range = log(hicPlot$zrange, logBase)
            )
        } else {
            hic$color <- mapColors(vector = hic$counts,
                palette = rhicInternal$palette,
                range = hicPlot$zrange
            )
        }

        hicPlot$color_palette <- rhicInternal$palette
    }

    # =========================================================================
    # VIEWPORTS
    # =========================================================================

    ## Viewport scale
    scale <- rect_vpScale(
        hicPlot = hicPlot,
        hicPlotInternal = rhicInternal
    )
    
    ## Inner viewport y-coordinate
    if (rhicInternal$flip == TRUE){
        y <- unit(1, "npc")
    } else {
        y <- unit(0, "npc")
    }

    if (is.null(hicPlot$x) | is.null(hicPlot$y)) {
        vp_name <- "hicRectangle1"
        inside_vp <- viewport(
            height = unit(4 / sqrt(2), "npc"),
            width = unit(2 / sqrt(2), "npc"),
            x = unit(scale[[1]][1], "native"),
            y = y,
            xscale = scale[[1]],
            yscale = scale[[1]],
            just = c("left", "bottom"),
            name = "hicRectangle1_inside",
            angle = -45
        )
        
        # Number of bins along yscale
        num_pixelsWidth <- 
            (rhicInternal$chromend - rhicInternal$chromstart)/hicPlot$resolution
        per_pixel <- 1/num_pixelsWidth
        num_pixelsHeight <- 0.5/per_pixel

        outside_vp <- viewport(
            height = unit(0.5, "snpc"),
            width = unit(1, "snpc"),
            x = unit(0.5, "npc"),
            y = unit(0.5, "npc"),
            xscale = scale[[2]],
            yscale = c(0, num_pixelsHeight),
            clip = "on",
            just = "center",
            name = "hicRectangle1_outside"
        )


        if (rhicInternal$draw == TRUE) {
            grid.newpage()
        }
    } else {
        
        ## Get viewport name
        currentViewports <- current_viewports()
        vp_name <- paste0(
            "hicRectangle",
            length(grep(
                pattern = "hicRectangle",
                x = currentViewports
            )) + 1
        )

        ## Convert coordinates into same units as page
        page_coords <- convert_page(object = hicPlot)

        ## Get length of side of inside viewport
        vp_side <- (as.numeric(page_coords$width) + 2 *
            as.numeric(page_coords$height)) / sqrt(2)
            
        inside_vp <- viewport(
                height = unit(
                    vp_side,
                    get("page_units", envir = pgEnv)
                ),
                width = unit(
                    vp_side,
                    get("page_units", envir = pgEnv)
                ),
                x = unit(scale[[1]][1], "native"),
                y = y,
                xscale = scale[[1]],
                yscale = scale[[1]],
                just = c("left", "bottom"),
                name = paste0(vp_name, "_inside"),
                angle = -45
            )
        
        # Number of bins along yscale
        num_pixelsWidth <- 
            (rhicInternal$chromend - rhicInternal$chromstart)/hicPlot$resolution
        per_pixel <- as.numeric(page_coords$width)/num_pixelsWidth
        num_pixelsHeight <- as.numeric(page_coords$height)/per_pixel
        
        outside_vp <- viewport(
                height = page_coords$height,
                width = page_coords$width,
                x = page_coords$x, y = page_coords$y,
                just = hicPlot$just,
                xscale = scale[[2]],
                yscale = c(0, num_pixelsHeight),
                clip = "on",
                name = paste0(vp_name, "_outside")
            ) 
            
        addViewport(paste0(vp_name, "_outside"))
    }

    # =========================================================================
    # INITIALIZE GTREE FOR GROBS WITH BACKGROUND
    # =========================================================================
    
    hicPlot$outsideVP <- outside_vp
    backgroundGrob <- rectGrob(gp = gpar(
        fill = rhicInternal$bg,
        col = NA
    ), name = "background")
    assign("hic_grobs3", gTree(vp = inside_vp, children = gList(backgroundGrob)),
        envir = pgEnv
    )
    
    # =========================================================================
    # MAKE GROBS
    # =========================================================================

    if (!is.null(hicPlot$chromstart) & !is.null(hicPlot$chromend)) {
        if (nrow(hic) > 0) {
            hic_squares <- rectGrob(
                x = hic$x,
                y = hic$y,
                just = c("left", "bottom"),
                width = hicPlot$resolution,
                height = hicPlot$resolution,
                gp = gpar(col = NA, fill = hic$color),
                default.units = "native"
            )

            assign("hic_grobs3",
                addGrob(
                    gTree = get("hic_grobs3", envir = pgEnv),
                    child = hic_squares
                ),
                envir = pgEnv
            )
        } else {
            if (!is.na(hicPlot$resolution)){
                warning("No data found in region.", call. = FALSE)
            }
        }
    }


    # ========================================================================
    # IF DRAW == TRUE, DRAW GROBS
    # ========================================================================

    if (rhicInternal$draw == TRUE) {
        pushViewport(outside_vp)
        grid.draw(get("hic_grobs3", envir = pgEnv))
        upViewport()
    }

    # =========================================================================
    # ADD GROBS TO OBJECT AND RESET CHROMSTART AND CHROMEND
    # =========================================================================

    hicPlot$grobs <- get("hic_grobs3", envir = pgEnv)
    hicPlot$chromstartAdjusted <- hicPlot$chromstart
    hicPlot$chromendAdjusted <- hicPlot$chromend
    hicPlot$chromstart <- rhicInternal$chromstart
    hicPlot$chromend <- rhicInternal$chromend

    # =========================================================================
    # RETURN OBJECT
    # =========================================================================

    message("hicRectangle[", vp_name, "]")
    invisible(hicPlot)
}
